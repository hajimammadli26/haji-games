## What lines the street and fills the horizon, city by city: old Baku's sandstone houses with eyvans,
## şəbəkə windows and hanging carpets; Şəki's whitewashed houses with red roofs and the Xan sarayı; Qəbələ's
## forest and waterfall; Naxçıvan's brick houses and Möminə Xatın; Lənkəran's tea fields and lighthouse;
## Quba's orchards and Şahdağ; Qobustan's carved rocks, mud volcanoes and the Caspian. Plus the qala gate
## and Qız Qalası. Spec: the web prototype's makeHouse* / make*Back / makeGate / makeTower.
##
## Usage:
##   var made := Scenery.house("sheki", -1, rng)   # [node, width along the street]; the node's x = 0 is the kerb
##   var back := Scenery.backdrop("baku")           # far away, place it at the end of the street
class_name Scenery
extends RefCounted

## Each city's street look: road texture, its tint, kerb colour, haze.
const LOOK := {
	"baku": {"road": "cobble_grey", "tint": "#ffffff", "curb": "#b38a55", "fog": "#f3d6a4", "sky": "#3d8fd6"},
	"sheki": {"road": "cobble_grey", "tint": "#f2f2f2", "curb": "#9e3d22", "fog": "#dfe9d6", "sky": "#4a9ae0"},
	"qebele": {"road": "trail", "tint": "#ffffff", "curb": "#4f7a3a", "fog": "#cfe2d8", "sky": "#5aa8e0"},
	"naxcivan": {"road": "cobble_grey", "tint": "#f2e6dc", "curb": "#9a4e2a", "fog": "#ead2b8", "sky": "#3d8fd6"},
	"lenkeran": {"road": "cobble_grey", "tint": "#dde4e6", "curb": "#5f7a64", "fog": "#c9d6d8", "sky": "#7a9ab0"},
	"quba": {"road": "cobble_grey", "tint": "#f2f2f2", "curb": "#8a5a2b", "fog": "#dfe8e0", "sky": "#4a9ae0"},
	"qobustan": {"road": "trail", "tint": "#e0d4bc", "curb": "#a08a64", "fog": "#e8dcc4", "sky": "#4a9ae0"},
}


static func _e(p: Node3D, c: Variant, rx: float, ry: float, rz: float, pos: Vector3, rot := Vector3.ZERO, segs := 12) -> MeshInstance3D:
	return Characters._egg(p, c, rx, ry, rz, pos, rot, segs)


static func _c(p: Node3D, c: Variant, r: float, h: float, pos: Vector3, rot := Vector3.ZERO, r_top := -1.0) -> MeshInstance3D:
	return Characters._cyl(p, c, r, h, pos, rot, r_top)


