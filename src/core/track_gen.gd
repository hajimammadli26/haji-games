## Builds the street ahead of the runner from hand-made rows, each one passable at the speed it is met.
## The opening rows teach one move each; later rows block more lanes as the run gets harder.
## Seeded: the same seed builds the same street.
##
## Usage:
##   var gen := TrackGen.new(sim, 7)
##   gen.fill()   # call every step: builds until tune.view_ahead metres ahead
class_name TrackGen
extends RefCounted

## The first rows: one move each (jump, slide, swerve), then a mix, a ramp onto a cart, a phaeton.
const INTRO := [
	[["basket", 1]], [["carpet", 0]], [["stall", 2]], [["basket", 0], ["carpet", 2]],
	[["cart", 1, {"ramp": true}]], [["phaeton", 2]],
]

var sim: RunSim
var rng := RandomNumberGenerator.new()
var next_s := 0.0 ## where the next row goes
var rows := 0
var caravans := 0
var simurqs := 0
var reserved := [0.0, 0.0, 0.0] ## a caravan's lane stays clear up to this s
var hunt_open := false ## the week's buta hunt is on: buta stones lie in the street
var letters := true ## the day's word: its letters lie in the street, one at a time
var treats := false ## this city has its own treat: some bread lines are made of it


func _init(run: RunSim, seed_value: int) -> void:
	sim = run
	rng.seed = seed_value
	_bread_line(1, 14.0, sim.tune.bread_line + 2, 0.6) # a row of bread to lead the way
	next_s = sim.tune.speed_start * sim.tune.safe_start


## Builds rows until the street reaches tune.view_ahead metres past the runner.
func fill() -> void:
	while next_s < sim.s + sim.tune.view_ahead:
		_row()


func _difficulty(t: float) -> float:
	return minf(1.0, t / sim.tune.ramp_time)


func _row() -> void:
	var tune := sim.tune
	var s := next_s
	var t := s / maxf(1.0, (tune.speed_start + sim.speed_at(s / tune.speed_start)) * 0.5) # about when he gets here
	var d := _difficulty(t)
	var v := sim.speed_at(t)
	var row: Array = []
	if rows < INTRO.size():
		row = INTRO[rows]
	else:
		var free: Array[int] = []
		for l in 3:
			if reserved[l] <= s:
				free.append(l)
		if caravans == 0 and t > tune.caravan_after and not free.is_empty():
			row = [["caravan", free[rng.randi() % free.size()]]] # the first caravan comes on time, alone
		else:
			var n := 1
			var r := rng.randf()
			if t > tune.double_block_after and r < 0.25 + 0.4 * d:
				n = 2
			if t > tune.double_block_after + 30.0 and r < 0.12 + 0.2 * d:
				n = 3
			n = mini(n, free.size())
			_shuffle(free)
			var safe := n < 3 # three lanes blocked: at least one must be jumped or slid
			for i in n:
				var pool := ["basket", "carpet", "stall", "stall", "phaeton", "cart", "cart"]
				if t > tune.caravan_after and n < 3 and not _row_has(row, "caravan"):
					pool.append_array(["caravan", "caravan"])
				var kind: String = pool[rng.randi() % pool.size()]
				if n == 3 and i == 2 and not safe:
					kind = "basket" if rng.randf() < 0.5 else "carpet"
				if n == 3 and kind == "caravan":
					kind = "stall"
				if kind in ["basket", "carpet", "cart"]:
					safe = true
				var opts := {}
				if kind == "cart":
					opts["ramp"] = n == 3 or rng.randf() < 0.6
					if d > 0.4 and rng.randf() < 0.4:
						opts["len"] = 12.0
				row.append([kind, free[i], opts])
	var end := s
	var used := {}
	for e in row:
		var kind: String = e[0]
		var lane: int = e[1]
		var opts: Dictionary = e[2] if e.size() > 2 else {}
		used[lane] = true
		if kind == "caravan":
			var ahead := maxf(0.0, s - sim.s)
			var at := s + tune.caravan_speed * ahead / maxf(1.0, sim.speed)
			var c := sim.add_obstacle("caravan", lane, at)
			caravans += 1
			reserved[lane] = at + c.length + 4.0
			end = maxf(end, s + 3.0)
			_side_cart(row, lane, s, used)
			continue
		if kind == "cart":
			var s0 := s
			if opts.get("ramp", false):
				sim.add_obstacle("ramp", lane, s)
				s0 = s + RunSim.KINDS["ramp"]["len"]
			var o := sim.add_obstacle("cart", lane, s0, opts)
			_bread_line(lane, s0 + 0.8, int(o.length / 2.2), o.top + 0.6)
			end = maxf(end, o.s1())
			continue
		var ob := sim.add_obstacle(kind, lane, s)
		if kind == "basket" and rng.randf() < 0.6:
			_bread_arc(lane, s + ob.length * 0.5)
		end = maxf(end, ob.s1())
	# bread in a free lane, stopping before the next row
	var gap_dist := v * (tune.row_gap_start + (tune.row_gap_end - tune.row_gap_start) * d)
	var free_l: Array[int] = []
	for l in 3:
		if not used.has(l) and reserved[l] <= s:
			free_l.append(l)
	if not free_l.is_empty():
		# one lane gets the line; a nar or a power-up takes a slot in it instead of sitting on a bread
		var l := free_l[rng.randi() % free_l.size()]
		var count := clampi(int((gap_dist - 1.5 + 4.0) / 2.2) + 1, 2, tune.bread_line)
		var special := ""
		var r := rng.randf()
		if r < tune.nar_chance:
			special = "nar"
		elif simurqs == 0 and rows >= tune.simurq_first_row:
			special = "simurq" # every run meets the Simurq early
		elif r < tune.nar_chance + tune.power_chance and rows > INTRO.size():
			special = "simurq" if rng.randf() < tune.simurq_share else ["magnet", "shoe", "double", "pole"][rng.randi() % 4]
		if special == "simurq":
			simurqs += 1
		var taken := {}
		if special != "":
			var k := mini(3, count - 1)
			sim.add_pickup(special, l, s - 4.0 + k * 2.2, 1.0)
			taken[k] = true
		if hunt_open and rows > INTRO.size() and rng.randf() < tune.hunt_chance and not taken.has(count - 1):
			sim.add_pickup("buta", l, s - 4.0 + (count - 1) * 2.2, 0.8)
			taken[count - 1] = true
		var ks := mini(2, count - 1)
		if rows > INTRO.size() and rng.randf() < tune.stone_chance and not taken.has(ks):
			sim.add_pickup("stone", l, s - 4.0 + ks * 2.2, 1.0)
			taken[ks] = true
		if letters and rows > 3 and rng.randf() < tune.letter_chance and not _letter_waiting():
			var other: Array[int] = []
			for x in free_l:
				if x != l:
					other.append(x)
			if not other.is_empty(): # a lane of its own
				sim.add_pickup("letter", other[rng.randi() % other.size()], s + 1.0, 1.1)
			elif not taken.has(mini(1, count - 1)):
				taken[mini(1, count - 1)] = true
				sim.add_pickup("letter", l, s - 4.0 + mini(1, count - 1) * 2.2, 1.1)
		if rng.randf() < 0.7:
			var kind := "treat" if treats and rng.randf() < tune.treat_share else "bread"
			for i in count:
				if not taken.has(i):
					sim.add_pickup(kind, l, s - 4.0 + i * 2.2, 0.6)
	rows += 1
	next_s = maxf(s + gap_dist, end + 3.0 + v * 0.35)


