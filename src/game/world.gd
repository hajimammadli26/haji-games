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
var _houses: Array = [] ## [chunk node, far end s]: houses are grouped in chunks, merged once full
var _chunk: Node3D ## the chunk being filled
var _chunk_n := 0
const CHUNK_HOUSES := 4
const NEAR := 80.0 ## houses in full detail up to here; beyond, each is one simple block (art bible §8: < 300 draws)
const PICKUP_RANGE := 60.0 ## pickups appear from this far (2.7 s ahead at top speed)
const POWER_KINDS := ["magnet", "shoe", "double", "pole", "simurq"] ## pickups that pulse
const POWER_PULSE := 0.12 ## how much a power-up grows and shrinks as it breathes
const OBSTACLE_RANGE := 100.0 ## obstacles appear from this far (4.5 s ahead at top speed: time to read them)
## The flat colour of the far blocks, per city (wall colour; a hedge green or rock for the nature cities).
const FAR := {"baku": "#d9a95f", "sheki": "#e9dfcc", "naxcivan": "#b5653a", "qebele": "#3f6f3f",
	"lenkeran": "#4f8a44", "quba": "#5a8a46", "qobustan": "#8a7560"}
## The roof band on top of a far block (cities with roofs you see from afar).
const FAR_ROOF := {"baku": "#b88a4a", "sheki": "#a8432c", "naxcivan": "#8a4e32"}
## The windows' dark slots on a far block's street face (cities of houses).
const FAR_WINDOW := {"baku": "#6a4a2a", "sheki": "#5a4a3a", "naxcivan": "#5a3a2a"}
var _house_next := {-1: -20.0, 1: -20.0}
var _gates: Array = [] ## [node, s]
var _gate_next := 300.0
var _rng := RandomNumberGenerator.new()
var _obj_rng := RandomNumberGenerator.new()
var _street_mat: StandardMaterial3D
var _rain: CPUParticles3D
var _sky: Node3D ## clouds and birds, far off, travelling with the runner
var _clouds: Array[Node3D] = [] ## the cloud band and its copy, 320 m apart
var _cloud_mat: StandardMaterial3D ## the clouds' own fogless material, tinted per city
var _birds: Array[Node3D] = []
var letter_text: Callable ## returns the next letter of the day's word (for a letter tile's face)
## Pickups sit on the street, not in the air: every bread draws through one MultiMesh, every pickup's soft blob
## shadow through another, and power-ups get a turquoise glow ring on the ground (one more): three draws for
## however many there are (art bible §8: bread draws as one batch).
const MM_MAX := 160
const BREAD_HOP := 0.09 ## m a bread rises at the top of its little hop
const ITEM_HOP := 0.14 ## m any other pickup rises
const HOP_RATE := 3.4 ## hops' speed (rad/s of the sine)
const SQUASH := 0.12 ## how much a pickup flattens at the bottom of its hop
const SHADOW_FADE := 4.5 ## m above its ground at which a pickup's shadow has faded out
const SHADOW_ALPHA := 0.85
const TURQ := Color("#19b3a6")
var _bread_mm: MultiMeshInstance3D
var _shadow_mm: MultiMeshInstance3D
var _glow_mm: MultiMeshInstance3D
var _contact: MeshInstance3D ## soft contact shade along both kerbs, where the walls meet the street


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
	env.glow_enabled = not (OS.has_feature("web") or OS.has_feature("mobile")) # costly on phones and in browsers
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
	_build_sky()
	_build_pickup_batches()
	_contact = MeshInstance3D.new()
	_contact.mesh = _contact_mesh()
	_contact.material_override = _shade_mat(false)
	_contact.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_contact)
	_follow.append(_contact)
	set_city(city)


