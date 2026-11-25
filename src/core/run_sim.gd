## The run, without any drawing: Cırtdan's lane, jump and slide, the obstacles and pickups on the street,
## the collisions, the Div and the score. One call to step() advances it by a fixed time step.
## Distance runs along -z in the world: something at track position s sits at z = -s.
##
## Usage:
##   var sim := RunSim.new(load("res://src/data/tuning.tres"))
##   sim.add_obstacle("basket", 1, 80.0)
##   var input := RunSim.RunInput.new(); input.jump = true
##   sim.step(1.0 / 60.0, input)   # then read sim.y, sim.dead, sim.bread ...
class_name RunSim
extends RefCounted

## A stumble: the Div comes close (a second one while he is close and he catches you).
signal stumbled
## A head-on hit with something solid; the run ends.
signal crashed(kind: String)
## The Div caught Cırtdan; the run ends.
signal caught
## A yağ çörəyi was picked up; total is this run's count.
signal bread_taken(total: int)
## Cırtdan left the ground.
signal jumped
## Cırtdan started a slide.
signal slid
## A power-up was picked up (magnet, shoe, double, pole, simurq) or the boost started (fly).
signal power_taken(kind: String)
## A nar was picked up.
signal nar_taken
## The flying carpet took a hit for Cırtdan.
signal shield_used
## The Simurq or the boost put Cırtdan back on the ground.
signal landed_from_flight
## A letter of the day's word, a buta stone or a magic stone was picked up (kind: letter, buta, stone).
signal item_taken(kind: String)
## Cırtdan got past an obstacle in his own lane without touching it (over a basket, under a carpet).
signal passed(kind: String)
## The Div had come close after a stumble and Cırtdan got away again.
signal escaped

## Power-ups and how long each lasts is power_time(kind).
const POWERS := ["magnet", "shoe", "double", "pole", "simurq", "fly"]

const PSTAND := 1.45 ## standing height (papaq included), so a carpet at 1.15 needs a slide
const PSLIDE := 0.5 ## height while sliding
const PHALF := 0.3 ## half width
const PDEPTH := 0.3 ## half depth along the street

## What each obstacle asks for and what a head-on hit does. len and top in metres.
const KINDS := {
	"basket": {"len": 1.1, "top": 0.85, "bottom": 0.0, "frontal": "stumble", "half": 0.95},
	"carpet": {"len": 0.3, "top": 2.62, "bottom": 1.15, "frontal": "stumble", "half": 1.0},
	"stall": {"len": 1.5, "top": 3.0, "bottom": 0.0, "frontal": "crash", "half": 0.95},
	"phaeton": {"len": 5.6, "top": 2.4, "bottom": 0.0, "frontal": "crash", "half": 0.85},
	"cart": {"len": 6.0, "top": 1.6, "bottom": 0.0, "frontal": "crash", "half": 0.9, "roof": true},
	"caravan": {"len": 12.0, "top": 2.2, "bottom": 0.0, "frontal": "crash", "half": 0.8, "roof": true, "moves": true},
	"ramp": {"len": 4.0, "top": 1.6, "bottom": 0.0, "frontal": "", "half": 0.8, "ramp": true},
}

## One frame's input: each flag is true for the step it was pressed in.
class RunInput:
	var left := false
	var right := false
	var jump := false
	var slide := false
	var carpet := false ## use a flying carpet (double tap)
	var boost := false ## start the bought boost (only in its window)

	## Clears every flag (call after each step).
	func clear() -> void:
		left = false
		right = false
		jump = false
		slide = false
		carpet = false
		boost = false

## Something on the street. s0 is its near end along the track.
class Obstacle:
	var kind: String
	var lane: int
	var s0: float
	var prev_s0: float
	var length: float
	var top: float
	var bottom: float
	var frontal: String
	var half: float
	var roof := false
	var ramp := false
	var moving := false
	var hit := false
	var passed := false
	var cleared := false ## taken away by a shield or a continue: no longer there
	var node: Node3D ## its drawing, owned by the game scene

	## The far end along the track.
	func s1() -> float:
		return s0 + length