## A hay cart with a ramp in the next lane, ending just before a caravan meets the runner:
## jump across onto the camels' backs.
func _side_cart(row: Array, lane: int, s: float, used: Dictionary) -> void:
	var tune := sim.tune
	var side: Array[int] = []
	for l in [lane - 1, lane + 1]:
		if l >= 0 and l <= 2 and not _row_has_lane(row, l) and reserved[l] <= s:
			side.append(l)
	if side.is_empty() or rng.randf() >= tune.caravan_ramp_chance:
		return
	var l2 := side[rng.randi() % side.size()]
	var c0 := s - 10.0
	var ramp_len: float = RunSim.KINDS["ramp"]["len"]
	for q in sim.obstacles:
		if q.lane == l2 and q.s1() > c0 - ramp_len - 2.0 and q.s0 < s:
			return
	for i in range(sim.pickups.size() - 1, -1, -1): # nothing left inside the cart
		var p := sim.pickups[i]
		if p.lane == l2 and p.s > c0 - ramp_len - 1.0 and p.s < c0 + 7.0 and p.y < 2.0:
			if p.node != null:
				p.node.queue_free()
			sim.pickups.remove_at(i)
	sim.add_obstacle("ramp", l2, c0 - ramp_len)
	sim.add_obstacle("cart", l2, c0, {"len": 6.0})
	_bread_line(l2, c0 + 0.8, 3, RunSim.KINDS["cart"]["top"] + 0.6)
	used[l2] = true


func _bread_line(lane: int, s: float, n: int, y: float) -> void:
	for i in n:
		sim.add_pickup("bread", lane, s + i * 2.2, y)


func _bread_arc(lane: int, s_mid: float) -> void: # the jump's path over a low obstacle
	for i in 5:
		var u := i / 4.0 * 2.0 - 1.0
		sim.add_pickup("bread", lane, s_mid + u * 3.2, 0.6 + 1.4 * (1.0 - u * u))


func _shuffle(a: Array[int]) -> void: # seeded, so the same seed gives the same street
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var tmp := a[i]
		a[i] = a[j]
		a[j] = tmp


func _letter_waiting() -> bool:
	for p in sim.pickups:
		if p.kind == "letter" and not p.taken:
			return true
	return false


func _row_has(row: Array, kind: String) -> bool:
	for e in row:
		if e[0] == kind:
			return true
	return false


func _row_has_lane(row: Array, lane: int) -> bool:
	for e in row:
		if e[1] == lane:
			return true
	return false
