## The street generator: fair for every seed. Static checks of what it builds (no player physics).
## Spec: design/game-brief.md, src/core/track_gen.gd.
extends GdUnitTestSuite

const SEEDS := 30
const SWERVE := ["stall", "phaeton", "caravan"] ## things that can only be swerved round


## A sim that counts the pickups the generator asks for (to see if any later vanish).
class CountingSim extends RunSim:
	var made := {}

	func add_pickup(kind: String, lane: int, s_at: float, y_at: float) -> Pickup:
		made[kind] = made.get(kind, 0) + 1
		return super(kind, lane, s_at, y_at)


func _street(seed_value: int, metres: float, t: Tuning, counting := false) -> RunSim:
	var sim: RunSim = CountingSim.new(t) if counting else RunSim.new(t)
	var gen := TrackGen.new(sim, seed_value)
	gen.hunt_open = true
	while sim.s < metres:
		sim.s += 20.0
		gen.fill()
	return sim


func _distance_at(t: Tuning, seconds: float) -> float:
	var sim := RunSim.new(t)
	var s := 0.0
	var x := 0.0
	while x < seconds:
		s += sim.speed_at(x) / 60.0
		x += 1.0 / 60.0
	return s


func test_no_place_blocks_all_three_lanes_with_swerve_only_things() -> void:
	var t: Tuning = load("res://src/data/tuning.tres")
	for sd in SEEDS:
		var sim := _street(sd, 2500.0, t)
		var s := 0.0
		while s < 2500.0:
			var blocked := {}
			for o in sim.obstacles:
				if o.kind in SWERVE and o.s0 <= s and o.s1() >= s:
					blocked[o.lane] = true
			assert_int(blocked.size()).override_failure_message("seed %d at %.0f m" % [sd, s]).is_less(3)
			s += 1.0


func test_every_run_meets_the_simurq_early() -> void:
	var t: Tuning = load("res://src/data/tuning.tres")
	var limit := _distance_at(t, 32.0)
	for sd in SEEDS:
		var sim := _street(sd, limit + 50.0, t)
		var first := INF
		for p in sim.pickups:
			if p.kind == "simurq":
				first = minf(first, p.s)
		assert_float(first).override_failure_message("seed %d" % sd).is_less(limit)


# Regression: the side cart next to a caravan deleted buta stones lying where it was put.
func test_side_cart_keeps_buta_stones() -> void:
	var t: Tuning = (load("res://src/data/tuning.tres") as Tuning).duplicate()
	t.hunt_chance = 1.0
	t.caravan_ramp_chance = 1.0
	for sd in SEEDS:
		var sim: CountingSim = _street(sd, 3000.0, t, true)
		var have := 0
		for p in sim.pickups:
			if p.kind == "buta":
				have += 1
		assert_int(have).override_failure_message("seed %d" % sd).is_equal(int(sim.made.get("buta", 0)))


# After the children's ramp the rows keep getting closer, down to row_gap_late (owner, 2026-11-25).
func test_row_gap_keeps_shrinking_for_grown_ups() -> void:
	var tune: Tuning = load("res://src/data/tuning.tres")
	assert_float(TrackGen.row_gap_at(tune, 0.0)).is_equal_approx(tune.row_gap_start, 0.001)
	assert_float(TrackGen.row_gap_at(tune, tune.ramp_time)).is_equal_approx(tune.row_gap_end, 0.001)
	assert_float(TrackGen.row_gap_at(tune, tune.ramp_time + tune.late_ramp_time * 0.5)).is_less(tune.row_gap_end)
	assert_float(TrackGen.row_gap_at(tune, 100000.0)).is_equal_approx(tune.row_gap_late, 0.001)
