## The world the run is drawn in: sky, light and haze, the street with its kerbs and lane grooves, the
## city's horizon, the houses (and now and then a qala gate) streaming along both sides, and the drawings of
## RunSim's obstacles and pickups, alive (wheels turn, camels walk, carpets sway, mud bubbles).
## One city at a time: set_city() changes everything to that city's look.
##
## Usage:
##   var world := World.new(tune); add_child(world)
##   world.set_city("sheki"); world.reset(seed)
##   world.update(sim, s, anim_t)   # every frame, with the interpolated distance
class_name World
extends Node3D

const GATE_CITIES := ["baku", "sheki", "naxcivan"]
const BEHIND := 25.0

var tune: Tuning
var city := "baku"
var env: Environment
var sky_mat: ProceduralSkyMaterial
var sun: DirectionalLight3D
var street: MeshInstance3D
var _follow: Array[Node3D] = [] ## pieces that move with the runner (street, kerbs, grooves)
var _back: Node3D
var _houses: Array = [] ## [node, far end s]
var _house_next := {-1: -20.0, 1: -20.0}
var _gates: Array = [] ## [node, s]
var _gate_next := 300.0
var _rng := RandomNumberGenerator.new()
var _obj_rng := RandomNumberGenerator.new()
var _street_mat: StandardMaterial3D
var _rain: CPUParticles3D
var letter_text: Callable ## returns the next letter of the day's word (for a letter tile's face)


func _init(tuning: Tuning) -> void:
	tune = tuning


func _ready() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#3d8fd6")
	sky_mat.sky_horizon_color = Color("#f6dfae")
	sky_mat.ground_horizon_color = Color("#f3d6a4")
	sky_mat.ground_bottom_color = Color("#c98a4a")
	sky_mat.sun_angle_max = 20.0
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.65
	env.fog_enabled = true
	env.fog_density = 0.0045
	env.fog_sky_affect = 0.0
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_hdr_threshold = 1.2
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.08
	env.adjustment_contrast = 1.08
	env.adjustment_brightness = 0.94
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.05
	sun.light_color = Color("#fff1d6")
	add_child(sun)
	street = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(8, 400)
	street.mesh = pm
	add_child(street)
	_follow.append(street)
	for s in [-1, 1]:
		var k := Kit.part(self, Kit.box(0.4, 0.2, 400), Kit.mat("#b38a55"), Vector3(s * 4.1, 0.1, 0))
		k.set_meta("curb", true)
		_follow.append(k)
		var gr := Kit.part(self, Kit.box(0.08, 0.02, 400), Kit.mat("#7d6a4f"), Vector3(s * tune.lane_width / 2.0, 0.012, 0))
		_follow.append(gr)
	_rain = CPUParticles3D.new()
	_rain.amount = 300
	_rain.lifetime = 0.8
	_rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_rain.emission_box_extents = Vector3(9, 0.5, 14)
	_rain.direction = Vector3(0, -1, 0.15)
	_rain.spread = 2.0
	_rain.initial_velocity_min = 18.0
	_rain.initial_velocity_max = 22.0
	_rain.gravity = Vector3.ZERO
	var drop := BoxMesh.new()
	drop.size = Vector3(0.02, 0.5, 0.02)
	var dm := StandardMaterial3D.new()
	dm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.albedo_color = Color(0.85, 0.92, 1.0, 0.45)
	drop.material = dm
	_rain.mesh = drop
	_rain.local_coords = false
	add_child(_rain)
	set_city(city)


## Changes the street, the horizon, the haze and the houses to a city's look.
func set_city(id: String) -> void:
	city = id
	if street == null:
		return
	var look: Dictionary = Scenery.LOOK.get(id, Scenery.LOOK["baku"])
	_street_mat = Kit.tex(look["road"], Vector2(2, 100), Color(look["tint"]))
	street.material_override = _street_mat
	for n in _follow:
		if n.has_meta("curb"):
			(n as MeshInstance3D).material_override = Kit.mat(look["curb"])
	var fog := Color(look["fog"])
	env.fog_light_color = fog
	sky_mat.sky_top_color = Color(look["sky"])
	sky_mat.sky_horizon_color = fog.lightened(0.25)
	sky_mat.ground_horizon_color = fog
	if _back != null:
		_back.queue_free()
	_back = Scenery.backdrop(id)
	add_child(_back)
	_rain.emitting = id == "lenkeran" # Lənkəran's rain
	_rain.visible = _rain.emitting
	reset(0)


## Clears the houses and gates for a new run (the street rebuilds itself ahead as it is drawn).
func reset(seed_value: int) -> void:
	for h in _houses:
		h[0].queue_free()
	_houses.clear()
	for g in _gates:
		g[0].queue_free()
	_gates.clear()
	_house_next = {-1: -60.0, 1: -60.0} # houses behind the start too: the menu camera looks back
	_rng.seed = seed_value + 17
	_obj_rng.seed = seed_value + 29
	_gate_next = 300.0 + _rng.randf() * 200.0