## Something to pick up.
class Pickup:
	var kind: String
	var lane: int
	var x: float
	var s: float
	var y: float
	var taken := false
	var node: Node3D ## its drawing, owned by the game scene

var tune: Tuning
var time := 0.0
var s := 0.0
var prev_s := 0.0
var speed := 0.0
var lane := 1
var prev_lane := 1
var x := 0.0
var prev_x := 0.0
var y := 0.0
var prev_y := 0.0
var vy := 0.0
var grounded := true
var on_roof := ""
var slide_t := 0.0
var air_t := 0.0
var jump_buf := 0.0
var div_t := 0.0
var intro_t := 0.0
var stumble_t := 0.0
var invuln := 0.0
var div_gap := 0.0
var bread := 0
var score := 0.0
var mult := 1
var treat_worth := 3 ## bread one of this city's treats is worth (Şəki halvası is worth more)
var base_mult := 1 ## from missions (every third claim adds one); distance adds up to mult_cap - 1
var dead := "" ## "", "crash" or "caught"
var power := {} ## kind -> seconds left
var levels := {} ## shop levels by power kind (set by the game from the save)
var carpet_t := 0.0 ## seconds the shield carpet has left
var carpets := 0 ## carpets in hand this run (free ones first)
var free_carpets := 0
var boosts := 0 ## start boosts owned (the game spends one from the save)
var boost_used := false
var nar_got := 0
var continues := 0
var obstacles: Array[Obstacle] = []
var pickups: Array[Pickup] = []


func _init(tuning: Tuning) -> void:
	tune = tuning
	reset()


## Back to the start line: an empty street, the Div on screen for his opening chase.
func reset() -> void:
	time = 0.0
	s = 0.0
	prev_s = 0.0
	speed = tune.speed_start
	lane = 1
	prev_lane = 1
	x = 0.0
	prev_x = 0.0
	y = 0.0
	prev_y = 0.0
	vy = 0.0
	grounded = true
	on_roof = ""
	slide_t = 0.0
	air_t = 0.0
	jump_buf = 0.0
	div_t = 0.0
	intro_t = tune.div_intro_time
	stumble_t = 0.0
	invuln = 0.0
	div_gap = tune.div_near_gap
	bread = 0
	score = 0.0
	mult = 1
	dead = ""
	for k in POWERS:
		power[k] = 0.0
	carpet_t = 0.0
	free_carpets = tune.carpets_per_run
	carpets = free_carpets
	boost_used = false
	nar_got = 0
	continues = 0
	obstacles.clear()
	pickups.clear()


## How long a power-up lasts at its shop level.
func power_time(kind: String) -> float:
	if kind == "fly":
		return tune.boost_time
	var base := tune.simurq_time if kind == "simurq" else tune.power_time
	return base + float(levels.get(kind, 0)) * tune.upgrade_step


## True while the Simurq or the boost carries Cırtdan.
func is_flying() -> bool:
	return power["simurq"] > 0.0 or power["fly"] > 0.0


## True while the start boost can still be used.
func boost_open() -> bool:
	return not boost_used and boosts > 0 and time < tune.boost_window and dead == ""


## Nar for the next continue: continue_cost, doubling each time in a run.
func continue_cost() -> int:
	return tune.continue_cost * (1 << continues)


## Back into the run after a crash: the Div backs off, the street just ahead is cleared,
## a moment of safety. The game takes the nar from the save first.
func continue_run() -> void:
	continues += 1
	dead = ""
	div_t = 0.0
	stumble_t = 0.0
	invuln = 2.5
	vy = 0.0
	for o in obstacles:
		if o.s0 < s + 25.0 and o.s1() > s - 2.0:
			o.hit = true
			o.cleared = true


