## Stand-in figures built from primitive meshes, one function per thing on the street.
## They read like the web prototype's figures; the design stage replaces them with real models and animation.
##
## Usage:
##   var runner := Figures.cirtdan()   # a Node3D; its parts are in runner.get_meta("parts")
##   add_child(runner)
class_name Figures
extends RefCounted

static var _mats := {}


## A plain coloured material, shared by every mesh of that colour.
static func mat(color: Color, emissive := false) -> StandardMaterial3D:
	var key := color.to_html() + ("e" if emissive else "")
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = color
		m.roughness = 0.85
		if emissive:
			m.emission_enabled = true
			m.emission = color
		_mats[key] = m
	return _mats[key]


static func _part(parent: Node3D, mesh: Mesh, color: Color, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(color)
	mi.position = pos
	mi.rotation = rot
	parent.add_child(mi)
	return mi


static func _box(sx: float, sy: float, sz: float) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3(sx, sy, sz)
	return b


static func _cyl(r_top: float, r_bot: float, h: float, segs := 16) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bot
	c.height = h
	c.radial_segments = segs
	return c


static func _ball(r: float, h := -1.0) -> SphereMesh:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0 if h < 0.0 else h
	sm.radial_segments = 16
	sm.rings = 10
	return sm


static func _shadow(parent: Node3D, r: float) -> void:
	var d := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = 0.01
	d.mesh = c
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.23, 0.14, 0.06, 0.32)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	d.material_override = m
	d.position.y = 0.02
	parent.add_child(d)


## Cırtdan: small, a big head, red papaq, blue patterned vest, a bread sack on his back. Faces -z.
## Parts for animation: "leg_l", "leg_r", "arm_l", "arm_r", "rig".
static func cirtdan() -> Node3D:
	var g := Node3D.new()
	var rig := Node3D.new()
	g.add_child(rig)
	var skin := Color("#f2c08f")
	var legs := []
	for sx in [-0.12, 0.12]:
		var leg := Node3D.new()
		leg.position = Vector3(sx, 0.52, 0)
		rig.add_child(leg)
		_part(leg, _cyl(0.085, 0.085, 0.4), Color("#4b3221"), Vector3(0, -0.2, 0))
		_part(leg, _box(0.16, 0.1, 0.28), Color("#7a3b16"), Vector3(0, -0.45, -0.04))
		legs.append(leg)
	_part(rig, _cyl(0.2, 0.22, 0.44), Color("#f3ecd8"), Vector3(0, 0.74, 0))
	_part(rig, _box(0.44, 0.36, 0.34), Color("#1f4f8f"), Vector3(0, 0.78, 0))
	_part(rig, _ball(0.24, 0.5), Color("#c9a46a"), Vector3(0, 0.8, 0.24)) # the sack, on his back (+z faces the camera)
	var arms := []
	for sx in [-0.27, 0.27]:
		var arm := Node3D.new()
		arm.position = Vector3(sx, 0.92, 0)
		rig.add_child(arm)
		_part(arm, _cyl(0.06, 0.06, 0.32), Color("#f3ecd8"), Vector3(0, -0.16, 0))
		_part(arm, _ball(0.07), skin, Vector3(0, -0.34, 0))
		arms.append(arm)
	_part(rig, _ball(0.3, 0.58), skin, Vector3(0, 1.32, 0))
	for sx in [-0.11, 0.11]:
		_part(rig, _ball(0.085, 0.2), Color.WHITE, Vector3(sx, 1.34, -0.24))
		_part(rig, _ball(0.045, 0.11), Color("#2a1a10"), Vector3(sx, 1.34, -0.29))
	_part(rig, _cyl(0.26, 0.26, 0.22), Color("#c8221d"), Vector3(0, 1.58, 0)) # papaq
	_part(rig, _cyl(0.27, 0.27, 0.06), Color("#7a1512"), Vector3(0, 1.47, 0))
	_shadow(g, 0.32)
	g.set_meta("parts", {"rig": rig, "leg_l": legs[0], "leg_r": legs[1], "arm_l": arms[0], "arm_r": arms[1]})
	return g