## The kerbs' contact shade: a dark band on each kerb's top darkest at the wall, and a fainter one on the road
## beside the kerb (vertex alpha fades out away from the wall): one mesh, one draw.
func _contact_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for sd in [-1.0, 1.0]:
		for band in [[4.3, 3.9, 0.205, 0.6, 0.18], [3.9, 3.3, 0.016, 0.4, 0.0]]: # [x wall side, x far, y, alpha in, out]
			var x0: float = band[0] * sd
			var x1: float = band[1] * sd
			var y: float = band[2]
			var c0 := Color(1, 1, 1, band[3])
			var c1 := Color(1, 1, 1, band[4])
			var q := [[x0, -200.0, c0], [x1, -200.0, c1], [x1, 200.0, c1], [x0, -200.0, c0], [x1, 200.0, c1], [x0, 200.0, c0]]
			if sd < 0.0:
				q = [q[0], q[2], q[1], q[3], q[5], q[4]]
			for v in q:
				st.set_color(v[2])
				st.set_normal(Vector3.UP)
				st.add_vertex(Vector3(v[0], y, v[1]))
	return st.commit()


## An unshaded see-through shade, its colour and alpha from the vertices (or the MultiMesh instances).
func _shade_mat(textured: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.albedo_color = Color(0.23, 0.14, 0.06) # warm Ink-brown shade, never black (art bible §4)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.disable_receive_shadows = true
	if textured:
		m.albedo_texture = _radial([0.0, 1.0], [Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	return m


func _radial(offs: Array, cols: Array) -> GradientTexture2D:
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array(offs)
	gr.colors = PackedColorArray(cols)
	var g := GradientTexture2D.new()
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(1.0, 0.5)
	g.gradient = gr
	g.width = 64
	g.height = 64
	return g


func _mm(mesh: Mesh, material: Material, colors: bool) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = colors
	mm.mesh = mesh
	mm.instance_count = MM_MAX
	mm.visible_instance_count = 0
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.custom_aabb = AABB(Vector3(-60, -5, -100000), Vector3(120, 80, 200000)) # it travels with the street
	add_child(mi)
	return mi


func _build_pickup_batches() -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	quad.orientation = PlaneMesh.FACE_Y
	_shadow_mm = _mm(quad, _shade_mat(true), true)
	var gm := StandardMaterial3D.new()
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	gm.vertex_color_use_as_albedo = true
	gm.cull_mode = BaseMaterial3D.CULL_DISABLED
	gm.albedo_texture = _radial([0.0, 0.5, 0.74, 0.86, 1.0], [Color(1, 1, 1, 0), Color(1, 1, 1, 0.12), Color(1, 1, 1, 1),
		Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)]) # a ring of light round a faint centre
	_glow_mm = _mm(quad, gm, true)


## A bread's drawing joins the bread MultiMesh: its node stays (position, scale and visibility live there, and the
## game frees it as before) but its mesh is drawn by the batch.
func _adopt_bread(node: Node3D) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			if _bread_mm == null:
				_bread_mm = _mm((c as MeshInstance3D).mesh, (c as MeshInstance3D).material_override, false)
			node.remove_child(c)
			c.queue_free()


## Where a pickup's shadow falls: the street (0), a cart roof or ramp under it, or -1 for none (a bread line
## over a barrier would otherwise throw its shadow on the road far below).
func _ground_under(sim: RunSim, p: RunSim.Pickup) -> float:
	var g := 0.0
	for o in sim.obstacles:
		if o.cleared or absf(p.x - sim.lane_x(o.lane)) > o.half + 0.2:
			continue
		if p.s < o.s0 - 0.3 or p.s > o.s1() + 0.3:
			continue
		var top := o.top
		if o.ramp:
			top = clampf((p.s - o.s0) / o.length, 0.0, 1.0) * o.top
		if top > p.y + 0.2:
			continue # it hangs over the pickup (a carpet): the shadow stays on the road
		if not (o.ramp or o.roof):
			return -1.0
		g = maxf(g, top)
	return g


func _build_sky() -> void:
	_sky = Node3D.new()
	add_child(_sky)
	_cloud_mat = Kit.mat("#ffffff").duplicate()
	_cloud_mat.disable_fog = true
	var white := _cloud_mat
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var band := Kit.joint(_sky) # the clouds as one band, drawn twice side by side so it scrolls without a seam
	for i in 10: # puffy clouds: a few balls each
		var c := Kit.joint(band, Vector3(-160.0 + i * 32.0 + rng.randf() * 10.0, 40.0 + rng.randf() * 14.0, -190.0 - rng.randf() * 130.0))
		for k in 4 + rng.randi() % 3:
			var m := Kit.part(c, Kit.ball(4.0 + rng.randf() * 4.0, -1.0, 10), white, Vector3(k * 5.0 - 10.0, rng.randf() * 2.5, rng.randf() * 3.0))
			m.scale.y = 0.6
	Kit.merge(band) # all clouds, one draw (two with the copy), instead of one draw per cloud
	var copy := band.duplicate()
	_sky.add_child(copy)
	_clouds = [band, copy]
	for i in 4: # birds: two flapping wings
		var b := Kit.joint(_sky)
		for sd in [-1.0, 1.0]:
			var wing := Kit.joint(b)
			Kit.part(wing, Kit.box(0.9, 0.05, 0.3), Kit.mat("#3a2a24"), Vector3(sd * 0.45, 0, 0))
		_birds.append(b)


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
	sky_mat.sky_horizon_color = Color(look.get("hz", fog.lightened(0.25)))
	sky_mat.sky_curve = 0.12 # a longer, softer fall from the top colour to the warm horizon
	sky_mat.ground_horizon_color = fog
	sun.light_color = Color(look.get("sun", "#fff1d6"))
	sun.light_energy = float(look.get("sun_e", 1.05))
	_cloud_mat.albedo_color = Color(look.get("cloud", "#ffffff"))
	if _back != null:
		_back.queue_free()
	_back = Scenery.backdrop(id) # already merged (and fogless) inside
	add_child(_back)
	_rain.emitting = id == "lenkeran" # Lənkəran's rain
	_rain.visible = _rain.emitting
	reset(0)


## Clears the houses and gates for a new run (the street rebuilds itself ahead as it is drawn).
func reset(seed_value: int) -> void:
	for h in _houses:
		h[0].queue_free()
	_houses.clear()
	_chunk = null
	_chunk_n = 0
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
	_sky.position = Vector3(0, 0, -s)
	var off := fposmod(t * 1.2, 320.0) # the band drifts; its copy follows 320 m behind
	_clouds[0].position.x = off
	_clouds[1].position.x = off - 320.0
	for i in _birds.size(): # birds circling high over the street
		var b := _birds[i]
		var a := t * (0.35 + i * 0.05) + i * 2.0
		b.position = Vector3(cos(a) * (14.0 + i * 3.0), 26.0 + sin(t * 0.7 + i) * 2.0, -60.0 - i * 15.0 + sin(a) * 10.0)
		b.rotation.y = -a
		var flap := sin(t * 9.0 + i) * 0.6
		b.get_child(0).rotation.z = flap
		b.get_child(1).rotation.z = -flap
	for o in sim.obstacles:
		if o.node == null:
			o.node = Props.obstacle(o.kind, o.length, city, _obj_rng)
			if o.node.has_meta("parts"): # moving things (camels, a phaeton): each joint's pieces as one
				Kit.merge_joints(o.node)
			else: # still things draw as one mesh per material
				Kit.merge(o.node)
			_ranges(o.node, 0.0, OBSTACLE_RANGE)
			add_child(o.node)
		o.node.visible = not o.cleared
		o.node.position = Vector3(sim.lane_x(o.lane), 0, -(o.s0 + o.length * 0.5))
		_animate_obstacle(o, t)
	var cam := get_viewport().get_camera_3d()
	var nb := 0
	var ns := 0
	var ng := 0
	for p in sim.pickups:
		if p.node == null:
			var text := ""
			if p.kind == "letter" and letter_text.is_valid():
				text = letter_text.call()
			p.node = Props.pickup(p.kind, text, city)
			_ranges(p.node, 0.0, PICKUP_RANGE)
			p.node.set_meta("base", p.node.scale)
			if p.kind == "bread":
				_adopt_bread(p.node)
			add_child(p.node)
		if p.taken:
			p.node.scale = p.node.scale * 0.8
			p.node.position.y += 0.1
			p.node.visible = p.node.scale.x > 0.05
		else: # a little hop, the line rippling along, flattening a touch where it lands
			var hop := absf(sin(t * HOP_RATE + p.s * 0.45))
			var squash := pow(1.0 - hop, 6.0)
			p.node.position = Vector3(p.x, p.y + hop * (BREAD_HOP if p.kind == "bread" else ITEM_HOP), -p.s)
			p.node.rotation.y = t * 3.0 + p.s
			var sc: Vector3 = p.node.get_meta("base")
			if p.kind in POWER_KINDS: # power-ups breathe so they read as magic
				sc *= 1.0 + sin(t * 5.0 + p.s) * POWER_PULSE
			p.node.scale = sc * Vector3(1.0 + squash * SQUASH * 0.6, 1.0 - squash * SQUASH, 1.0 + squash * SQUASH * 0.6)
		var near := p.node.visible and cam != null and cam.global_position.distance_to(p.node.global_position) < PICKUP_RANGE
		if not near:
			continue
		if p.kind == "bread" and _bread_mm != null and nb < MM_MAX:
			_bread_mm.multimesh.set_instance_transform(nb, p.node.transform)
			nb += 1
		if p.taken or ns >= MM_MAX:
			continue
		var gy := _ground_under(sim, p)
		var hgt := p.node.position.y - gy
		if gy < 0.0 or hgt > SHADOW_FADE:
			continue
		var k := 1.0 - hgt / SHADOW_FADE # nearer the ground: a tighter, darker shadow
		var land := pow(1.0 - absf(sin(t * HOP_RATE + p.s * 0.45)), 3.0)
		var power: bool = p.kind in POWER_KINDS
		var r := (0.55 if power else 0.4) * (1.15 - 0.3 * k) * (1.0 + land * 0.1)
		var at := Vector3(p.x, gy + 0.03, -p.s)
		_shadow_mm.multimesh.set_instance_transform(ns, Transform3D(Basis.from_scale(Vector3(r, 1, r)), at))
		_shadow_mm.multimesh.set_instance_color(ns, Color(1, 1, 1, SHADOW_ALPHA * k * (0.85 + land * 0.15)))
		ns += 1
		if power and ng < MM_MAX: # the power-up's glow ring, breathing with it
			var gr := 0.95 * (1.0 + sin(t * 5.0 + p.s) * 0.08)
			_glow_mm.multimesh.set_instance_transform(ng, Transform3D(Basis.from_scale(Vector3(gr, 1, gr)), at + Vector3(0, 0.01, 0)))
			_glow_mm.multimesh.set_instance_color(ng, Color(TURQ, 0.55 + sin(t * 5.0 + p.s) * 0.2))
			ng += 1
	if _bread_mm != null:
		_bread_mm.multimesh.visible_instance_count = nb
		_bread_mm.visible = nb > 0
	_shadow_mm.multimesh.visible_instance_count = ns
	_shadow_mm.visible = ns > 0
	_glow_mm.multimesh.visible_instance_count = ng
	_glow_mm.visible = ng > 0


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


## Sets a visibility range on every mesh under n (0 = no limit on that side).
func _ranges(n: Node, begin: float, end: float) -> void:
	for c in n.get_children():
		_ranges(c, begin, end)
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).visibility_range_begin = begin
		(n as GeometryInstance3D).visibility_range_end = end


## One simple block standing in for a house far away: its size and flat city colour, with the near houses'
## silhouette kept (Baku's merlons, Şəki's pitched red roof, Naxçıvan's turquoise band) and their windows as dark
## slots on the street face. All plain colours: merged per chunk they stay one draw.
func _far_block(house: Node3D, far_node: Node3D) -> void:
	var box := AABB()
	var first := true
	for c in house.get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).mesh != null:
			var b: AABB = (c as MeshInstance3D).transform * (c as MeshInstance3D).mesh.get_aabb()
			box = b if first else box.merge(b)
			first = false
	if first:
		return
	var size := box.size
	size.y = minf(size.y, 10.0)
	var side := -1.0 if house.position.x < 0.0 else 1.0
	var mi := _far_part(far_node, Kit.box(size.x, size.y, size.z), FAR.get(city, "#d9a95f"),
		house.position + box.position + Vector3(box.size.x, size.y, box.size.z) * 0.5)
	var c := mi.position
	var top := c.y + size.y * 0.5
	var face := c.x - side * size.x * 0.5 # the street-facing side
	if FAR_WINDOW.has(city):
		var n := maxi(1, int(size.z / 2.4))
		for f in int((size.y - 0.8) / 3.0):
			for i in n:
				var z := c.z - size.z * 0.5 + (i + 0.5) * size.z / n
				_far_part(far_node, Kit.box(0.08, 1.5, 1.0), FAR_WINDOW[city], Vector3(face - side * 0.03, 1.9 + f * 3.0, z))
	match city:
		"baku":
			_far_part(far_node, Kit.box(size.x + 0.3, 0.45, size.z + 0.2), FAR_ROOF[city], Vector3(c.x, top + 0.22, c.z))
			var m := 0.5
			while m < size.z: # the parapet's merlons along the street edge
				_far_part(far_node, Kit.box(0.5, 0.6, 0.55), FAR_ROOF[city], Vector3(face + side * 0.3, top + 0.7, c.z - size.z * 0.5 + m))
				m += 1.1
		"sheki":
			_far_part(far_node, Kit.prism(size.x + 1.0, 2.0, size.z + 0.8), FAR_ROOF[city], Vector3(c.x, top + 1.0, c.z))
		_:
			if FAR_ROOF.has(city):
				_far_part(far_node, Kit.box(size.x + 0.3, 0.7, size.z + 0.3), FAR_ROOF[city], Vector3(c.x, top + 0.35, c.z))
			if city == "naxcivan":
				_far_part(far_node, Kit.box(0.1, 0.45, size.z), "#4f9a94", Vector3(face - side * 0.05, top - 0.5, c.z))