## A winding line of bread high over the street, for a flight of this many seconds.
func sky_bread(seconds: float) -> void:
	var n := maxi(3, int((seconds * speed - 18.0) / 3.0)) # ends before he lands
	for i in n:
		var l := clampi(roundi(1.0 + sin(i * 0.35) * 1.2), 0, 2)
		add_pickup("bread", l, s + 14.0 + i * 3.0, tune.simurq_height + 0.6)


## The x of a lane's centre (lane 0, 1 or 2).
func lane_x(l: int) -> float:
	return (l - 1) * tune.lane_width


## The running speed t seconds into a run.
func speed_at(t: float) -> float:
	return minf(tune.speed_max, tune.speed_start + tune.speed_ramp * t)


## True while Cırtdan is sliding.
func is_sliding() -> bool:
	return slide_t > 0.0


## Puts an obstacle on the street and returns it. opts may hold "len".
func add_obstacle(kind: String, l: int, s0: float, opts: Dictionary = {}) -> Obstacle:
	var k: Dictionary = KINDS[kind]
	var o := Obstacle.new()
	o.kind = kind
	o.lane = l
	o.s0 = s0
	o.prev_s0 = s0
	o.length = float(opts.get("len", k["len"]))
	o.top = k["top"]
	o.bottom = k["bottom"]
	o.frontal = k["frontal"]
	o.half = k["half"]
	o.roof = k.get("roof", false)
	o.ramp = k.get("ramp", false)
	o.moving = k.get("moves", false)
	obstacles.append(o)
	return o


## Puts a pickup on the street and returns it.
func add_pickup(kind: String, l: int, at_s: float, at_y: float) -> Pickup:
	var p := Pickup.new()
	p.kind = kind
	p.lane = l
	p.x = lane_x(l)
	p.s = at_s
	p.y = at_y
	pickups.append(p)
	return p