## The Div: huge, furry green, horned, a round belly and a wooden club. Comic, not scary. Faces +z
## (the game turns him to run toward -z). Parts: "leg_l", "leg_r", "arm_l", "arm_r", "rig".
static func div() -> Node3D:
	var g := Node3D.new()
	var rig := Node3D.new()
	g.add_child(rig)
	var fur := Color("#6f8a3a")
	var legs := []
	for sx in [-0.45, 0.45]:
		var leg := Node3D.new()
		leg.position = Vector3(sx, 1.0, 0)
		rig.add_child(leg)
		_part(leg, _ball(0.3, 1.1), Color("#556b2b"), Vector3(0, -0.45, 0))
		_part(leg, _box(0.6, 0.3, 0.9), Color("#3e2a17"), Vector3(0, -0.95, 0.12))
		legs.append(leg)
	_part(rig, _ball(1.0, 2.1), fur, Vector3(0, 1.9, 0))
	_part(rig, _ball(0.72, 1.5), Color("#d9c48a"), Vector3(0, 1.8, 0.42))
	_part(rig, _ball(0.6, 1.1), fur, Vector3(0, 3.1, 0.05))
	for sx in [-0.38, 0.38]:
		_part(rig, _cyl(0.0, 0.13, 0.5), Color("#f1e6c8"), Vector3(sx, 3.65, 0), Vector3(0, 0, -signf(sx) * 0.5))
	_part(rig, _ball(0.17, 0.36), Color.WHITE, Vector3(-0.2, 3.25, 0.5))
	_part(rig, _ball(0.13, 0.28), Color.WHITE, Vector3(0.2, 3.25, 0.5))
	_part(rig, _ball(0.16, 0.26), Color("#c96b4a"), Vector3(0, 3.05, 0.6))
	var arms := []
	for sx in [-0.95, 0.95]:
		var arm := Node3D.new()
		arm.position = Vector3(sx, 2.35, 0)
		rig.add_child(arm)
		_part(arm, _ball(0.24, 1.2), fur, Vector3(0, -0.5, 0))
		arms.append(arm)
	_part(arms[1], _cyl(0.07, 0.07, 0.9), Color("#7b4a22"), Vector3(0, -0.7, 0.2), Vector3(0.5, 0, 0))
	_part(arms[1], _ball(0.22, 0.64), Color("#7b4a22"), Vector3(0, -0.3, 0.42))
	_shadow(g, 0.95)
	g.set_meta("parts", {"rig": rig, "leg_l": legs[0], "leg_r": legs[1], "arm_l": arms[0], "arm_r": arms[1]})
	return g