func _far_part(far_node: Node3D, mesh: Mesh, col: String, pos: Vector3) -> MeshInstance3D:
	var mi := Kit.part(far_node, mesh, Kit.mat(col), pos)
	mi.set_meta("no_ink", true)
	_ranges(mi, NEAR - 4.0, 0.0)
	return mi


func _stream(s: float) -> void:
	var ahead := s + tune.view_ahead + 20.0
	if city in GATE_CITIES:
		while _gate_next < ahead + 10.0:
			var g := Scenery.gate()
			g.position = Vector3(0, 0, -_gate_next)
			Kit.merge(g)
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
			Kit.merge(node)
			if _chunk == null: # a chunk sits where it starts, so distances to it are measured from there
				_chunk = Node3D.new()
				_chunk.position = Vector3(0, 0, -_house_next[side])
				add_child(_chunk)
				_chunk.add_child(Node3D.new()) # 0: near detail
				_chunk.add_child(Node3D.new()) # 1: far blocks
				_houses.append([_chunk, 0.0])
				_chunk_n = 0
			node.position = Vector3(side * 4.3, 0, -(_house_next[side] + w * 0.5)) - _chunk.position
			var near_node: Node3D = _chunk.get_child(0)
			var far_node: Node3D = _chunk.get_child(1)
			near_node.add_child(node)
			_far_block(node, far_node)
			_ranges(node, 0.0, NEAR)
			_houses[-1][1] = maxf(_houses[-1][1], _house_next[side] + w)
			_chunk_n += 1
			if _chunk_n >= CHUNK_HOUSES: # a full chunk: one mesh per material near, one mesh of blocks far
				Kit.merge(near_node)
				Kit.merge(far_node)
				_ranges(near_node, 0.0, NEAR)
				_ranges(far_node, NEAR - 4.0, 0.0)
				_chunk = null
			_house_next[side] += w + (2.5 if _rng.randf() < 0.15 else 0.05)
	for i in range(_houses.size() - 1, -1, -1):
		if _houses[i][1] < s - BEHIND and _houses[i][0] != _chunk:
			_houses[i][0].queue_free()
			_houses.remove_at(i)
	for i in range(_gates.size() - 1, -1, -1):
		if _gates[i][1] + 3.0 < s - BEHIND:
			_gates[i][0].queue_free()
			_gates.remove_at(i)
