## The run's rules: what each obstacle asks for, the Div, power-ups, and the bugs the gameplay playtest found
## (each regression test was watched failing on the code before its fix).
## Spec: design/game-brief.md, prototypes/cirtdan (the reference), src/core/run_sim.gd.
extends GdUnitTestSuite

const DT := 1.0 / 60.0

var tune: Tuning
var sim: RunSim
var input := RunSim.RunInput.new()


func before_test() -> void:
	tune = load("res://src/data/tuning.tres")
	sim = RunSim.new(tune)


func _run(seconds: float) -> void:
	for i in int(seconds / DT):
		sim.step(DT, input)
		input.clear()
		if sim.dead != "":
			return


func _frames_until_landing() -> int:
	var probe := RunSim.new(tune)
	var i := RunSim.RunInput.new()
	i.jump = true
	probe.step(DT, i)
	var n := 1
	while not probe.grounded and n < 600:
		probe.step(DT, RunSim.RunInput.new())
		n += 1
	return n


func test_running_into_basket_stumbles() -> void:
	sim.add_obstacle("basket", 1, 8.0)
	var stumbles := [0]
	sim.stumbled.connect(func() -> void: stumbles[0] += 1)
	_run(2.0)
	assert_int(stumbles[0]).is_equal(1)
	assert_str(sim.dead).is_empty()


func test_jumping_basket_counts_as_passed() -> void:
	sim.add_obstacle("basket", 1, 8.0)
	var passed := []
	sim.passed.connect(func(k: String) -> void: passed.append(k))
	_run(0.45) # about 4.5 m before it
	input.jump = true
	_run(2.0)
	assert_array(passed).contains(["basket"])


func test_stall_head_on_ends_run() -> void:
	sim.add_obstacle("stall", 1, 8.0)
	_run(2.0)
	assert_str(sim.dead).is_equal("crash")


func test_second_stumble_while_div_near_is_caught() -> void:
	sim.add_obstacle("basket", 1, 8.0)
	sim.add_obstacle("basket", 1, 20.0)
	_run(3.0)
	assert_str(sim.dead).is_equal("caught")


func test_city_treat_counts_its_worth() -> void:
	sim.treat_worth = 5
	sim.add_pickup("treat", 1, 3.0, 0.6)
	_run(1.0)
	assert_int(sim.bread).is_equal(5)


# Regression: a jump pressed 117 ms before landing was lost (the buffer counted down in the step it was set).
func test_jump_buffer_keeps_press_120_ms_before_landing() -> void:
	var land := _frames_until_landing()
	var jumps := [0]
	sim.jumped.connect(func() -> void: jumps[0] += 1)
	input.jump = true
	sim.step(DT, input)
	input.clear()
	for f in range(1, land + 3):
		if f == land - 8: # 7 steps (117 ms) before the step he lands in
			input.jump = true
		sim.step(DT, input)
		input.clear()
	assert_int(jumps[0]).is_equal(2)


# Regression: flying over a basket and a carpet counted as jumping and sliding them.
func test_flying_over_obstacles_does_not_count_as_passing() -> void:
	sim.power["simurq"] = 6.0
	sim.add_obstacle("basket", 1, 30.0)
	sim.add_obstacle("carpet", 1, 40.0)
	var passed := []
	sim.passed.connect(func(k: String) -> void: passed.append(k))
	_run(5.0)
	assert_array(passed).is_empty()


# Regression: the carpet shield's time ran out while flying, when nothing can hit him.
func test_carpet_shield_waits_during_flight() -> void:
	sim.carpets = 1
	input.carpet = true
	sim.step(DT, input)
	input.clear()
	sim.power["simurq"] = 8.0
	_run(7.0)
	assert_float(sim.carpet_t).is_greater_equal(tune.carpet_time - 0.2)


# Regression: with the pole he hopped on his own rhythm, into stalls; now he leaps when the player jumps.
func test_pole_waits_for_jump_then_leaps_high() -> void:
	sim.power["pole"] = 10.0
	_run(1.0)
	assert_bool(sim.grounded).is_true()
	input.jump = true
	var top := 0.0
	for i in 90:
		sim.step(DT, input)
		input.clear()
		top = maxf(top, sim.y)
	assert_float(top).is_greater_equal(tune.pole_height * 0.95)


# Regression: the camels' backs were only a moment's ride; they now stop when Cırtdan is on them.
func test_caravan_stops_when_ridden() -> void:
	var c := sim.add_obstacle("caravan", 1, -2.0) # under him: it spans -2 .. 10 m
	sim.y = c.top
	sim.prev_y = c.top
	sim.grounded = false
	_run(0.1)
	assert_str(sim.on_roof).is_equal("caravan")
	assert_bool(c.moving).is_false()


# The run eases in for children, then keeps speeding up for grown-ups (owner, 2026-11-25).
func test_speed_children_phase_unchanged() -> void:
	assert_float(sim.speed_at(0.0)).is_equal_approx(tune.speed_start, 0.001)
	assert_float(sim.speed_at(60.0)).is_equal_approx(tune.speed_start + tune.speed_ramp * 60.0, 0.001)
	assert_float(sim.speed_at(150.0)).is_less_equal(tune.speed_max + 0.001)


func test_speed_keeps_rising_after_the_children_phase() -> void:
	var t_max := (tune.speed_max - tune.speed_start) / tune.speed_ramp
	assert_float(sim.speed_at(t_max + 60.0)).is_greater(tune.speed_max)
	assert_float(sim.speed_at(t_max + 60.0)).is_greater(sim.speed_at(t_max + 30.0))


func test_speed_never_passes_the_late_cap() -> void:
	assert_float(sim.speed_at(100000.0)).is_equal_approx(tune.speed_late_max, 0.001)