## An obstacle's figure by kind (see RunSim.KINDS); length is along the street.
static func obstacle(kind: String, length: float) -> Node3D:
	var g := Node3D.new()
	match kind:
		"basket": # baskets, a jug, watermelons: jump it
			_part(g, _cyl(0.42, 0.38, 0.62), Color("#b07a35"), Vector3(-0.5, 0.31, 0))
			_part(g, _ball(0.3, 0.54), Color("#2f7a2e"), Vector3(0.35, 0.27, 0.18))
			_part(g, _ball(0.3, 0.54), Color("#2f7a2e"), Vector3(0.65, 0.27, -0.12))
			_part(g, _cyl(0.14, 0.3, 0.8), Color("#b65a2b"), Vector3(0.0, 0.4, -0.35))
			_shadow(g, 0.95)
		"carpet": # a carpet hung on a rope: slide under it
			for sx in [-1.05, 1.05]:
				_part(g, _cyl(0.06, 0.06, 2.9), Color("#6b4220"), Vector3(sx, 1.45, 0))
			_part(g, _cyl(0.025, 0.025, 2.1), Color("#d9c79c"), Vector3(0, 2.62, 0), Vector3(0, 0, PI / 2))
			_part(g, _box(1.8, 1.42, 0.04), Color("#b3262a"), Vector3(0, 1.9, 0))
			_part(g, _box(1.3, 0.95, 0.05), Color("#1d3f8a"), Vector3(0, 1.9, 0))
			_part(g, _box(0.5, 0.5, 0.06), Color("#e8b23a"), Vector3(0, 1.9, 0), Vector3(0, 0, PI / 4))
		"stall": # a bazaar stall: swerve round it
			for p in [Vector2(-0.8, -0.6), Vector2(0.8, -0.6), Vector2(-0.8, 0.6), Vector2(0.8, 0.6)]:
				_part(g, _cyl(0.05, 0.05, 2.4), Color("#6b4220"), Vector3(p.x, 1.2, p.y))
			_part(g, _cyl(0.0, 1.35, 0.8, 4), Color("#c8322c"), Vector3(0, 2.75, 0), Vector3(0, PI / 4, 0))
			_part(g, _box(1.8, 0.9, 1.4), Color("#8a5a2b"), Vector3(0, 0.45, 0))
			for i in 6:
				_part(g, _ball(0.12), [Color("#e2452f"), Color("#f29a2e"), Color("#9fc93c")][i % 3], Vector3(-0.5 + (i % 3) * 0.5, 1.0, -0.3 + (i / 3) * 0.4))
			_shadow(g, 1.1)
		"phaeton": # a black carriage and its horse, the horse inside the box's front: swerve
			_part(g, _box(1.5, 0.7, 2.6), Color("#2a2224"), Vector3(0, 1.0, -0.8))
			_part(g, _box(1.6, 0.1, 1.5), Color("#3b2b24"), Vector3(0, 2.35, -1.3))
			for p in [Vector2(-0.82, 0.1), Vector2(0.82, 0.1), Vector2(-0.82, -1.7), Vector2(0.82, -1.7)]:
				var w := _part(g, TorusMesh.new(), Color("#6b2a1a"), Vector3(p.x, 0.55, p.y), Vector3(0, 0, PI / 2))
				(w.mesh as TorusMesh).inner_radius = 0.42
				(w.mesh as TorusMesh).outer_radius = 0.55
			_part(g, _box(0.6, 0.7, 1.6), Color("#5b3a22"), Vector3(0, 1.15, 1.6))
			_part(g, _box(0.25, 0.8, 0.3), Color("#5b3a22"), Vector3(0, 1.7, 2.35), Vector3(0.5, 0, 0))
			for p in [Vector2(-0.17, 1.1), Vector2(0.17, 1.1), Vector2(-0.17, 2.1), Vector2(0.17, 2.1)]:
				_part(g, _cyl(0.06, 0.06, 0.9), Color("#5b3a22"), Vector3(p.x, 0.45, p.y))
		"cart": # a hay cart: run along its roof
			_part(g, _box(1.7, 0.25, length), Color("#8a5a2b"), Vector3(0, 0.75, 0))
			var z := -length * 0.5 + 0.7
			while z < length * 0.5:
				_part(g, _box(1.6, 0.68, 1.3), Color("#e2bd55"), Vector3(0, 1.24, z))
				z += 1.4
			for px in [-0.95, 0.95]:
				for pz in [-length * 0.5 + 0.9, length * 0.5 - 0.9]:
					var w := _part(g, TorusMesh.new(), Color("#6b2a1a"), Vector3(px, 0.55, pz), Vector3(0, 0, PI / 2))
					(w.mesh as TorusMesh).inner_radius = 0.42
					(w.mesh as TorusMesh).outer_radius = 0.55
		"ramp": # a plank ramp up onto the cart
			var plank := _part(g, _box(1.5, 0.12, sqrt(16.0 + 1.6 * 1.6)), Color("#a8743a"), Vector3(0, 0.8, 0))
			plank.rotation.x = atan2(1.6, 4.0)
		"caravan": # three camels walking toward you (+z)
			for i in 3:
				var c := Node3D.new()
				c.position.z = 2.4 - i * 2.4
				g.add_child(c)
				_part(c, _ball(0.45, 0.9), Color("#c99a5b"), Vector3(0, 1.45, 0))
				_part(c, _ball(0.32, 0.8), Color("#a8783e"), Vector3(0, 1.85, -0.25))
				_part(c, _box(0.9, 0.05, 0.7), Color("#b3262a"), Vector3(0, 1.8, 0.2))
				_part(c, _cyl(0.13, 0.13, 0.85), Color("#c99a5b"), Vector3(0, 1.95, 0.95), Vector3(0.55, 0, 0))
				_part(c, _ball(0.17, 0.66), Color("#c99a5b"), Vector3(0, 2.3, 1.3), Vector3(PI / 2, 0, 0))
				for p in [Vector2(-0.22, 0.6), Vector2(0.22, 0.6), Vector2(-0.22, -0.6), Vector2(0.22, -0.6)]:
					_part(c, _cyl(0.07, 0.07, 1.15), Color("#c99a5b"), Vector3(p.x, 0.6, p.y))
	return g


