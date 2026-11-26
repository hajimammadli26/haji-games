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

## Each city's street look: road texture, its tint, kerb colour, haze; the sky's top and horizon, the sun's colour
## and energy, and the clouds' colour (art bible §4 per city: the game layer never changes, only light and haze).
const LOOK := {
	"baku": {"road": "cobble_grey", "tint": "#ffffff", "curb": "#b38a55", "fog": "#f3d6a4", "sky": "#3d8fd6",
		"hz": "#f8e2b4", "sun": "#fff1d6", "sun_e": 1.05, "cloud": "#fff8ec"},
	"sheki": {"road": "cobble_grey", "tint": "#f2f2f2", "curb": "#9e3d22", "fog": "#dfe9d6", "sky": "#4a9ae0",
		"hz": "#eef2dc", "sun": "#fff4e0", "sun_e": 1.0, "cloud": "#ffffff"},
	"qebele": {"road": "trail", "tint": "#ffffff", "curb": "#4f7a3a", "fog": "#cfe2d8", "sky": "#5aa8e0",
		"hz": "#dcefe8", "sun": "#f4f8e6", "sun_e": 0.95, "cloud": "#f4fbff"},
	"naxcivan": {"road": "cobble_grey", "tint": "#f2e6dc", "curb": "#9a4e2a", "fog": "#ead2b8", "sky": "#3486d4",
		"hz": "#f6dab4", "sun": "#ffe8c8", "sun_e": 1.1, "cloud": "#fff4e4"},
	"lenkeran": {"road": "cobble_grey", "tint": "#dde4e6", "curb": "#5f7a64", "fog": "#c9d6d8", "sky": "#7a9ab0",
		"hz": "#dfe6e6", "sun": "#e8eef0", "sun_e": 0.85, "cloud": "#c4ccd2"},
	"quba": {"road": "cobble_grey", "tint": "#f2f2f2", "curb": "#8a5a2b", "fog": "#dfe8e0", "sky": "#3b8fe0",
		"hz": "#eaf3f6", "sun": "#fffaf0", "sun_e": 1.05, "cloud": "#ffffff"},
	"qobustan": {"road": "trail", "tint": "#e0d4bc", "curb": "#a08a64", "fog": "#e8dcc4", "sky": "#5a9ed8",
		"hz": "#f2e4c6", "sun": "#ffecd0", "sun_e": 1.05, "cloud": "#fbf2e2"},
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
	var sx := -side # toward the street
	var stone: String = ["#e6c48a", "#dcb77a", "#ecd09a"][rng.randi() % 3] # trim stone, a little different per house
	_b(g, Kit.tex("wall", Vector2(d / 4.0, h / 4.0) * 1.0), d, h, w, Vector3(side * d / 2.0, h / 2.0, 0))
	# the cornice: a pale moulding with dentils under a projecting slab, then the parapet's merlons
	_b(g, stone, 0.3, 0.18, w + 0.1, Vector3(sx * 0.1, h - 0.12, 0))
	var k := -w / 2.0 + 0.3
	while k < w / 2.0 - 0.2:
		_b(g, stone, 0.16, 0.14, 0.16, Vector3(sx * 0.07, h - 0.3, k))
		k += 0.55
	_b(g, "#c4934f", d + 0.3, 0.4, w + 0.2, Vector3(side * d / 2.0, h + 0.2, 0))
	var m := 0.5 # a flat roof edged with little merlons, like İçərişəhər's parapets
	while m < w:
		_b(g, "#c99a58", 0.45, 0.55, 0.5, Vector3(-side * 0.05, h + 0.65, -w / 2.0 + m))
		m += 1.1
	for zc in [-1.0, 1.0]: # quoins: pale corner stones, long and short in turn
		var y := 0.55
		var i := 0
		while y < h - 0.4:
			var qw := 0.7 if i % 2 == 0 else 0.42
			_b(g, stone, 0.06, 0.46, qw, Vector3(sx * 0.03, y, zc * (w / 2.0 - qw / 2.0)))
			y += 0.55
			i += 1
	_b(g, "#9a6a34", 0.3, 0.3, w + 0.2, Vector3(-side * 0.1, 0.15, 0)) # a stone plinth, darker: the wall's foot in shade
	_b(g, "#7e5428", 0.32, 0.06, w + 0.2, Vector3(-side * 0.1, 0.02, 0))
	var face := -side * 0.02
	var floors := maxi(1, int(h / 3.0))
	var door_i := -1
	var n0 := maxi(1, int(w / 2.4))
	if rng.randf() < 0.75:
		door_i = rng.randi() % n0
	for f in floors:
		var y := 1.6 + f * 3.0
		if f >= 1: # a string course between the floors
			_b(g, stone, 0.12, 0.16, w, Vector3(sx * 0.06, y - 1.5, 0))
		var n := maxi(1, int(w / 2.4))
		for i in n:
			var z := -w / 2.0 + (i + 0.5) * (w / n)
			if f == 0 and i == door_i:
				_door(g, side, z, rng)
				continue
			_face(g, side, Kit.tex("shebeke"), 1.2, 1.8, Vector3(face, y + 0.3, z))
			for e in [-1.0, 1.0]: # the stone frame
				_b(g, stone, 0.1, 2.0, 0.14, Vector3(sx * 0.05, y + 0.3, z + e * 0.67))
			_b(g, stone, 0.16, 0.24, 1.6, Vector3(sx * 0.08, y + 1.32, z)) # the lintel and its keystone
			_b(g, "#d8b06a", 0.2, 0.34, 0.24, Vector3(sx * 0.1, y + 1.36, z))
			_b(g, stone, 0.2, 0.1, 1.5, Vector3(sx * 0.1, y - 0.66, z)) # the sill
		if f >= 1 and rng.randf() < 0.65:
			if rng.randf() < 0.55:
				_closed_eyvan(g, side, y, w, rng)
			else: # an open wooden eyvan, sometimes with a carpet over its rail
				var bx := -side * 0.7
				_b(g, Kit.tex("wood"), 1.4, 0.15, w * 0.8, Vector3(bx, y - 0.9, 0))
				_b(g, "#5e3618", 0.1, 0.7, w * 0.8, Vector3(bx * 2.0, y - 0.5, 0))
				_b(g, "#5e3618", 0.12, 0.08, w * 0.8, Vector3(bx * 2.0, y - 0.12, 0)) # the handrail
				for q in 3: # brackets under it
					_b(g, "#5e3618", 1.2, 0.12, 0.12, Vector3(bx, y - 1.1, -w * 0.3 + q * w * 0.3), Vector3(0, 0, side * 0.5))
				if rng.randf() < 0.6:
					var c := _face(g, side, Kit.tex(Props.CARPETS[rng.randi() % 3], Vector2.ONE, Color.WHITE, true), 1.6, 2.2, Vector3(bx * 2.0 - side * 0.06, y - 1.4, 0))
					c.set_meta("no_ink", true)
	if rng.randf() < 0.3 and floors >= 2: # washing on a line between two brackets
		var ly := 1.6 + 3.0 + 1.6
		_b(g, "#3b2414", 0.02, 0.02, w * 0.7, Vector3(sx * 0.45, ly, 0))
		for q in 4:
			var cl: String = ["#e9e2cf", "#7fa6c8", "#d8b46a", "#b86a5a"][(q + rng.randi()) % 4]
			_b(g, cl, 0.03, 0.5 + rng.randf() * 0.3, 0.45, Vector3(sx * 0.45, ly - 0.35, -w * 0.3 + q * w * 0.2))
	if rng.randf() < 0.18:
		_e(g, "#c7a06c", 1.6, 1.3, 1.6, Vector3(side * d / 2.0, h + 0.3, 0))
	elif rng.randf() < 0.35: # a little room on the roof, set back
		_b(g, "#d2a462", 2.2, 1.8, 2.4, Vector3(side * 3.2, h + 0.9, (rng.randf() - 0.5) * (w - 3.0)))
	_details(g, side, w, rng)
	_baku_props(g, side, w, rng)
	return [g, w]


## A door on the ground floor at z: a stone arch round two wooden leaves, a step, sometimes a pot by it.
static func _door(g: Node3D, side: int, z: float, rng: RandomNumberGenerator) -> void:
	var sx := -side
	var wood: String = ["#4a2a14", "#5e3418", "#3e3a30"][rng.randi() % 3]
	_face(g, side, Kit.mat(wood), 1.3, 2.2, Vector3(sx * 0.03, 1.1, z))
	_c(g, wood, 0.65, 0.02, Vector3(sx * 0.03, 2.2, z), Vector3(0, 0, PI / 2))
	_b(g, "#2a1a0e", 0.05, 2.2, 0.05, Vector3(sx * 0.05, 1.1, z)) # the leaves' meeting line
	for e in [-1.0, 1.0]:
		_b(g, "#e6c48a", 0.14, 2.3, 0.2, Vector3(sx * 0.07, 1.15, z + e * 0.75))
		_e(g, "#c89b45", 0.04, 0.04, 0.04, Vector3(sx * 0.07, 1.15, z + e * 0.18)) # knockers
	_c(g, "#e6c48a", 0.86, 0.02, Vector3(sx * 0.015, 2.2, z), Vector3(0, 0, PI / 2)) # the arch's stone ring, behind the door
	_b(g, "#b89a6a", 0.6, 0.16, 1.8, Vector3(sx * 0.3, 0.08, z)) # the step
	if rng.randf() < 0.5: # a copper pot hanging by the door
		_c(g, "#c46a2c", 0.16, 0.22, Vector3(sx * 0.35, 2.5, z + 1.0), Vector3.ZERO, 0.2)


## Baku's closed wooden balcony (şüşəbənd): a wooden box on brackets, şəbəkə glazing along its front.
static func _closed_eyvan(g: Node3D, side: int, y: float, w: float, rng: RandomNumberGenerator) -> void:
	var sx := -side
	var bw := minf(w * 0.7, 3.6)
	var bz := (rng.randf() - 0.5) * (w - bw - 0.6)
	_b(g, Kit.tex("wood"), 0.9, 2.2, bw, Vector3(sx * 0.45, y + 0.1, bz))
	_face(g, side, Kit.tex("shebeke"), bw - 0.25, 1.15, Vector3(sx * 0.915, y + 0.45, bz))
	var mz := -bw / 2.0 + 0.12
	while mz <= bw / 2.0 - 0.1: # the mullions
		_b(g, "#4a2a14", 0.06, 1.3, 0.08, Vector3(sx * 0.93, y + 0.45, bz + mz))
		mz += (bw - 0.24) / 3.0
	_b(g, "#5e3618", 0.08, 0.1, bw, Vector3(sx * 0.93, y - 0.18, bz)) # rails at the glazing's foot
	_b(g, "#8a5a2b", 1.15, 0.14, bw + 0.25, Vector3(sx * 0.55, y + 1.25, bz)) # its little roof
	_b(g, "#6b4220", 1.05, 0.14, bw + 0.15, Vector3(sx * 0.5, y - 1.0, bz)) # and floor
	for q in [-1.0, 1.0]: # carved brackets under it
		_b(g, "#5e3618", 1.0, 0.12, 0.12, Vector3(sx * 0.42, y - 1.3, bz + q * (bw / 2.0 - 0.25)), Vector3(0, 0, side * 0.55))


## Baku's doorstep life: a wooden bench, a copper jug, a tea table with its samovar now and then.
static func _baku_props(g: Node3D, side: int, w: float, rng: RandomNumberGenerator) -> void:
	var sx := -side
	if rng.randf() < 0.3:
		var z := (rng.randf() - 0.5) * (w - 2.0)
		_b(g, "#6b4220", 0.4, 0.06, 1.4, Vector3(sx * 0.35, 0.45, z))
		for e in [-0.6, 0.6]:
			_b(g, "#4a2a14", 0.36, 0.45, 0.06, Vector3(sx * 0.35, 0.22, z + e))
	if rng.randf() < 0.3:
		var z := (rng.randf() - 0.5) * (w - 1.0)
		_c(g, "#b8642a", 0.16, 0.36, Vector3(sx * 0.3, 0.18, z), Vector3.ZERO, 0.1)
		_c(g, "#b8642a", 0.06, 0.14, Vector3(sx * 0.3, 0.43, z), Vector3.ZERO, 0.08)
	if rng.randf() < 0.12: # a samovar on a low table
		var z := (rng.randf() - 0.5) * (w - 1.5)
		_c(g, "#6b4220", 0.4, 0.06, Vector3(sx * 0.55, 0.42, z))
		_c(g, "#4a2a14", 0.05, 0.4, Vector3(sx * 0.55, 0.2, z))
		_c(g, "#c88a3a", 0.13, 0.3, Vector3(sx * 0.55, 0.6, z), Vector3.ZERO, 0.16)
		_c(g, "#8a5a2b", 0.05, 0.1, Vector3(sx * 0.55, 0.8, z))


static func _sheki(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var h := 4.5 + rng.randf() * 2.5
	var w := 5.0 + rng.randf() * 3.0
	var d := 5.0
	_b(g, Kit.tex("sheki_wall", Vector2(d / 4.0, h / 4.0)), d, h, w, Vector3(side * d / 2.0, h / 2.0, 0))
	Kit.part(g, Kit.prism(d + 1.0, 2.0, w + 0.8), Kit.tex("sheki_roof", Vector2(3, 2)), Vector3(side * d / 2.0, h + 1.0, 0))
	for by in [0.35, h - 0.25]: # brick bands along the river-stone wall
		_b(g, "#a8583a", 0.06, 0.3, w, Vector3(-side * 0.01, by, 0))
	if rng.randf() < 0.5: # a chimney through the red tiles
		_b(g, "#d8cdb8", 0.6, 1.6, 0.6, Vector3(side * d * 0.7, h + 1.6, (rng.randf() - 0.5) * w * 0.5))
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
	_b(g, Kit.tex("brick", Vector2(d / 4.0, h / 4.0), Color("#e6cdbd")), d, h, w, Vector3(side * d / 2.0, h / 2.0, 0))
	_b(g, "#9a5a3a", d + 0.2, 0.35, w + 0.2, Vector3(side * d / 2.0, h + 0.17, 0)) # the flat roof's edge
	_b(g, "#4f9a94", 0.08, 0.45, w, Vector3(-side * 0.02, h - 0.5, 0)) # a girih band, muted turquoise
	for k in int(w / 0.9): # its diamonds
		_b(g, "#e9dfcc", 0.04, 0.22, 0.22, Vector3(-side * 0.07, h - 0.5, -w / 2.0 + 0.45 + k * 0.9), Vector3(PI / 4, 0, 0))
	var n := maxi(1, int(w / 2.2))
	for i in n:
		var z := -w / 2.0 + (i + 0.5) * (w / n)
		var y := h * 0.5
		_face(g, side, Kit.mat("#4f9a94"), 1.2, 1.7, Vector3(-side * 0.02, y, z)) # turquoise frame
		_face(g, side, Kit.mat("#3a2a24"), 0.85, 1.45, Vector3(-side * 0.04, y - 0.1, z)) # the dark opening
		var arch := _c(g, "#4f9a94", 0.6, 0.8, Vector3(-side * 0.03, y + 1.2, z), Vector3(0, 0, 0), 0.0) # pointed top
		arch.scale = Vector3(0.1, 1, 1) # flat against the wall
	if rng.randf() < 0.25:
		_e(g, "#4f9a94", 1.4, 1.1, 1.4, Vector3(side * 2.5, h + 0.3, 0))
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
	var lv := [[1.3, 1.4, 1.4, "#24584a"], [1.0, 1.2, 2.3, "#2f6b4f"], [0.7, 1.0, 3.1, "#3d7d5c"]]
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
	_b(g, "#3f6b45", 7.0, 0.3, w, Vector3(side * 3.7, 0.15, 0))
	for i in 3 + rng.randi() % 3:
		var t := _pine(1.0 + rng.randf() * 1.0) if rng.randf() < 0.65 else _oak(0.8 + rng.randf() * 0.5, "#3a7a52")
		t.position = Vector3(side * (1.6 + rng.randf() * 5.0), 0, -w / 2.0 + rng.randf() * w)
		g.add_child(t)
	for i in 2 + rng.randi() % 2: # fındıq: hazel bushes with nut clusters, right by the trail
		var z := -w / 2.0 + rng.randf() * w
		var x := side * (0.7 + rng.randf() * 0.6)
		_e(g, "#4a8a4e", 0.6, 0.5, 0.6, Vector3(x, 0.5, z), Vector3.ZERO, 7)
		for k in 3:
			_e(g, "#a8743a", 0.09, 0.09, 0.09, Vector3(x - side * 0.5, 0.55 + k * 0.08, z + (k - 1) * 0.15), Vector3.ZERO, 6)
	if rng.randf() < 0.45: # a kötük: a cut stump with its pale top
		var z := (rng.randf() - 0.5) * w
		_c(g, "#6b4220", 0.35, 0.5, Vector3(side * 1.0, 0.25, z), Vector3.ZERO, 0.3)
		_c(g, "#d8b07a", 0.3, 0.03, Vector3(side * 1.0, 0.51, z))
	if rng.randf() < 0.2: # a log hut
		var hut := Kit.joint(g, Vector3(side * 4.0, 0, 0))
		for y in 6:
			_c(hut, "#5b3a22", 0.18, 3.4, Vector3(0, 0.2 + y * 0.36, 0), Vector3(PI / 2, 0, 0))
		Kit.part(hut, Kit.prism(3.6, 1.6, 3.8), Kit.mat("#7a4a22"), Vector3(0, 2.9, 0))
	if rng.randf() < 0.5: # a mossy boulder
		var z := (rng.randf() - 0.5) * w
		_e(g, "#8a8478", 0.7, 0.45, 0.6, Vector3(side * 0.9, 0.2, z), Vector3.ZERO, 6)
		_e(g, "#5a8a4a", 0.55, 0.18, 0.5, Vector3(side * 0.95, 0.55, z), Vector3.ZERO, 6)
	return [g, w]


static func _tea(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var w := 6.0 + rng.randf() * 3.0
	for row in 4: # terraces stepping up away from the street, a tea row on each
		_b(g, "#7a6446", 1.5, 0.25 + row * 0.35, w, Vector3(side * (1.2 + row * 1.5), (0.25 + row * 0.35) / 2.0, 0))
		var z := -w / 2.0 + 0.6
		while z < w / 2.0:
			_e(g, "#5f9b4a" if row % 2 else "#4f8c42", 0.6, 0.42, 0.6, Vector3(side * (1.2 + row * 1.5), 0.6 + row * 0.35, z), Vector3.ZERO, 7)
			z += 1.05
	if rng.randf() < 0.4: # a naringi tree heavy with tangerines
		var t := _oak(0.85, "#2f7a3e", "#f07a1a")
		t.position = Vector3(side * 7.2, 1.4, (rng.randf() - 0.5) * w * 0.6)
		g.add_child(t)
	if rng.randf() < 0.3: # a tin-roofed house on posts with a veranda
		var hz := Kit.joint(g, Vector3(side * 8.4, 1.4, 0))
		for px in [-1.3, 1.3]:
			for pz in [-1.6, 1.6]:
				_c(hz, "#5e3618", 0.1, 0.9, Vector3(px, 0.45, pz))
		_b(hz, "#e9e2cf", 3.0, 2.4, 3.4, Vector3(0, 2.1, 0))
		_b(hz, "#8a5a2b", 3.4, 0.12, 3.8, Vector3(0, 0.95, 0))
		_face(hz, side, Kit.mat("#4a6a7a"), 0.8, 1.0, Vector3(-side * 1.52, 2.2, 0.7))
		Kit.part(hz, Kit.prism(3.8, 1.3, 4.2), Kit.mat("#8a9aa8"), Vector3(0, 3.95, 0))
		for k in 5: # the tin's ridges
			_b(hz, "#6f8090", 3.9, 0.06, 0.06, Vector3(0, 3.5, -1.8 + k * 0.9))
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
	var apples := ["#9cc43a", "#e8c94a", "#c86a7a"] # green, yellow, desaturated rose: never the papaq red
	for i in 3:
		var t := _oak(0.75 + rng.randf() * 0.3, "#4a9a3a", apples[rng.randi() % 3])
		t.position = Vector3(side * (2.2 + rng.randf() * 4.0), 0, -w / 2.0 + rng.randf() * w)
		g.add_child(t)
	if rng.randf() < 0.25:
		var l := Props.loom()
		l.position = Vector3(side * 1.8, 0, 0)
		l.rotation.y = PI / 2
		g.add_child(l)
	elif rng.randf() < 0.3: # a Quba house: wooden walls, a carved balcony, a green tin hip roof
		var hz := Kit.joint(g, Vector3(side * 5.2, 0, 0))
		_b(hz, "#c89a68", 3.6, 4.6, 4.0, Vector3(0, 2.3, 0))
		_b(hz, "#8a5a2b", 0.9, 0.12, 3.6, Vector3(-side * 2.2, 2.4, 0))
		for k in 5:
			_c(hz, "#6b4220", 0.05, 0.8, Vector3(-side * 2.55, 2.85, -1.6 + k * 0.8))
		_b(hz, "#6b4220", 0.06, 0.08, 3.6, Vector3(-side * 2.55, 3.25, 0))
		for fz in [-1.0, 1.0]:
			_face(hz, side, Kit.mat("#3a4a5a"), 0.8, 1.0, Vector3(-side * 1.82, 3.4, fz))
		Kit.part(hz, Kit.cyl(0.0, 3.4, 1.8, 4), Kit.mat("#4f7a5a"), Vector3(0, 5.5, 0), Vector3(0, PI / 4, 0)) # a hip roof
	return [g, w]


static func _rocks(side: int, rng: RandomNumberGenerator) -> Array:
	var g := Node3D.new()
	var w := 6.0 + rng.randf() * 3.0
	_b(g, "#c8b48a", 7.0, 0.15, w, Vector3(side * 3.8, 0.07, 0))
	_b(g, Kit.tex("rock_art"), 1.2, 2.6 + rng.randf() * 1.6, w * 0.7, Vector3(side * 1.8, 1.4, 0), Vector3(0, 0, side * 0.12))
	for i in 2: # tabular boulders: flat slabs piled, as at Böyükdaş
		var x := side * (3.8 + rng.randf() * 2.5)
		var z := -w / 2.0 + rng.randf() * w
		var hh := 1.2 + rng.randf() * 1.2
		_b(g, "#8a7560", 2.6, hh, 2.2, Vector3(x, hh / 2.0, z), Vector3(0, rng.randf(), 0))
		_b(g, "#9a856a", 2.2, 0.7, 1.9, Vector3(x + side * 0.2, hh + 0.35, z), Vector3(0, rng.randf(), side * 0.08))
	for i in 2:
		_e(g, "#7d6a55", 0.8 + rng.randf(), 0.6 + rng.randf() * 0.6, 0.9, Vector3(side * (5.5 + rng.randf() * 2.0), 0.4, -w / 2.0 + rng.randf() * w), Vector3.ZERO, 6)
	for i in 5: # dry grass tufts
		_c(g, "#b8a05a", 0.1, 0.4, Vector3(side * (1.0 + rng.randf() * 5.0), 0.2, -w / 2.0 + rng.randf() * w), Vector3.ZERO, 0.0)
	return [g, w]


# --- the horizon -------------------------------------------------------------------------------

static func _hills(g: Node3D, cols: Array, n: int, base: float) -> void: # rounded hills, half sunk
	for i in n:
		var h := base + (i % 3) * 18.0
		_e(g, cols[i % 2], 40.0 + i * 5.0, h, 30.0, Vector3(-120.0 + i * (240.0 / n), 0, -40.0 - (i % 2) * 25.0), Vector3.ZERO, 10)


## A mountain: a cone, with a snow cap (snow "" for none).
static func _peak(g: Node3D, col: String, r: float, h: float, pos: Vector3, snow := "", cap := 0.35, segs := 9) -> void:
	Kit.part(g, Kit.cyl(0.0, r, h, segs), Kit.mat(col), pos + Vector3(0, h / 2.0, 0))
	if snow != "":
		Kit.part(g, Kit.cyl(0.0, r * cap * 1.04, h * cap, segs), Kit.mat(snow), pos + Vector3(0, h * (1.0 - cap / 2.0) + 0.2, 0))


## A tiered pine silhouette for far forests.
static func _far_pine(g: Node3D, col: String, h: float, pos: Vector3) -> void:
	for k in 3:
		Kit.part(g, Kit.cyl(0.0, h * (0.32 - k * 0.07), h * 0.45, 7), Kit.mat(col), pos + Vector3(0, h * (0.28 + k * 0.24), 0))


## A flat-roofed far house (a box with a darker top), for skylines.
static func _far_house(g: Node3D, wall: String, top: String, sx: float, sy: float, pos: Vector3) -> void:
	_b(g, wall, sx, sy, sx * 0.8, pos + Vector3(0, sy / 2.0, 0))
	_b(g, top, sx + 0.6, 0.8, sx * 0.8 + 0.6, pos + Vector3(0, sy + 0.4, 0))


## The far view for a city, built around (0, 0, 0): place it ahead at the street's end. Each city's landmark
## stands near the middle, tall, so it shows over the street's end (art bible §6: the horizon says where you are).
## Plain-coloured pieces merge into one vertex-coloured mesh before fog is turned off: the whole horizon is a
## few draws however much it holds.
static func backdrop(city: String) -> Node3D:
	var g := Node3D.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(city)
	match city:
		"sheki": # forested Caucasus foothills, red-roofed houses on them, the Xan sarayı on its terrace
			for i in 5:
				_peak(g, "#7f9cae" if i % 2 else "#8eaabb", 70.0, 110.0 + (i % 3) * 25.0, Vector3(-200.0 + i * 100.0, -10, -150))
			_hills(g, ["#3e7a52", "#4a8a5a"], 7, 45)
			for i in 14:
				var x := -110.0 + i * 16.0 + rng.randf() * 6.0
				if absf(x) < 26.0:
					continue
				var y := 6.0 + rng.randf() * 18.0
				var z := -20.0 - rng.randf() * 20.0
				_b(g, "#e9dfcc", 6, 4, 5, Vector3(x, y + 2, z))
				Kit.part(g, Kit.prism(7, 2.4, 6), Kit.mat("#a8432c"), Vector3(x, y + 5.2, z))
			_b(g, "#cbbd9e", 58, 6, 22, Vector3(-4, 3, 4)) # the terrace
			_b(g, Kit.tex("palace", Vector2(3, 1)), 48, 20, 12, Vector3(-4, 16, 4))
			Kit.part(g, Kit.prism(54, 7, 15), Kit.tex("sheki_roof", Vector2(10, 2)), Vector3(-4, 29.5, 4))
			for x in [-36.0, 28.0]: # the old plane trees (çinar) beside it
				_c(g, "#6b4a30", 1.6, 18, Vector3(x, 9, 10))
				_e(g, "#3f7a46", 11, 10, 10, Vector3(x, 24, 10), Vector3.ZERO, 9)
		"qebele": # misty mountains, a dark pine forest, the waterfall in its cliff right ahead
			for i in 5:
				_peak(g, "#7fa6a8" if i % 2 else "#91b4b4", 75.0, 130.0 + (i % 2) * 30.0, Vector3(-200.0 + i * 100.0, -10, -170), "#eef6f6", 0.22)
			for i in 26:
				var x := -130.0 + i * 10.0 + rng.randf() * 4.0
				if absf(x) < 22.0:
					continue
				_far_pine(g, ["#24584a", "#2f6b4f", "#1f4f44"][i % 3], 34.0 + rng.randf() * 26.0, Vector3(x, 0, -10.0 - rng.randf() * 40.0))
			_b(g, "#6e6a5a", 50, 70, 16, Vector3(0, 35, -24)) # the cliff face
			_e(g, "#7a7666", 16, 60, 12, Vector3(-16, 0, -12), Vector3.ZERO, 7)
			_e(g, "#7a7666", 16, 56, 12, Vector3(16, 0, -12), Vector3.ZERO, 7)
			_e(g, "#4f8a5a", 28, 8, 12, Vector3(0, 70, -22), Vector3.ZERO, 8) # moss on top
			var fall := Kit.part(g, Kit.plane(14, 62), Kit.tex("water", Vector2(2, 3)), Vector3(0, 33, -10))
			fall.set_meta("scroll", true)
			_e(g, "#eef8ff", 14, 4, 6, Vector3(0, 2, -6), Vector3.ZERO, 10) # foam
			_e(g, "#6aa8c8", 20, 1, 10, Vector3(0, 0.3, 0), Vector3.ZERO, 10) # the pool
		"naxcivan": # dry terracotta hills, İlandağ's split crown, Möminə Xatın ahead
			_hills(g, ["#b07850", "#c08a5a"], 6, 34)
			_c(g, "#7a5446", 48, 80, Vector3(46, 40, -70), Vector3.ZERO, 14.0) # İlandağ
			_c(g, "#7a5446", 7, 26, Vector3(39, 93, -70), Vector3.ZERO, 0.0) # its two horns, the notch between
			_c(g, "#7a5446", 6, 20, Vector3(54, 90, -70), Vector3.ZERO, 0.0)
			for i in 10:
				var x := -100.0 + i * 20.0 + rng.randf() * 6.0
				if absf(x + 12.0) < 18.0:
					continue
				_far_house(g, "#c8865a", "#9a5a3a", 8.0 + rng.randf() * 5.0, 5.0 + rng.randf() * 5.0, Vector3(x, 0, 18.0 - rng.randf() * 16.0))
			var mx := Vector3(-12, 0, 20) # Möminə Xatın: a ten-sided brick tomb, turquoise bands, a pointed roof
			_b(g, "#a86a46", 18, 3, 18, mx + Vector3(0, 1.5, 0))
			Kit.part(g, Kit.cyl(7.0, 7.4, 40, 10), Kit.tex("brick", Vector2(4, 4)), mx + Vector3(0, 23, 0))
			for y in [30.0, 38.0, 42.0]:
				Kit.part(g, Kit.cyl(7.6, 7.6, 1.6, 10), Kit.mat("#4f9a94"), mx + Vector3(0, y, 0))
			Kit.part(g, Kit.cyl(0.0, 7.8, 11, 10), Kit.mat("#8a4e32"), mx + Vector3(0, 48.5, 0))
			_b(g, "#3a2a24", 4, 9, 0.3, mx + Vector3(0, 8, 7.4)) # the door
			_c(g, "#3a2a24", 2, 3, mx + Vector3(0, 14, 7.4), Vector3.ZERO, 0.0).scale = Vector3(1, 1, 0.15)
		"lenkeran": # Talysh mountains, tea terraces on the slopes, the Caspian and the lighthouse
			for i in 6:
				_e(g, "#4f7a6a" if i % 2 else "#5f8a78", 50.0, 60.0 + (i % 3) * 14.0, 30, Vector3(-150.0 + i * 52.0, 0, -80), Vector3.ZERO, 10)
			for k in 6: # stepped tea terraces climbing the hill on the left
				_b(g, "#5f9b4a" if k % 2 else "#4f8c42", 70.0 - k * 10.0, 4, 10, Vector3(-60.0 + k * 2.0, 2.0 + k * 4.0, -20.0 - k * 8.0))
			_b(g, "#5a86a8", 160, 1, 90, Vector3(80, 0.5, -10)) # the sea
			var lx := Vector3(18, 0, 22) # the lighthouse in Madder and cream
			_c(g, "#8a8478", 6, 3, lx + Vector3(0, 1.5, 0))
			_c(g, "#f0e6d0", 3.6, 34, lx + Vector3(0, 18, 0), Vector3.ZERO, 2.6)
			for y in [8.0, 18.0, 28.0]:
				_c(g, "#8f2b2b", 3.6 - y * 0.03, 4, lx + Vector3(0, y, 0), Vector3.ZERO, 3.4 - y * 0.03)
			_c(g, "#3a2a24", 3.8, 0.6, lx + Vector3(0, 35.2, 0)) # the gallery
			_c(g, "#fff2b0", 2.0, 3.2, lx + Vector3(0, 37.1, 0)) # the lamp room
			_c(g, "#8f2b2b", 2.6, 2.6, lx + Vector3(0, 40.0, 0), Vector3.ZERO, 0.0)
		"quba": # snowy Şahdağ massif, green foothills, rows of apple trees
			_peak(g, "#7f96ac", 56, 150, Vector3(-150, -10, -160), "#f2f6fc", 0.4)
			_peak(g, "#6f8aa2", 90, 190, Vector3(10, -10, -170), "#f6f9ff", 0.45, 11) # Şahdağ
			_peak(g, "#7f96ac", 60, 140, Vector3(140, -10, -150), "#f2f6fc", 0.4)
			_peak(g, "#8aa0b4", 50, 120, Vector3(80, -10, -120), "#f2f6fc", 0.3)
			_hills(g, ["#5a9a4a", "#6aa858"], 7, 24)
			for i in 40: # the orchards: little round trees in rows
				var x := -120.0 + (i % 20) * 12.0
				if absf(x) < 14.0:
					continue
				var z := 20.0 - (i / 20) * 14.0
				_c(g, "#6b4a30", 0.6, 3, Vector3(x, 1.5, z))
				_e(g, "#4a8a3a" if i % 3 else "#5a9a44", 4.5, 4, 4.5, Vector3(x, 5.5, z), Vector3.ZERO, 7)
		"qobustan": # flat-topped rock outcrops either side, grey mud volcanoes ahead, the Caspian beyond
			_b(g, "#3d8fd6", 600, 10, 40, Vector3(0, 5, -120)) # the sea, a band on the horizon
			_b(g, "#8fc4ea", 600, 0.6, 2, Vector3(0, 10.2, -100)) # its bright edge
			for i in 8:
				var sd := -1.0 if i % 2 else 1.0
				var x := sd * (42.0 + (i / 2) * 34.0 + rng.randf() * 8.0)
				var hh := 18.0 + rng.randf() * 18.0
				var z := -20.0 - rng.randf() * 30.0
				_c(g, "#8a7560" if i % 3 else "#9a856a", 22.0 + rng.randf() * 6.0, hh, Vector3(x, hh / 2.0, z), Vector3.ZERO, 16.0)
				_c(g, "#a8946e", 15.5, 1.4, Vector3(x, hh + 0.3, z), Vector3.ZERO, 14.0)
			for i in 4: # mud volcanoes, wet grey tops and a mud tongue running down
				var v := Vector3(-30.0 + i * 20.0, 0, 10.0 - (i % 2) * 16.0)
				var r := 12.0 + (i % 2) * 5.0
				var hh := 10.0 + (i % 2) * 5.0
				_c(g, "#8c8a84", r, hh, v + Vector3(0, hh / 2.0, 0), Vector3.ZERO, r * 0.22)
				_c(g, "#5e5a54", r * 0.24, 0.6, v + Vector3(0, hh + 0.2, 0))
				_b(g, "#6e6a64", 1.8, 0.5, r * 0.9, v + Vector3(r * 0.2, hh * 0.5, r * 0.4), Vector3(atan2(hh, r) * 0.9, 0.3, 0))
		_: # Baku: the old city's sandstone roofs and wall, Qız Qalası, the Şirvanşahlar domes and minaret, the sea
			_b(g, "#3d8fd6", 500, 1, 120, Vector3(0, 0.5, -180))
			for i in 16:
				var x := -120.0 + i * 15.0 + rng.randf() * 5.0
				_far_house(g, ["#d9a95f", "#c99a52", "#e0b673"][i % 3], "#b88a4a", 9.0 + rng.randf() * 4.0, 7.0 + rng.randf() * 9.0, Vector3(x, 0, -6.0 - rng.randf() * 20.0))
			_b(g, "#c99a58", 240, 9, 3, Vector3(0, 4.5, 34)) # the qala wall
			for i in 40:
				_b(g, "#c99a58", 2.4, 2.2, 3.2, Vector3(-117.0 + i * 6.0, 10.1, 34))
			var mn := Vector3(24, 0, 0) # Şirvanşahlar: domes and the minaret
			_e(g, "#c99a58", 7, 6, 7, mn + Vector3(-4, 14, 0), Vector3.ZERO, 10)
			_b(g, "#d9a95f", 16, 14, 12, mn + Vector3(-4, 7, 0))
			_e(g, "#c99a58", 4, 4, 4, mn + Vector3(8, 10, 2), Vector3.ZERO, 10)
			_c(g, "#e0b673", 1.6, 34, mn + Vector3(12, 17, 4), Vector3.ZERO, 1.3)
			_c(g, "#b88a4a", 2.6, 1.2, mn + Vector3(12, 28, 4))
			_c(g, "#c99a58", 1.4, 4, mn + Vector3(12, 36, 4), Vector3.ZERO, 0.0)
			var t := tower()
			t.position = Vector3(-4, 0, 18) # right at the street's end, behind the qala wall, rising over the roofs
			t.rotation.y = PI * 0.65 # the windows and door face the street; the buttress shows at the side
			t.scale = Vector3.ONE * 1.9
			g.add_child(t)
	Kit.merge(g) # plain pieces become one vertex-coloured mesh (the waterfall keeps its own, it scrolls)
	_no_fog(g) # far away: no fog, so the skyline shows through the haze
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


const TOWER_UV := 0.07 ## masonry texture repeats per unit: one 16-course repeat every ~14 units
const TOWER_H := 30.0 ## the tower's height (the texture's v counts down from here, so courses line up)


static func _qq_r(y: float) -> float: # the tower's radius at a height: it tapers a little
	return 8.0 - y * 0.02


## Qız Qalası: the Maiden Tower. A slightly tapering round tower of grey-gold limestone courses (texture), three
## projecting stone belts, its long buttress with a rounded nose, small slit windows with pale lintels and sills,
## the arched door, a corbelled parapet with merlons, on a stepped rock plinth. The runner faces −Z; the side
## with the windows and the door faces local angle ~3.3 rad (backdrop() turns it toward the street).
## Textured parts share one material, the rest are plain colours: merged, the tower is two draws.
static func tower() -> Node3D:
	var g := Node3D.new()
	var stone := Kit.tex("tower", Vector2.ONE, Color("#e2d6c4")) # toned toward the real limestone's grey
	var pts := PackedVector2Array([Vector2(_qq_r(0.0), 0.0)])
	for yb in [7.0, 14.0, 21.0]: # the belts: a course stepping out
		pts.append_array([Vector2(_qq_r(yb), yb), Vector2(_qq_r(yb) + 0.22, yb + 0.12),
			Vector2(_qq_r(yb) + 0.22, yb + 0.62), Vector2(_qq_r(yb + 0.75), yb + 0.75)])
	var rt := _qq_r(28.0)
	pts.append_array([Vector2(rt, 28.0), Vector2(rt + 0.5, 28.5), Vector2(rt + 0.5, 29.8), # the corbelled parapet
		Vector2(rt - 0.4, 29.8), Vector2(rt - 0.4, 29.0), Vector2(0.0, 29.0)]) # its inside and the roof
	Kit.part(g, _lathe_uv(pts, 28, "qq_body"), stone)
	var nose := PackedVector2Array([Vector2(-3.2, -4.0), Vector2(3.2, -4.0), Vector2(3.2, -10.0)])
	for i in range(1, 12): # the buttress: a long wall ending in a half round, towards local −z
		var a := i * PI / 12.0
		nose.append(Vector2(cos(a) * 3.2, -10.0 - sin(a) * 3.2))
	nose.append(Vector2(-3.2, -10.0))
	Kit.part(g, _prism_up(nose, 26.5, "qq_buttress"), stone)
	for k in 7: # the buttress's own low parapet
		var a := k * PI / 6.0
		_b(g, "#c4a271", 0.9, 0.9, 0.6, Vector3(cos(a) * 2.9, 26.9, -10.0 - sin(a) * 2.9), Vector3(0, atan2(cos(a), -sin(a)), 0))
	_c(g, "#9c8058", 9.4, 1.4, Vector3(0, 0.7, 0)) # the rock plinth, stepped
	_c(g, "#ab8d62", 8.7, 0.7, Vector3(0, 1.75, 0))
	_b(g, "#9c8058", 7.6, 1.4, 11.0, Vector3(0, 0.7, -7.5))
	var wins := [[4.5, 2.7], [8.5, 3.5], [10.5, 2.5], [12.0, 4.0], [16.5, 3.0], [18.5, 3.9], [23.5, 2.6], [25.0, 3.6],
		[16.0, 1.2], [24.0, 0.4], [10.0, 5.6], [19.0, 6.1]]
	for wv in wins: # small slit windows, a pale lintel over each and a sill under it
		var y: float = wv[0]
		var a: float = wv[1]
		var dir := Vector3(cos(a), 0, sin(a))
		var rot := Vector3(0, atan2(dir.x, dir.z), 0)
		var rr := _qq_r(y)
		_b(g, "#2e231c", 0.8, 1.6, 0.5, dir * (rr - 0.15) + Vector3(0, y, 0), rot)
		_b(g, "#dcc596", 1.3, 0.32, 0.5, dir * (rr - 0.1) + Vector3(0, y + 0.96, 0), rot)
		_b(g, "#b89a6a", 1.1, 0.16, 0.45, dir * (rr - 0.08) + Vector3(0, y - 0.86, 0), rot)
	for wv in [[6.0, 0.0], [14.5, 0.0], [21.0, -1.6]]: # and on the buttress's nose and side
		var y: float = wv[0]
		if wv[1] == 0.0:
			_b(g, "#2e231c", 0.8, 1.5, 0.4, Vector3(0, y, -13.05))
			_b(g, "#dcc596", 1.3, 0.3, 0.4, Vector3(0, y + 0.92, -13.02))
		else:
			_b(g, "#2e231c", 0.4, 1.5, 0.8, Vector3(-3.15, y, -7.0))
	var da := 3.3 # the arched door at the foot, on the street side
	var dd := Vector3(cos(da), 0, sin(da))
	var drot := Vector3(0, atan2(dd.x, dd.z), 0)
	_b(g, "#d2b886", 3.0, 4.6, 0.6, dd * (_qq_r(2.0) - 0.2) + Vector3(0, 4.1, 0), drot) # its stone surround
	_b(g, "#2a1e18", 2.0, 2.8, 0.6, dd * (_qq_r(2.0) - 0.1) + Vector3(0, 3.5, 0), drot)
	var arch := _c(g, "#2a1e18", 1.0, 0.6, dd * (_qq_r(2.0) - 0.1) + Vector3(0, 4.9, 0), drot + Vector3(PI / 2, 0, 0))
	for k in 22: # merlons round the parapet
		var a := k * TAU / 22.0
		var dir := Vector3(cos(a), 0, sin(a))
		_b(g, "#c4a271", 1.25, 1.1, 0.7, dir * (rt + 0.2) + Vector3(0, 30.35, 0), Vector3(0, atan2(dir.x, dir.z), 0))
	return g


## A turned surface with world-scaled uvs (u round the circumference, v down from TOWER_H) and smooth normals
## round it, flat along the profile: the belts and parapet keep their crisp steps.
static func _lathe_uv(pts: PackedVector2Array, segs: int, key: String) -> Mesh:
	return Kit.cached(key, func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var reps := maxf(1.0, roundf(TAU * pts[0].x * TOWER_UV))
		for i in segs:
			var a0 := i * TAU / segs
			var a1 := (i + 1) * TAU / segs
			var u0 := float(i) / segs * reps
			var u1 := float(i + 1) / segs * reps
			for j in pts.size() - 1:
				var p := pts[j]
				var q := pts[j + 1]
				var d := q - p
				var n := Vector2(d.y, -d.x).normalized()
				var n0 := Vector3(cos(a0) * n.x, n.y, sin(a0) * n.x)
				var n1 := Vector3(cos(a1) * n.x, n.y, sin(a1) * n.x)
				var vp := (TOWER_H - p.y) * TOWER_UV
				var vq := (TOWER_H - q.y) * TOWER_UV
				Kit._quad(st, [Vector3(cos(a0) * p.x, p.y, sin(a0) * p.x), Vector3(cos(a1) * p.x, p.y, sin(a1) * p.x),
					Vector3(cos(a1) * q.x, q.y, sin(a1) * q.x), Vector3(cos(a0) * q.x, q.y, sin(a0) * q.x)],
					[n0, n1, n1, n0], [Vector2(u0, vp), Vector2(u1, vp), Vector2(u1, vq), Vector2(u0, vq)])
		return st.commit())


## A plan outline (x, z) raised h upward, walls and a flat top, uvs scaled like the tower's so courses line up.
static func _prism_up(poly: PackedVector2Array, h: float, key: String) -> Mesh:
	return Kit.cached(key, func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var mid := Vector2.ZERO
		for p in poly:
			mid += p / poly.size()
		var u := 0.0
		var vb := TOWER_H * TOWER_UV
		var vt := (TOWER_H - h) * TOWER_UV
		for i in poly.size():
			var a := poly[i]
			var b := poly[(i + 1) % poly.size()]
			var e := b - a
			var n := Vector3(e.y, 0, -e.x).normalized()
			var c := (a + b) * 0.5 - mid
			if n.dot(Vector3(c.x, 0, c.y)) < 0.0:
				n = -n
			var u1 := u + e.length() * TOWER_UV
			Kit._quad(st, [Vector3(a.x, 0, a.y), Vector3(b.x, 0, b.y), Vector3(b.x, h, b.y), Vector3(a.x, h, a.y)],
				[n, n, n, n], [Vector2(u, vb), Vector2(u1, vb), Vector2(u1, vt), Vector2(u, vt)])
			u = u1
		var tri := Geometry2D.triangulate_polygon(poly)
		for i in range(0, tri.size(), 3):
			var p0 := Vector3(poly[tri[i]].x, h, poly[tri[i]].y)
			var p1 := Vector3(poly[tri[i + 1]].x, h, poly[tri[i + 1]].y)
			var p2 := Vector3(poly[tri[i + 2]].x, h, poly[tri[i + 2]].y)
			var order := [p0, p1, p2] if (p2 - p0).cross(p1 - p0).dot(Vector3.UP) > 0.0 else [p0, p2, p1]
			for p in order:
				st.set_normal(Vector3.UP)
				st.set_uv(Vector2(p.x, p.z) * TOWER_UV)
				st.add_vertex(p)
		return st.commit())


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