## Advances the run by dt seconds with this step's input.
func step(dt: float, input: RunInput) -> void:
	if dead != "":
		return
	time += dt
	prev_s = s
	prev_x = x
	prev_y = y
	speed = speed_at(time)
	# input
	if input.left and lane > 0:
		prev_lane = lane
		lane -= 1
	if input.right and lane < 2:
		prev_lane = lane
		lane += 1
	if input.jump:
		jump_buf = tune.input_buffer + dt # + one step: it is counted down in this same step
	if input.carpet and carpets > 0 and carpet_t <= 0.0:
		carpets -= 1
		if free_carpets > 0:
			free_carpets -= 1
		carpet_t = tune.carpet_time
		power_taken.emit("carpet")
	if input.boost and boost_open():
		boost_used = true
		boosts -= 1
		power["fly"] = tune.boost_time
		sky_bread(tune.boost_time)
		power_taken.emit("fly")
	if input.slide:
		if not grounded:
			vy = -tune.fast_fall_speed
		slide_t = tune.slide_time
		jump_buf = 0.0
		slid.emit()
	# forward and sideways
	s += speed * dt
	var tx := lane_x(lane)
	var mv := tune.lane_change_speed * dt
	x = tx if absf(tx - x) <= mv else x + signf(tx - x) * mv
	# vertical
	air_t = 0.0 if grounded else air_t + dt
	if jump_buf > 0.0 and (grounded or air_t < tune.coyote_time):
		var hgt := tune.super_jump_height if power["shoe"] > 0.0 else tune.jump_height
		if power["pole"] > 0.0: # the kəndirbaz's pole: every jump is a great leap, when the player wants it
			hgt = maxf(hgt, tune.pole_height)
		vy = sqrt(2.0 * tune.gravity * hgt)
		grounded = false
		jump_buf = 0.0
		slide_t = 0.0
		air_t = 1.0
		jumped.emit()
	jump_buf = maxf(0.0, jump_buf - dt)
	var flying := is_flying()
	if flying: # the Simurq or the carpet holds him high; the street passes below
		y += (tune.simurq_height - y) * minf(1.0, dt * 2.5)
		vy = 0.0
		grounded = false
		slide_t = 0.0
		if maxf(power["simurq"], power["fly"]) <= dt: # a safe landing
			invuln = maxf(invuln, 1.6)
			landed_from_flight.emit()
	else:
		vy -= tune.gravity * dt
		y += vy * dt
	var sup := _support_at(x, prev_y, s)
	if flying:
		pass
	elif y <= sup.x:
		y = sup.x
		vy = 0.0
		grounded = true
		on_roof = _roof_kind
		if _roof_obj != null and _roof_obj.moving: # someone climbed on: the camels stop to look
			_roof_obj.moving = false
	else:
		grounded = y - sup.x < 0.05 and vy <= 0.0
	slide_t = maxf(0.0, slide_t - dt)
	if not flying:
		_collide()
	if dead != "":
		return
	for o in obstacles: # caravans walk toward you
		o.prev_s0 = o.s0
		if o.moving:
			o.s0 -= tune.caravan_speed * dt
	_dt = dt
	_take_pickups()
	for o in obstacles:
		if not o.passed and not o.hit and not o.cleared and not o.ramp and s - PDEPTH > o.s1():
			o.passed = true
			if o.lane == lane and not flying: # flown over by the Simurq or the carpet: not a jump or a slide
				passed.emit(o.kind)
	# the Div
	if div_t > 0.0 and div_t <= dt:
		escaped.emit()
	div_t = maxf(0.0, div_t - dt)
	stumble_t = maxf(0.0, stumble_t - dt)
	intro_t = maxf(0.0, intro_t - dt)
	invuln = maxf(0.0, invuln - dt)
	if not flying: # the shield waits while he flies (nothing can hit him up there)
		carpet_t = maxf(0.0, carpet_t - dt)
	for k in POWERS:
		power[k] = maxf(0.0, power[k] - dt)
	var want := tune.div_near_gap if div_t > 0.0 or intro_t > 0.0 else tune.div_far_gap
	var rate := 3.0 if want < div_gap else 0.8
	div_gap += (want - div_gap) * minf(1.0, dt * rate)
	# score
	mult = base_mult + mini(tune.mult_cap - 1, int(s / tune.mult_every))
	score += speed * dt * mult * (2.0 if power["double"] > 0.0 else 1.0)
	_forget_behind()


var _roof_kind := ""
var _roof_obj: Obstacle
var _dt := 0.0

## The ground under Cırtdan (x = height): the street, a ramp, a cart roof or the camels' backs.
func _support_at(px: float, py: float, ps: float) -> Vector2:
	var g := 0.0
	_roof_kind = ""
	_roof_obj = null
	for o in obstacles:
		if not (o.ramp or o.roof) or o.cleared:
			continue
		if absf(px - lane_x(o.lane)) > o.half + PHALF * 0.5:
			continue
		if ps + PDEPTH < o.s0 or ps - PDEPTH > o.s1():
			continue
		var h := o.top
		if o.ramp:
			h = clampf((ps - o.s0) / o.length, 0.0, 1.0) * o.top
		var tol := 0.6 if o.ramp else 0.35
		if py >= h - tol and h > g:
			g = h
			_roof_kind = "" if o.ramp else o.kind
			_roof_obj = null if o.ramp else o
	return Vector2(g, 0.0)


func _overlaps(o: Obstacle, ox_s0: float, px: float, py: float, h: float, ps: float) -> bool:
	return absf(px - lane_x(o.lane)) < o.half + PHALF and ps + PDEPTH > ox_s0 and ps - PDEPTH < ox_s0 + o.length \
		and py < o.top and py + h > o.bottom