## A yağ çörəyi: a puffed golden round, upright so it faces the runner, spinning.
static func bread() -> Node3D:
	var g := Node3D.new()
	_part(g, _cyl(0.33, 0.33, 0.12), Color("#c27a22"), Vector3.ZERO, Vector3(PI / 2, 0, 0))
	_part(g, _ball(0.27, 0.16), Color("#f2b64a"), Vector3(0, 0, 0.06), Vector3(PI / 2, 0, 0))
	return g


## A stretch of old-Baku houses beside the street: sandstone, a balcony now and then. side is -1 or 1.
static func house(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var h := 5.0 + rng.randf() * 5.0
	var w := 5.0 + rng.randf() * 3.0
	_part(g, _box(5.0, h, w), Color("#d9a95f"), Vector3(side * 2.5, h * 0.5, 0))
	_part(g, _box(5.3, 0.4, w + 0.2), Color("#c4934f"), Vector3(side * 2.5, h + 0.2, 0))
	var floors := maxi(1, int(h / 3.0))
	for f in floors:
		var y := 1.6 + f * 3.0
		var n := maxi(1, int(w / 2.4))
		for i in n:
			var z := -w * 0.5 + (i + 0.5) * (w / n)
			_part(g, _box(0.05, 1.8, 1.2), Color("#2c6fd1") if (i + f) % 2 == 0 else Color("#d6362f"), Vector3(-side * 0.03, y + 0.3, z))
		if f >= 1 and rng.randf() < 0.6:
			_part(g, _box(1.4, 0.15, w * 0.8), Color("#7a4a22"), Vector3(-side * 0.7, y - 0.9, 0))
			if rng.randf() < 0.6:
				_part(g, _box(0.04, 2.2, 1.6), Color("#b3262a"), Vector3(-side * 1.42, y - 1.4, 0))
	return [g, w]


## A pickup's figure by kind: bread, nar, magnet (Nənə's tray), shoe (magic çarıq), double (two ovens),
## pole (the rope-walker's pole), simurq (a great feather).
static func pickup(kind: String) -> Node3D:
	if kind == "bread":
		return bread()
	var g := Node3D.new()
	match kind:
		"nar": # a red pomegranate with its crown
			_part(g, _ball(0.34, 0.62), Color("#b5162b"), Vector3.ZERO)
			for i in 5:
				var a := i / 5.0 * TAU
				_part(g, _cyl(0.0, 0.05, 0.16), Color("#7a0f1c"), Vector3(cos(a) * 0.07, 0.36, sin(a) * 0.07))
		"magnet": # a copper tray with bread on it
			_part(g, _cyl(0.42, 0.42, 0.05), Color("#cf7a38"), Vector3.ZERO, Vector3(PI / 2, 0, 0))
			_part(g, _cyl(0.25, 0.25, 0.06), Color("#a8572a"), Vector3(0, 0, 0.02), Vector3(PI / 2, 0, 0))
			for i in 3:
				_part(g, _cyl(0.1, 0.1, 0.05), Color("#e59a2f"), Vector3(-0.13 + i * 0.13, 0.03 * i, 0.07), Vector3(PI / 2, 0, 0))
		"shoe": # a leather çarıq with a turned-up toe and gold sparks
			_part(g, _ball(0.2, 0.3), Color("#8a4a1c"), Vector3.ZERO, Vector3(0, 0, 0))
			_part(g, _cyl(0.0, 0.08, 0.3), Color("#8a4a1c"), Vector3(0, 0.12, -0.36), Vector3(-0.9, 0, 0))
			for p in [Vector3(-0.32, 0.25, 0), Vector3(0.3, 0.1, 0), Vector3(0, 0.4, 0)]:
				_part(g, _cyl(0.0, 0.05, 0.16), Color("#ffd34a"), p)
		"double": # two clay ovens with glowing mouths
			for sx in [-0.22, 0.22]:
				_part(g, _ball(0.24, 0.64), Color("#b8743e"), Vector3(sx, 0, 0))
				var f := _part(g, _ball(0.09, 0.14), Color("#ffb43a"), Vector3(sx, 0, 0.22))
				f.material_override = mat(Color("#ff8a1a"), true)
		"pole": # the balancing pole, weights at both ends
			_part(g, _cyl(0.035, 0.035, 1.2), Color("#c48a3e"), Vector3.ZERO, Vector3(0, 0, PI / 2))
			for sx in [-0.6, 0.6]:
				_part(g, _ball(0.1), Color("#c8322c"), Vector3(sx, 0, 0))
		"simurq": # one great tail feather
			_part(g, _cyl(0.02, 0.02, 1.0), Color("#f5e6c0"), Vector3.ZERO)
			_part(g, _ball(0.2, 0.84), Color("#1f9e9a"), Vector3(0, 0.18, 0))
			_part(g, _ball(0.12, 0.5), Color("#f2b632"), Vector3(0, 0.26, 0.02))
			_part(g, _ball(0.07, 0.18), Color("#2c4fa0"), Vector3(0, 0.3, 0.05))
	return g


## The Simurq: the fairy-tale bird, gold and turquoise, wings out, a long tail. Faces -z.
## Parts: "wings" (two Node3D to flap).
static func simurq() -> Node3D:
	var g := Node3D.new()
	_part(g, _ball(0.55, 1.8), Color("#f2b632"), Vector3.ZERO, Vector3(PI / 2, 0, 0))
	_part(g, _ball(0.3, 0.6), Color("#f2b632"), Vector3(0, 0.5, -1.0))
	_part(g, _cyl(0.0, 0.09, 0.35), Color("#e07b22"), Vector3(0, 0.45, -1.4), Vector3(-PI / 2, 0, 0))
	var wings := []
	for sd in [-1, 1]:
		var w := Node3D.new()
		w.position = Vector3(sd * 0.45, 0.15, 0)
		g.add_child(w)
		for i in 3:
			_part(w, _box(1.5 - i * 0.25, 0.06, 0.35), [Color("#1f9e9a"), Color("#f2b632"), Color("#c8322c")][i], Vector3(sd * (0.75 - i * 0.1), 0, -0.25 + i * 0.25))
		wings.append(w)
	for i in 5:
		_part(g, _box(0.18, 0.04, 1.9), [Color("#1f9e9a"), Color("#c8322c"), Color("#f2b632"), Color("#c8322c"), Color("#1f9e9a")][i], Vector3((i - 2) * 0.2, 0.05, 1.6), Vector3(0.15, (i - 2) * 0.12, 0))
	g.set_meta("parts", {"wings": wings})
	return g


## The flying carpet under Cırtdan: a green carpet with a red border and a gold medallion.
static func flying_carpet() -> Node3D:
	var g := Node3D.new()
	_part(g, _box(1.4, 0.05, 1.9), Color("#9e1f24"), Vector3.ZERO)
	_part(g, _box(1.15, 0.06, 1.6), Color("#2b7a48"), Vector3.ZERO)
	_part(g, _box(0.5, 0.07, 0.5), Color("#f2d16b"), Vector3.ZERO, Vector3(0, PI / 4, 0))
	return g