## Builds what is newly in view, drops what is behind, places and animates every drawing.
func update(sim: RunSim, s: float, t: float) -> void:
	_stream(s)
	for n in _follow:
		n.position.z = -s - 150.0
	if _back != null:
		_back.position = Vector3(0, 0, -s - 260.0)
		for c in _back.get_children(): # the waterfall falls
			if c.has_meta("scroll"):
				((c as MeshInstance3D).material_override as StandardMaterial3D).uv1_offset.y = -t * 0.8
	_rain.position = Vector3(0, 12, -s - 8.0)
	for o in sim.obstacles:
		if o.node == null:
			o.node = Props.obstacle(o.kind, o.length, city, _obj_rng)
			add_child(o.node)
		o.node.visible = not o.cleared
		o.node.position = Vector3(sim.lane_x(o.lane), 0, -(o.s0 + o.length * 0.5))
		_animate_obstacle(o, t)
	for p in sim.pickups:
		if p.node == null:
			var text := ""
			if p.kind == "letter" and letter_text.is_valid():
				text = letter_text.call()
			p.node = Props.pickup(p.kind, text, city)
			add_child(p.node)
		if p.taken:
			p.node.scale = p.node.scale * 0.8
			p.node.position.y += 0.1
			p.node.visible = p.node.scale.x > 0.05
		else:
			var bob := 0.0 if p.kind == "bread" else sin(t * 3.0 + p.s) * 0.12
			p.node.position = Vector3(p.x, p.y + bob, -p.s)
			p.node.rotation.y = t * 3.0 + p.s


func _animate_obstacle(o: RunSim.Obstacle, t: float) -> void:
	var n: Node3D = o.node
	if not n.has_meta("parts"):
		if o.kind == "carpet": # the hanging carpet sways a little
			for c in n.get_children():
				if c.has_meta("sway"):
					c.rotation.x = sin(t * 2.0 + o.s0) * 0.06
		return
	var parts: Dictionary = n.get_meta("parts")
	if parts.has("camels") and o.moving: # they stand still once Cırtdan climbs on
		var i := 0
		for c in parts["camels"]:
			var cp: Dictionary = c.get_meta("parts")
			var ph := t * 5.0 + i * 1.3
			var legs: Array = cp["legs"]
			for k in 4:
				legs[k].rotation.x = sin(ph + (PI if k % 2 == 0 else 0.0) + (PI if k >= 2 else 0.0)) * 0.35
			cp["rig"].position.y = absf(sin(ph)) * 0.06
			cp["head"].rotation.x = sin(ph * 0.5) * 0.12
			i += 1
	if parts.has("wheels"):
		for w in parts["wheels"]:
			w.rotation.x = -t * 0.8
		var hp: Dictionary = parts["horse"].get_meta("parts")
		hp["head"].rotation.x = sin(t * 2.0) * 0.08 # the horse waits, tossing its head
		hp["legs"][0].rotation.x = maxf(0.0, sin(t * 1.3)) * 0.4
	if parts.has("bubble"):
		var b: Node3D = parts["bubble"]
		var u := fmod(t * 0.7 + o.s0, 1.0)
		b.scale = Vector3.ONE * (0.4 + u * 1.2)
		b.visible = u < 0.95


func _stream(s: float) -> void:
	var ahead := s + tune.view_ahead + 20.0
	if city in GATE_CITIES:
		while _gate_next < ahead + 10.0:
			var g := Scenery.gate()
			g.position = Vector3(0, 0, -_gate_next)
			add_child(g)
			_gates.append([g, _gate_next])
			_gate_next += 380.0 + _rng.randf() * 200.0
	for side in [-1, 1]:
		while _house_next[side] < ahead:
			var skip := false
			for gt in _gates: # the gate's walls stay clear: balconies and carpets never poke through
				if _house_next[side] < gt[1] + 4.0 and _house_next[side] + 9.0 > gt[1] - 4.0:
					_house_next[side] = gt[1] + 4.0
					skip = true
			if skip:
				continue
			var made: Array = Scenery.house(city, side, _rng)
			var node: Node3D = made[0]
			var w: float = made[1]
			node.position = Vector3(side * 4.3, 0, -(_house_next[side] + w * 0.5))
			add_child(node)
			_houses.append([node, _house_next[side] + w])
			_house_next[side] += w + (2.5 if _rng.randf() < 0.15 else 0.05)
	for i in range(_houses.size() - 1, -1, -1):
		if _houses[i][1] < s - BEHIND:
			_houses[i][0].queue_free()
			_houses.remove_at(i)
	for i in range(_gates.size() - 1, -1, -1):
		if _gates[i][1] + 3.0 < s - BEHIND:
			_gates[i][0].queue_free()
			_gates.remove_at(i)