func _collide() -> void:
	var h := PSLIDE if slide_t > 0.0 else PSTAND
	for o in obstacles:
		if o.hit or o.ramp or o.cleared:
			continue
		if o.roof and y >= o.top - 0.35:
			continue # on its roof
		if not _overlaps(o, o.s0, x, y, h, s):
			continue
		if power["pole"] > 0.0 and prev_y >= o.top - 0.15: # a kəndirbaz lands on it and springs off
			y = o.top
			vy = sqrt(2.0 * tune.gravity * tune.pole_height)
			continue
		var from_front := not _overlaps(o, o.prev_s0, x, y, h, prev_s) and absf(prev_x - lane_x(o.lane)) < o.half + PHALF
		if from_front:
			if o.frontal == "crash":
				_crash(o)
			else:
				_stumble(o)
		elif absf(prev_x - lane_x(lane)) > 0.05: # a side bump during a lane change: back where he came from
			lane = prev_lane
			x = prev_x
			_stumble(o)
		else:
			_stumble(o) # landing on it or rising into it: a stumble where he is
		if dead != "":
			return


func _stumble(o: Obstacle) -> void:
	if o != null:
		o.hit = true
	if invuln > 0.0:
		return
	if _shield(o):
		return
	if div_t > 0.0 and stumble_t <= 0.0:
		dead = "caught"
		caught.emit()
		return
	if stumble_t > 0.0:
		return
	div_t = tune.div_near_time
	stumble_t = 0.6
	stumbled.emit()


func _crash(o: Obstacle) -> void:
	if invuln > 0.0:
		o.hit = true
		return
	if _shield(o):
		return
	o.hit = true
	dead = "crash"
	crashed.emit(o.kind)


func _shield(o: Obstacle) -> bool: # the flying carpet takes one hit and the thing is gone
	if carpet_t <= 0.0:
		return false
	carpet_t = 0.0
	invuln = 1.0
	if o != null:
		o.hit = true
		o.cleared = true
	shield_used.emit()
	return true


func _take_pickups() -> void:
	var h := PSLIDE if slide_t > 0.0 else PSTAND
	var flying := is_flying()
	for p in pickups:
		if p.taken:
			continue
		if (p.kind == "bread" or p.kind == "treat") and (power["magnet"] > 0.0 or (flying and p.y > 3.0)): # the tray, or the sky line in flight
			var ds := p.s - s
			var dxp := p.x - x
			if absf(ds) < tune.magnet_radius and absf(dxp) < tune.magnet_radius:
				var k := minf(1.0, _dt * 10.0)
				p.s -= ds * k
				p.x -= dxp * k
				p.y += (y + 0.6 - p.y) * k
		if absf(p.s - s) < 0.8 and absf(p.x - x) < 0.8 and absf(p.y - (y + h * 0.5)) < 1.0:
			p.taken = true
			if p.kind == "bread":
				bread += 1
				bread_taken.emit(bread)
			elif p.kind == "treat": # the city's own treat counts as several bread
				bread += treat_worth
				bread_taken.emit(bread)
			elif p.kind == "nar":
				nar_got += 1
				nar_taken.emit()
			elif p.kind in POWERS:
				power[p.kind] = power_time(p.kind)
				if p.kind == "simurq":
					sky_bread(power_time("simurq"))
				power_taken.emit(p.kind)
			else:
				item_taken.emit(p.kind)


## Things more than 25 m behind are dropped (the game frees their drawings first: see Game).
func _forget_behind() -> void:
	var behind := s - 25.0
	for i in range(obstacles.size() - 1, -1, -1):
		if obstacles[i].s1() < behind:
			var o := obstacles[i]
			if o.node != null:
				o.node.queue_free()
			obstacles.remove_at(i)
	for i in range(pickups.size() - 1, -1, -1):
		if pickups[i].s < behind:
			var p := pickups[i]
			if p.node != null:
				p.node.queue_free()
			pickups.remove_at(i)