static func _b(p: Node3D, c: Variant, sx: float, sy: float, sz: float, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	return Characters._box(p, c, sx, sy, sz, pos, rot)


## A window or carpet plane on the street-facing wall (x = face), facing the street.
static func _face(p: Node3D, side: int, mat: Material, w: float, h: float, pos: Vector3) -> MeshInstance3D:
	return Kit.part(p, Kit.plane(w, h), mat, pos, Vector3(0, -PI / 2 if side > 0 else PI / 2, 0))


## One stretch beside the street on a side (-1 left, 1 right) in a city's look: [node, width].
static func house(city: String, side: int, rng: RandomNumberGenerator) -> Array:
	match city:
		"sheki": return _sheki(side, rng)
		"qebele": return _forest(side, rng)
		"naxcivan": return _nax(side, rng)
		"lenkeran": return _tea(side, rng)
		"quba": return _orchard(side, rng)
		"qobustan": return _rocks(side, rng)
	return _baku(side, rng)


static func _baku(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var h := 5.0 + rng.randf() * 5.0
	var w := 5.0 + rng.randf() * 3.0
	var d := 5.0
	_b(g, Kit.tex("wall", Vector2(d / 4.0, h / 4.0) * 1.0), d, h, w, Vector3(side * d / 2.0, h / 2.0, 0))
	_b(g, "#c4934f", d + 0.3, 0.4, w + 0.2, Vector3(side * d / 2.0, h + 0.2, 0))
	_b(g, "#b07a3a", 0.3, 0.25, w + 0.2, Vector3(-side * 0.1, 0.12, 0)) # a stone plinth
	var face := -side * 0.02
	var floors := maxi(1, int(h / 3.0))
	for f in floors:
		var y := 1.6 + f * 3.0
		var n := maxi(1, int(w / 2.4))
		for i in n:
			var z := -w / 2.0 + (i + 0.5) * (w / n)
			_face(g, side, Kit.tex("shebeke"), 1.2, 1.8, Vector3(face, y + 0.3, z))
			_b(g, "#8a5a2b", 0.12, 0.1, 1.4, Vector3(-side * 0.06, y - 0.65, z)) # sill
		if f >= 1 and rng.randf() < 0.6: # a wooden eyvan, sometimes with a carpet over its rail
			var bx := -side * 0.7
			_b(g, Kit.tex("wood"), 1.4, 0.15, w * 0.8, Vector3(bx, y - 0.9, 0))
			_b(g, "#5e3618", 0.1, 0.7, w * 0.8, Vector3(bx * 2.0, y - 0.5, 0))
			for k in 3: # brackets under it
				_b(g, "#5e3618", 1.2, 0.12, 0.12, Vector3(bx, y - 1.1, -w * 0.3 + k * w * 0.3), Vector3(0, 0, side * 0.5))
			if rng.randf() < 0.6:
				var c := _face(g, side, Kit.tex(Props.CARPETS[rng.randi() % 3], Vector2.ONE, Color.WHITE, true), 1.6, 2.2, Vector3(bx * 2.0 - side * 0.06, y - 1.4, 0))
				c.set_meta("no_ink", true)
	if rng.randf() < 0.5: # a shop door with an arch on the ground floor
		var dz := (rng.randf() - 0.5) * (w - 2.0)
		_face(g, side, Kit.mat("#4a2a14"), 1.4, 2.2, Vector3(face - side * 0.01, 1.1, dz))
		_c(g, "#4a2a14", 0.7, 0.02, Vector3(face - side * 0.01, 2.2, dz), Vector3(0, 0, PI / 2))
		if rng.randf() < 0.5: # a copper pot hanging by the door
			_c(g, "#c46a2c", 0.16, 0.22, Vector3(-side * 0.35, 2.5, dz + 1.0), Vector3.ZERO, 0.2)
	if rng.randf() < 0.18:
		_e(g, "#c7a06c", 1.6, 1.3, 1.6, Vector3(side * d / 2.0, h + 0.3, 0))
	_details(g, side, w, rng)
	return [g, w]


static func _sheki(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var h := 4.5 + rng.randf() * 2.5
	var w := 5.0 + rng.randf() * 3.0
	var d := 5.0
	_b(g, Kit.tex("sheki_wall", Vector2(d / 4.0, h / 4.0)), d, h, w, Vector3(side * d / 2.0, h / 2.0, 0))
	Kit.part(g, Kit.prism(d + 1.0, 2.0, w + 0.8), Kit.tex("sheki_roof", Vector2(3, 2)), Vector3(side * d / 2.0, h + 1.0, 0))
	var face := -side * 0.02
	var n := maxi(1, int(w / 2.6))
	for i in n:
		var z := -w / 2.0 + (i + 0.5) * (w / n)
		_face(g, side, Kit.tex("shebeke"), 1.6, 2.4, Vector3(face, h - 2.0, z))
		_face(g, side, Kit.mat("#4a2a14"), 1.1, 1.9, Vector3(face, 1.0, z))
	var bx := -side * 0.8 # the deep wooden eyvan along the upper floor
	_b(g, Kit.tex("wood"), 1.6, 0.15, w * 0.9, Vector3(bx, h - 3.3, 0))
	var z := -w * 0.42
	while z <= w * 0.42:
		_c(g, "#5e3618", 0.06, 2.6, Vector3(bx * 2.0, h - 2.0, z))
		z += 1.1
	_details(g, side, w, rng)
	return [g, w]


static func _nax(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var h := 4.0 + rng.randf() * 4.0
	var w := 5.0 + rng.randf() * 3.0
	var d := 5.0
	_b(g, Kit.tex("brick", Vector2(d / 4.0, h / 4.0)), d, h, w, Vector3(side * d / 2.0, h / 2.0, 0))
	_b(g, "#9a4e2a", d + 0.2, 0.35, w + 0.2, Vector3(side * d / 2.0, h + 0.17, 0))
	var n := maxi(1, int(w / 2.2))
	for i in n:
		var z := -w / 2.0 + (i + 0.5) * (w / n)
		var y := h * 0.55
		_face(g, side, Kit.mat("#1f9e9a"), 1.0, 1.6, Vector3(-side * 0.02, y, z))
		_c(g, "#1f9e9a", 0.5, 0.6, Vector3(-side * 0.03, y + 1.05, z), Vector3(0, 0, 0), 0.0).scale = Vector3(1, 1, 0.1)
	if rng.randf() < 0.25:
		_e(g, "#1f9e9a", 1.4, 1.1, 1.4, Vector3(side * 2.5, h + 0.3, 0))
	_details(g, side, w, rng)
	return [g, w]


## Life by the doors: a copper lantern on a bracket (glowing), clay pots of flowers, now and then a cat.
static func _details(g: Node3D, side: int, w: float, rng: RandomNumberGenerator) -> void:
	if rng.randf() < 0.55:
		var z := (rng.randf() - 0.5) * (w - 1.5)
		_b(g, "#3b2414", 0.5, 0.05, 0.05, Vector3(-side * 0.25, 3.2, z))
		_c(g, "#3b2414", 0.01, 0.25, Vector3(-side * 0.48, 3.06, z))
		_c(g, "#c46a2c", 0.14, 0.32, Vector3(-side * 0.48, 2.8, z), Vector3.ZERO, 0.08)
		_e(g, Kit.mat("#ffcf6a", true), 0.09, 0.12, 0.09, Vector3(-side * 0.48, 2.78, z))
		_c(g, "#c46a2c", 0.0, 0.14, Vector3(-side * 0.48, 3.0, z), Vector3.ZERO, 0.12)
	for i in rng.randi_range(0, 3):
		var z := (rng.randf() - 0.5) * (w - 1.0)
		var px := -side * (0.35 + rng.randf() * 0.2)
		_c(g, "#b65a2b", 0.18, 0.32, Vector3(px, 0.16, z), Vector3.ZERO, 0.22)
		_e(g, "#3f8a3a", 0.24, 0.2, 0.24, Vector3(px, 0.42, z), Vector3.ZERO, 8)
		var bloom: String = ["#e2452f", "#f2b632", "#f2a6c8", "#ffffff"][rng.randi() % 4]
		for k in 3:
			_e(g, bloom, 0.05, 0.05, 0.05, Vector3(px + cos(k * 2.1) * 0.13, 0.55, z + sin(k * 2.1) * 0.13))
	if rng.randf() < 0.08: # a cat asleep on the step
		var cz := (rng.randf() - 0.5) * (w - 1.0)
		_e(g, "#d98a3a", 0.22, 0.13, 0.15, Vector3(-side * 0.4, 0.12, cz))
		_e(g, "#d98a3a", 0.1, 0.09, 0.09, Vector3(-side * 0.4, 0.2, cz + 0.2))
		for e in [-0.05, 0.05]:
			_c(g, "#d98a3a", 0.03, 0.06, Vector3(-side * 0.4 + e, 0.3, cz + 0.2), Vector3.ZERO, 0.0)


static func _pine(sc: float) -> Node3D:
	var g := Node3D.new()
	_c(g, "#6b4220", 0.14, 1.2, Vector3(0, 0.6, 0))
	var lv := [[1.3, 1.4, 1.4, "#2f6a34"], [1.0, 1.2, 2.3, "#3a7a3a"], [0.7, 1.0, 3.1, "#47894a"]]
	for l in lv:
		_c(g, l[3], l[0], l[1], Vector3(0, l[2], 0), Vector3.ZERO, 0.0)
	g.scale = Vector3.ONE * sc
	return g


static func _oak(sc: float, leaf := "#3f8a3a", fruit := "") -> Node3D:
	var g := Node3D.new()
	_c(g, "#6b4220", 0.18, 1.8, Vector3(0, 0.9, 0), Vector3.ZERO, 0.14)
	_e(g, leaf, 1.4, 1.2, 1.4, Vector3(0, 2.6, 0), Vector3.ZERO, 8)
	if fruit == "":
		_e(g, "#c8722c", 0.9, 0.8, 0.9, Vector3(0.7, 3.1, 0.3), Vector3.ZERO, 8)
	else:
		for k in 6:
			_e(g, fruit, 0.15, 0.15, 0.15, Vector3(cos(k) * 1.0, 2.3 + sin(k * 3.0) * 0.4, sin(k) * 1.0))
	g.scale = Vector3.ONE * sc
	return g


static func _forest(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var w := 5.0 + rng.randf() * 3.0
	_b(g, "#4f7a3a", 6.0, 0.3, w, Vector3(side * 3.2, 0.15, 0))
	for i in 3 + rng.randi() % 3:
		var t := _pine(0.9 + rng.randf() * 0.8) if rng.randf() < 0.6 else _oak(0.8 + rng.randf() * 0.5)
		t.position = Vector3(side * (1.2 + rng.randf() * 4.5), 0, -w / 2.0 + rng.randf() * w)
		g.add_child(t)
	if rng.randf() < 0.2: # a log hut
		var hut := Kit.joint(g, Vector3(side * 3.5, 0, 0))
		for y in 6:
			_c(hut, "#5b3a22", 0.18, 3.4, Vector3(0, 0.2 + y * 0.36, 0), Vector3(PI / 2, 0, 0))
		Kit.part(hut, Kit.prism(3.6, 1.6, 3.8), Kit.mat("#7a4a22"), Vector3(0, 2.9, 0))
	if rng.randf() < 0.35:
		_e(g, "#8a8478", 0.6, 0.4, 0.5, Vector3(side * 0.6, 0.2, (rng.randf() - 0.5) * w), Vector3.ZERO, 6)
	return [g, w]


static func _tea(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var w := 6.0 + rng.randf() * 3.0
	_b(g, "#6e5a3a", 7.0, 0.2, w, Vector3(side * 3.8, 0.1, 0))
	for row in 4:
		var z := -w / 2.0 + 0.6
		while z < w / 2.0:
			_e(g, "#3f9a3a" if row % 2 else "#4aa844", 0.55, 0.45, 0.6, Vector3(side * (1.2 + row * 1.5), 0.45, z), Vector3.ZERO, 7)
			z += 1.1
	if rng.randf() < 0.35:
		var t := _oak(0.8, "#2f7a2e", "#f28a1a")
		t.position = Vector3(side * 6.5, 0, 0)
		g.add_child(t)
	if rng.randf() < 0.2:
		var hz := Kit.joint(g, Vector3(side * 5.5, 0, 0))
		_b(hz, "#e9e2cf", 3.0, 2.6, 3.4, Vector3(0, 1.3, 0))
		Kit.part(hz, Kit.prism(3.6, 1.4, 3.8), Kit.mat("#8a9aa8"), Vector3(0, 3.3, 0))
	return [g, w]


static func _orchard(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var w := 6.0 + rng.randf() * 3.0
	_b(g, "#6aa84a", 7.0, 0.2, w, Vector3(side * 3.8, 0.1, 0))
	var z := -w / 2.0
	while z < w / 2.0:
		_b(g, "#8a5a2b", 0.08, 0.9, 0.08, Vector3(side * 0.9, 0.45, z))
		z += 0.9
	_b(g, "#8a5a2b", 0.06, 0.08, w, Vector3(side * 0.9, 0.75, 0))
	for i in 3:
		var t := _oak(0.75 + rng.randf() * 0.3, "#4a9a3a", "#c8221d")
		t.position = Vector3(side * (2.2 + rng.randf() * 4.0), 0, -w / 2.0 + rng.randf() * w)
		g.add_child(t)
	if rng.randf() < 0.25:
		var l := Props.loom()
		l.position = Vector3(side * 1.8, 0, 0)
		l.rotation.y = PI / 2
		g.add_child(l)
	return [g, w]


static func _rocks(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var w := 6.0 + rng.randf() * 3.0
	_b(g, "#c8b48a", 7.0, 0.15, w, Vector3(side * 3.8, 0.07, 0))
	_b(g, Kit.tex("rock_art"), 1.2, 2.4 + rng.randf() * 1.6, w * 0.7, Vector3(side * 1.8, 1.4, 0), Vector3(0, 0, side * 0.12))
	for i in 3:
		_e(g, "#8a6e52", 0.8 + rng.randf(), 0.6 + rng.randf() * 0.8, 0.9, Vector3(side * (3.5 + rng.randf() * 3.0), 0.5, -w / 2.0 + rng.randf() * w), Vector3.ZERO, 6)
	for i in 5:
		_c(g, "#b8a05a", 0.1, 0.4, Vector3(side * (1.0 + rng.randf() * 5.0), 0.2, -w / 2.0 + rng.randf() * w), Vector3.ZERO, 0.0)
	return [g, w]


# --- the horizon -------------------------------------------------------------------------------

static func _hills(g: Node3D, cols: Array, n: int, base: float) -> void: # rounded hills, half sunk
	for i in n:
		var h := base + (i % 3) * 18.0
		_e(g, cols[i % 2], 40.0 + i * 5.0, h, 30.0, Vector3(-120.0 + i * (240.0 / n), 0, -40.0 - (i % 2) * 25.0), Vector3.ZERO, 10)


## The far view for a city, built around (0, 0, 0): place it ahead at the street's end.
static func backdrop(city: String) -> Node3D:
	var g := Node3D.new()
	match city:
		"sheki":
			_b(g, Kit.tex("palace", Vector2(3, 1)), 40, 16, 10, Vector3(0, 8, 0))
			Kit.part(g, Kit.prism(44, 6, 12), Kit.tex("sheki_roof", Vector2(10, 2)), Vector3(0, 19, 0))
			for i in 6:
				_c(g, "#3e7a3a" if i % 2 else "#2f6a34", 40.0 + i * 6.0, 60.0 + (i % 3) * 15.0, Vector3(-110.0 + i * 44.0, 28, -60.0 - (i % 2) * 20.0), Vector3.ZERO, 0.0)
		"qebele":
			for i in 7:
				_c(g, "#3e7a3a" if i % 2 else "#2f6a34", 36.0 + i * 5.0, 70.0 + (i % 3) * 20.0, Vector3(-120.0 + i * 40.0, 34, -40.0 - (i % 2) * 25.0), Vector3.ZERO, 0.0)
			_e(g, "#6e6a5a", 14, 44, 8, Vector3(-6, 0, -14), Vector3.ZERO, 7) # the cliffs either side of the fall
			_e(g, "#6e6a5a", 14, 40, 8, Vector3(22, 0, -14), Vector3.ZERO, 7)
			var fall := Kit.part(g, Kit.plane(12, 40), Kit.tex("water", Vector2(2, 2)), Vector3(8, 22, -8))
			fall.set_meta("scroll", true)
			_e(g, "#e8f4ff", 11, 3, 5, Vector3(8, 2, -6))
		"naxcivan":
			_hills(g, ["#8a5a3a", "#a06a42"], 6, 50)
			_c(g, "#6e4a32", 16, 70, Vector3(40, 35, -30), Vector3.ZERO, 0.0)
			_c(g, "#6e4a32", 12, 60, Vector3(52, 30, -28), Vector3.ZERO, 0.0)
			_c(g, Kit.tex("brick", Vector2(3, 3)), 6.5, 34, Vector3(-18, 17, 20), Vector3.ZERO, 6.0)
			_c(g, "#1f9e9a", 6.6, 3, Vector3(-18, 33, 20))
		"lenkeran":
			_hills(g, ["#2f6a34", "#3e7a3a"], 7, 55)
			_c(g, "#f6f2ea", 3, 26, Vector3(24, 13, 15), Vector3.ZERO, 2.2)
			_c(g, "#c8322c", 2.4, 3, Vector3(24, 27, 15))
		"quba":
			for i in 6:
				var x := -110.0 + i * 44.0
				var hh := 70.0 + (i % 3) * 20.0
				_c(g, "#4f6a5a" if i % 2 else "#5e7a64", 36, hh, Vector3(x, hh / 2.0, -50), Vector3.ZERO, 0.0)
				_c(g, "#ffffff", 12, hh * 0.32, Vector3(x, hh * 0.84, -50), Vector3.ZERO, 0.0)
		"qobustan":
			_hills(g, ["#a08a64", "#b09a72"], 6, 40)
			for i in 4:
				_c(g, "#6e6a62", 10, 7, Vector3(-40.0 + i * 26.0, 3.5, 10), Vector3.ZERO, 2.0)
		_: # Baku: Qız Qalası with its buttress, the Caspian hills
			var t := tower()
			t.position = Vector3(26, 0, 10)
			g.add_child(t)
	for c in g.get_children(): # far away: no fog, so the skyline shows through the haze
		_no_fog(c)
	return g


static var _fogless := {} ## material -> its copy without fog (shared, so far things still merge)


## Turns fog off for everything under n (far scenery stays clear through the haze).
static func _no_fog(n: Node) -> void:
	for c in n.get_children():
		_no_fog(c)
	if n is MeshInstance3D and n.material_override is StandardMaterial3D:
		var src: StandardMaterial3D = n.material_override
		if not _fogless.has(src):
			var m: StandardMaterial3D = src.duplicate()
			m.disable_fog = true
			_fogless[src] = m
		n.material_override = _fogless[src]


## Qız Qalası: the Maiden Tower with its buttress.
static func tower() -> Node3D:
	var g := Node3D.new()
	var t := Kit.tex("tower", Vector2(3, 1))
	_c(g, t, 8, 30, Vector3(0, 15, 0), Vector3.ZERO, 7.0)
	_b(g, Kit.tex("tower", Vector2(1, 1)), 7, 28, 9, Vector3(0, 14, -7.5))
	_c(g, "#a98351", 7.2, 1.4, Vector3(0, 30.6, 0))
	return g


## The qala darvazası: one stone wall with a round-topped passage over all three lanes (and their kerbs).
static func gate() -> Node3D:
	var g := Node3D.new()
	var pts := PackedVector2Array([Vector2(-5.4, 0), Vector2(-3.7, 0)])
	for i in 21: # the opening, cut along a half circle
		var a := PI - i * PI / 20.0
		pts.append(Vector2(cos(a) * 3.7, 4.3 + sin(a) * 3.7))
	pts.append_array([Vector2(3.7, 0), Vector2(5.4, 0), Vector2(5.4, 8.4), Vector2(-5.4, 8.4)])
	pts.reverse()
	Kit.part(g, Kit.extrude(pts, 6.0, "gate"), Kit.tex("wall", Vector2(0.28, 0.28) * 6.0))
	for i in 8:
		_b(g, "#c4934f", 0.9, 0.8, 1.0, Vector3(-4.9 + i * 1.4, 8.8, 2.5))
	for x in [-4.55, 4.55]:
		_b(g, "#6b4a2c", 0.8, 1.4, 0.1, Vector3(x, 5.6, 3.02))
	return g
