## The street's things: obstacles in each city's own look (baskets, carpet ropes, bazaar stalls, phaetons,
## hay carts, ramps, the camel caravan; Qəbələ's stumps, branches and boulders; Naxçıvan's salt; Quba's apple
## crates and looms; Qobustan's mud volcanoes, carved boulders and rock arches) and the pickups (yağ çörəyi,
## nar, the power-ups, letters, buta and magic stones, the cities' treats). Inked, built from Kit.
## Spec: the web prototype's addObstacle / addPickup and their make* builders.
##
## Usage:
##   var n := Props.obstacle("basket", 1.1, "quba", rng)   # centred on its length, facing the runner (+z)
##   var p := Props.pickup("bread")
class_name Props
extends RefCounted

const CARPETS := ["carpet_red", "carpet_blue", "carpet_green"]
## Each city's own look for an obstacle kind (others use the Baku look).
const SWAP := {
	"qebele": {"basket": "stump", "carpet": "branch", "stall": "boulder"},
	"naxcivan": {"basket": "salt"},
	"quba": {"basket": "crates", "stall": "loom"},
	"qobustan": {"basket": "mud", "stall": "art_boulder", "carpet": "rock_arch"},
}
## The treat each city puts in some bread lines.
const TREATS := {"sheki": "halva", "qebele": "finduq", "naxcivan": "bottle", "lenkeran": "tangerine", "quba": "apple"}


static func _e(p: Node3D, c: Variant, rx: float, ry: float, rz: float, pos: Vector3, rot := Vector3.ZERO, segs := 16) -> MeshInstance3D:
	return Characters._egg(p, c, rx, ry, rz, pos, rot, segs)


static func _c(p: Node3D, c: Variant, r: float, h: float, pos: Vector3, rot := Vector3.ZERO, r_top := -1.0) -> MeshInstance3D:
	return Characters._cyl(p, c, r, h, pos, rot, r_top)


static func _b(p: Node3D, c: Variant, sx: float, sy: float, sz: float, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	return Characters._box(p, c, sx, sy, sz, pos, rot)


## An obstacle of a kind, in a city's look; length for carts; rng picks a carpet's colours.
static func obstacle(kind: String, length: float, city: String, rng: RandomNumberGenerator) -> Node3D:
	var look: String = SWAP.get(city, {}).get(kind, kind)
	var g: Node3D
	match look:
		"basket": g = baskets()
		"carpet": g = carpet_rope(CARPETS[rng.randi() % 3])
		"stall": g = stall()
		"phaeton": g = phaeton()
		"cart": g = cart(length)
		"ramp": g = ramp()
		"caravan": g = caravan()
		"stump": g = stump()
		"branch": g = branch()
		"boulder": g = boulder()
		"salt": g = salt_pile()
		"crates": g = apple_crates()
		"loom": g = loom()
		"mud": g = mud_volcano()
		"art_boulder": g = art_boulder()
		"rock_arch": g = rock_arch()
		_: g = baskets()
	return g


## Səbətlər, küplər, qarpız: a low pile to jump.
static func baskets() -> Node3D:
	var g := Node3D.new()
	_c(g, Kit.tex("wicker", Vector2(2, 1)), 0.42, 0.62, Vector3(-0.5, 0.31, 0), Vector3.ZERO, 0.46)
	Kit.part(g, Kit.ring(0.44, 0.05), Kit.mat("#8c5c25"), Vector3(-0.5, 0.62, 0))
	for i in 5: # bread peeking out of the basket
		_e(g, "#e59a2f", 0.12, 0.06, 0.12, Vector3(-0.6 + (i % 3) * 0.1, 0.64 + (i / 3) * 0.05, -0.1 + (i % 2) * 0.2))
	for xz in [[0.35, 0.18], [0.65, -0.12]]: # two watermelons
		_e(g, "#2f7a2e", 0.3, 0.27, 0.3, Vector3(xz[0], 0.27, xz[1]))
		_b(g, "#1d4f1c", 0.06, 0.5, 0.58, Vector3(xz[0], 0.27, xz[1]))
	var jug := Kit.lathe(PackedVector2Array([Vector2(0, 0), Vector2(0.18, 0.02), Vector2(0.3, 0.25), Vector2(0.26, 0.55),
		Vector2(0.12, 0.7), Vector2(0.14, 0.82), Vector2(0, 0.82)]), 14)
	Kit.part(g, jug, Kit.mat("#b65a2b"), Vector3(0, 0, -0.35))
	Kit.part(g, Kit.ring(0.29, 0.02), Kit.mat("#efd9a0"), Vector3(0, 0.32, -0.35))
	Kit.ink(g)
	Kit.shadow(g, 0.95)
	return g


## A carpet hung on a rope across the lane: slide under it.
static func carpet_rope(tex: String) -> Node3D:
	var g := Node3D.new()
	for x in [-1.05, 1.05]:
		_c(g, Kit.tex("wood"), 0.06, 2.9, Vector3(x, 1.45, 0))
		_e(g, "#d8a53a", 0.08, 0.08, 0.08, Vector3(x, 2.92, 0))
	_c(g, "#d9c79c", 0.025, 2.1, Vector3(0, 2.62, 0), Vector3(0, 0, PI / 2))
	var c := Kit.part(g, Kit.plane(1.8, 1.42), Kit.tex(tex, Vector2.ONE, Color.WHITE, true), Vector3(0, 1.9, 0))
	c.set_meta("no_ink", true)
	c.set_meta("sway", true)
	for i in 12: # fringe
		_b(g, "#f4e2b8", 0.03, 0.12, 0.02, Vector3(-0.85 + i * 0.155, 1.13, 0))
	Kit.ink(g)
	return g


## Bazaar çadırı: a striped awning over a table of fruit and copper pots. Swerve round it.
static func stall() -> Node3D:
	var g := Node3D.new()
	for xz in [[-0.8, -0.6], [0.8, -0.6], [-0.8, 0.6], [0.8, 0.6]]:
		_c(g, "#6b4220", 0.05, 2.4, Vector3(xz[0], 1.2, xz[1]))
	_c(g, Kit.tex("awning", Vector2(4, 1)), 1.35, 0.8, Vector3(0, 2.75, 0), Vector3(0, PI / 4, 0), 0.0)
	_b(g, Kit.tex("wood"), 1.8, 0.9, 1.4, Vector3(0, 0.45, 0))
	_b(g, Kit.tex("carpet_blue"), 1.82, 0.7, 0.02, Vector3(0, 0.5, 0.71))
	var fruits := [["#e2452f", 0.12], ["#f29a2e", 0.12], ["#9fc93c", 0.11], ["#7a1f45", 0.1]]
	for i in 9:
		var f: Array = fruits[i % 4]
		_e(g, f[0], f[1], f[1], f[1], Vector3(-0.6 + (i % 3) * 0.6 + (i / 3) * 0.08, 1.0, -0.35 + (i / 3) * 0.35))
	for x in [0.6, -0.6]:
		_c(g, "#c46a2c", 0.2, 0.28, Vector3(x, 1.95, -0.4), Vector3.ZERO, 0.24)
	_e(g, "#b5162b", 0.14, 0.13, 0.14, Vector3(0, 1.0, 0.2)) # a nar on top
	Kit.ink(g)
	Kit.shadow(g, 1.1)
	return g


## Fayton: a black lacquer carriage, red seats, a canopy, the horse in front (toward you).
## Parts: wheels (spin), horse.
static func phaeton() -> Node3D:
	var root := Node3D.new()
	var g := Kit.joint(root, Vector3(0, 0, -1.6)) # the horse stands inside the obstacle's box
	var lac := "#2a2224"
	var gold := "#d8a53a"
	_b(g, lac, 1.5, 0.7, 2.6, Vector3(0, 1.0, 0))
	_b(g, "#a3241f", 1.3, 0.3, 1.0, Vector3(0, 1.45, -0.5))
	_b(g, "#a3241f", 1.3, 0.6, 0.15, Vector3(0, 1.75, -0.95))
	_b(g, "#3b2b24", 1.6, 0.1, 1.5, Vector3(0, 2.35, -0.5))
	for x in [-0.7, 0.7]:
		_c(g, gold, 0.04, 1.0, Vector3(x, 1.85, 0.2))
	_b(g, gold, 1.55, 0.06, 2.65, Vector3(0, 1.3, 0))
	var wheels := []
	for w in [[-0.82, 0.9, 0.55], [0.82, 0.9, 0.55], [-0.82, -0.9, 0.65], [0.82, -0.9, 0.65]]:
		var wj := Kit.joint(g, Vector3(w[0], w[2], w[1]))
		Kit.part(wj, Kit.ring(w[2], 0.07), Kit.mat("#6b2a1a"), Vector3.ZERO, Vector3(0, 0, PI / 2))
		for k in 3: # spokes
			_b(wj, "#8a4a2a", 0.04, w[2] * 2.0, 0.04, Vector3.ZERO, Vector3(k * PI / 3, 0, 0))
		_c(wj, gold, 0.08, 0.1, Vector3.ZERO, Vector3(0, 0, PI / 2))
		wheels.append(wj)
	var h := Characters.horse()
	h.position = Vector3(0, 0, 2.6)
	g.add_child(h)
	for x in [-0.35, 0.35]:
		_c(g, "#7b4a22", 0.04, 1.8, Vector3(x, 1.1, 1.8), Vector3(PI / 2, 0, 0))
	root.set_meta("parts", {"wheels": wheels, "horse": h})
	Kit.ink(root)
	Kit.shadow(g, 1.2, 2.6)
	return root


## Yük arabası: a flatbed of hay bales and sacks, a flat top you can run on.
static func cart(length: float) -> Node3D:
	var g := Node3D.new()
	_b(g, Kit.tex("wood", Vector2(1, length / 2.0)), 1.7, 0.25, length, Vector3(0, 0.75, 0))
	var z := -length / 2.0 + 0.7
	while z < length / 2.0:
		_b(g, Kit.tex("hay"), 1.6, 0.68, 1.3, Vector3(0, 1.24, z))
		_b(g, "#9c6b25", 1.62, 0.7, 0.08, Vector3(0, 1.24, z))
		z += 1.4
	for x in [-0.95, 0.95]:
		for zz in [-length / 2.0 + 0.9, length / 2.0 - 0.9]:
			Kit.part(g, Kit.ring(0.5, 0.07), Kit.mat("#6b2a1a"), Vector3(x, 0.55, zz), Vector3(0, 0, PI / 2))
			_c(g, "#d8a53a", 0.08, 0.1, Vector3(x, 0.55, zz), Vector3(0, 0, PI / 2))
	_e(g, "#c9a46a", 0.35, 0.3, 0.35, Vector3(0.4, 1.7, length / 2.0 - 0.6))
	Kit.ink(g)
	Kit.shadow(g, 1.2, length / 2.0)
	return g


## Taxta nərdivan: a plank ramp up onto a cart.
static func ramp() -> Node3D:
	var g := Node3D.new()
	var length := 4.0
	var h := 1.6
	_b(g, Kit.tex("wood", Vector2(1, 2)), 1.5, 0.12, Vector2(length, h).length(), Vector3(0, h / 2.0, 0), Vector3(atan2(h, length), 0, 0))
	for i in 6:
		_b(g, "#6b4220", 1.55, 0.05, 0.1, Vector3(0, (i + 0.5) / 6.0 * h + 0.08, length / 2.0 - (i + 0.5) / 6.0 * length))
	Kit.ink(g)
	return g


## Five camels in a line walking toward the runner (12 m: room to run along their backs). Parts: camels.
static func caravan() -> Node3D:
	var g := Node3D.new()
	var camels := []
	for i in 5:
		var c := Characters.camel()
		c.position.z = -i * 2.4 + 4.8
		g.add_child(c)
		camels.append(c)
	g.set_meta("parts", {"camels": camels})
	return g


# --- Qəbələ -------------------------------------------------------------------------------------

static func stump() -> Node3D:
	var g := Node3D.new()
	_c(g, "#7a4a22", 0.55, 0.8, Vector3(0, 0.4, 0), Vector3.ZERO, 0.5)
	_c(g, "#d9a86a", 0.5, 0.04, Vector3(0, 0.81, 0))
	Kit.part(g, Kit.ring(0.3, 0.02), Kit.mat("#a87a44"), Vector3(0, 0.83, 0))
	_c(g, "#f3ecd8", 0.05, 0.18, Vector3(0.4, 0.85, 0.2))
	_e(g, "#c8221d", 0.14, 0.07, 0.14, Vector3(0.4, 0.95, 0.2))
	for i in 4:
		_e(g, "#ffffff", 0.02, 0.02, 0.02, Vector3(0.4 + cos(i * 1.7) * 0.08, 1.0, 0.2 + sin(i * 1.7) * 0.08))
	Kit.ink(g)
	Kit.shadow(g, 0.7)
	return g


static func branch() -> Node3D:
	var g := Node3D.new()
	for x in [-1.05, 1.05]:
		_c(g, "#6b4220", 0.08, 1.9, Vector3(x, 0.95, 0))
		_c(g, "#6b4220", 0.06, 0.4, Vector3(x + 0.12, 1.95, 0), Vector3(0, 0, -0.5), 0.0)
	_c(g, "#5b3a22", 0.28, 2.6, Vector3(0, 1.6, 0), Vector3(0, 0, PI / 2))
	for i in 4:
		_e(g, "#3f8a3a", 0.35, 0.25, 0.3, Vector3(-0.9 + i * 0.6, 1.85, 0.1), Vector3.ZERO, 8)
	_c(g, "#2f6a34", 0.03, 0.4, Vector3(-0.4, 1.3, 0.1))
	_c(g, "#2f6a34", 0.03, 0.3, Vector3(0.5, 1.35, 0.1))
	Kit.ink(g)
	return g


static func boulder() -> Node3D:
	var g := Node3D.new()
	_e(g, "#8a8478", 1.0, 1.3, 0.9, Vector3(0, 1.2, 0), Vector3.ZERO, 7)
	_e(g, "#4f7a3a", 0.8, 0.3, 0.7, Vector3(0.1, 2.3, 0), Vector3.ZERO, 8)
	_e(g, "#8a8478", 0.45, 0.4, 0.4, Vector3(-0.7, 0.35, 0.4), Vector3.ZERO, 6)
	Kit.ink(g)
	Kit.shadow(g, 1.1)
	return g


# --- Naxçıvan, Quba, Qobustan ---------------------------------------------------------------------

static func salt_pile() -> Node3D:
	var g := Node3D.new()
	var i := 0
	for c in [[0, 0.35, 0, 0.45], [-0.5, 0.25, 0.1, 0.3], [0.5, 0.28, -0.1, 0.33], [0.1, 0.7, 0, 0.25], [-0.25, 0.2, 0.35, 0.2]]:
		_e(g, "#f4f0ff" if i % 2 else "#ffe6ef", c[3], c[3] * 1.5, c[3], Vector3(c[0], c[1], c[2]), Vector3(i, i * 2, 0), 4)
		i += 1
	Kit.ink(g)
	Kit.shadow(g, 0.9)
	return g


static func apple_crates() -> Node3D:
	var g := Node3D.new()
	for xy in [[-0.45, 0], [0.45, 0], [0, 0.45]]:
		_b(g, Kit.tex("wood"), 0.8, 0.42, 0.6, Vector3(xy[0], 0.21 + xy[1], 0))
		for k in 4:
			_e(g, "#c8221d", 0.12, 0.12, 0.12, Vector3(xy[0] - 0.25 + k * 0.17, 0.46 + xy[1], 0))
	Kit.ink(g)
	Kit.shadow(g, 0.9)
	return g


static func loom() -> Node3D:
	var g := Node3D.new()
	for x in [-0.85, 0.85]:
		_b(g, Kit.tex("wood"), 0.14, 2.8, 0.14, Vector3(x, 1.4, 0))
	for y in [2.7, 0.3]:
		_c(g, "#7a4a22", 0.08, 1.9, Vector3(0, y, 0), Vector3(0, 0, PI / 2))
	var c := Kit.part(g, Kit.plane(1.6, 1.2), Kit.tex("carpet_red", Vector2.ONE, Color.WHITE, true), Vector3(0, 0.95, 0))
	c.set_meta("no_ink", true)
	for i in 14:
		_b(g, "#f3ecd8", 0.015, 1.15, 0.015, Vector3(-0.78 + i * 0.12, 2.1, 0))
	_e(g, "#1d4f9a", 0.15, 0.15, 0.15, Vector3(0.5, 0.15, 0.4))
	_e(g, "#c89b45", 0.13, 0.13, 0.13, Vector3(-0.5, 0.13, 0.45))
	Kit.ink(g)
	Kit.shadow(g, 1.0)
	return g


static func mud_volcano() -> Node3D:
	var g := Node3D.new()
	_c(g, "#6e6a62", 0.75, 0.75, Vector3(0, 0.37, 0), Vector3.ZERO, 0.22)
	_c(g, "#4a4640", 0.22, 0.05, Vector3(0, 0.74, 0))
	var bub := _e(g, "#4a4640", 0.14, 0.14, 0.14, Vector3(0.05, 0.8, 0))
	bub.set_meta("bubble", true)
	bub.set_meta("keep", true)
	_c(g, "#5a5650", 0.9, 0.05, Vector3(0, 0.03, 0))
	g.set_meta("parts", {"bubble": bub})
	Kit.ink(g)
	return g


static func art_boulder() -> Node3D:
	var g := Node3D.new()
	_b(g, Kit.tex("rock_art"), 1.7, 2.6, 1.2, Vector3(0, 1.3, 0), Vector3(0, 0.15, 0))
	_e(g, "#8a6e52", 0.5, 0.4, 0.5, Vector3(0.7, 0.3, 0.6), Vector3.ZERO, 6)
	Kit.ink(g)
	Kit.shadow(g, 1.1)
	return g


static func rock_arch() -> Node3D:
	var g := Node3D.new()
	for x in [-1.05, 1.05]:
		_b(g, "#8a6e52", 0.4, 1.5, 0.6, Vector3(x, 0.75, 0))
	_b(g, Kit.tex("rock_art", Vector2(0.5, 0.3)), 2.7, 0.6, 0.6, Vector3(0, 1.75, 0))
	Kit.ink(g)
	return g


# --- pickups -----------------------------------------------------------------------------------

## A pickup's figure: bread, nar, magnet (Nənə's tray), shoe (çarıq), double (two təndirs), pole, simurq
## (a feather), letter (text), buta, stone, treat (city: the city's own treat).
static func pickup(kind: String, text: String = "", city: String = "baku") -> Node3D:
	var g := Node3D.new()
	match kind:
		"bread":
			_bread(g, 1.0)
		"nar":
			_e(g, "#b5162b", 0.34, 0.31, 0.34, Vector3.ZERO)
			_e(g, "#e4485a", 0.12, 0.1, 0.06, Vector3(-0.12, 0.1, 0.29))
			for i in 6:
				var a := i / 6.0 * TAU
				_c(g, "#7a0f1c", 0.05, 0.16, Vector3(cos(a) * 0.07, 0.36, sin(a) * 0.07), Vector3(sin(a) * 0.4, 0, -cos(a) * 0.4), 0.0)
		"magnet":
			_c(g, "#cf7a38", 0.42, 0.05, Vector3.ZERO, Vector3(PI / 2, 0, 0))
			Kit.part(g, Kit.ring(0.42, 0.03), Kit.mat("#e7a35a"), Vector3(0, 0, 0.03), Vector3(PI / 2, 0, 0))
			_c(g, "#a8572a", 0.25, 0.02, Vector3(0, 0, 0.04), Vector3(PI / 2, 0, 0))
			for i in 3:
				var b := Kit.joint(g, Vector3(-0.13 + i * 0.13, 0.03 * i, 0.08))
				b.scale = Vector3.ONE * 0.35
				_bread(b, 1.0)
		"shoe":
			_e(g, "#8a4a1c", 0.2, 0.15, 0.36, Vector3.ZERO)
			_c(g, "#8a4a1c", 0.08, 0.3, Vector3(0, 0.12, 0.36), Vector3(-0.7, 0, 0), 0.0)
			Kit.part(g, Kit.ring(0.2, 0.03), Kit.mat("#d8a53a"), Vector3(0, 0.12, -0.05))
			for xy in [[-0.32, 0.25], [0.3, 0.1], [0, 0.4]]:
				_c(g, Kit.mat("#fff1a0", true), 0.05, 0.16, Vector3(xy[0], xy[1], 0), Vector3.ZERO, 0.0)
		"double":
			for x in [-0.22, 0.22]:
				_e(g, "#b8743e", 0.24, 0.32, 0.24, Vector3(x, 0, 0))
				_e(g, Kit.mat("#ff8a1a", true), 0.09, 0.07, 0.05, Vector3(x, 0, 0.22))
				_c(g, "#8a4f26", 0.11, 0.05, Vector3(x, 0.31, 0))
		"pole":
			_c(g, "#c48a3e", 0.035, 2.4, Vector3.ZERO, Vector3(0, 0, PI / 2))
			for x in [-1.2, 1.2]:
				_e(g, "#c8322c", 0.12, 0.12, 0.12, Vector3(x, 0, 0))
				_c(g, "#f2b632", 0.08, 0.22, Vector3(x, -0.18, 0), Vector3(PI, 0, 0), 0.0)
			g.scale = Vector3.ONE * 0.6
		"simurq":
			_c(g, "#f5e6c0", 0.025, 1.0, Vector3.ZERO)
			_e(g, "#1f9e9a", 0.2, 0.42, 0.04, Vector3(0, 0.18, 0))
			_e(g, "#f2b632", 0.13, 0.27, 0.05, Vector3(0, 0.26, 0))
			_e(g, "#2c4fa0", 0.07, 0.1, 0.06, Vector3(0, 0.3, 0))
		"letter":
			_b(g, Kit.tex("wood"), 0.62, 0.62, 0.1, Vector3.ZERO)
			Kit.part(g, Kit.ring(0.44, 0.04), Kit.mat("#d8a53a"), Vector3.ZERO, Vector3(PI / 2, 0, 0))
			for face in [1.0, -1.0]:
				var l := Label3D.new()
				l.text = text
				l.font_size = 96
				l.pixel_size = 0.005
				l.modulate = Color("#4a2a0c")
				l.outline_size = 0
				l.position.z = 0.06 * face
				l.rotation.y = 0.0 if face > 0 else PI
				g.add_child(l)
		"buta":
			_c(g, Kit.tex("buta_stone"), 0.32, 0.12, Vector3.ZERO, Vector3(PI / 2, 0, 0))
		"stone":
			_e(g, Kit.mat("#c9a0f0", true), 0.2, 0.34, 0.2, Vector3.ZERO, Vector3.ZERO, 4)
		"treat":
			_treat(g, String(TREATS.get(city, "halva")))
	Kit.ink(g)
	return g


static func _bread(g: Node3D, s: float) -> void: # a puffed golden round with a scored top, standing up
	# two pieces, no outline: a street can hold forty of them at once, so each must be cheap to draw
	_c(g, "#c27a22", 0.33 * s, 0.1 * s, Vector3.ZERO, Vector3(PI / 2, 0, 0)).set_meta("no_ink", true)
	_e(g, Kit.tex("bread"), 0.32 * s, 0.32 * s, 0.1 * s, Vector3(0, 0, 0.04 * s), Vector3(0, 0, 0)).set_meta("no_ink", true)


static func _treat(g: Node3D, kind: String) -> void:
	match kind:
		"halva": # Şəki halvası: a diamond of rice-net pastry
			_b(g, "#c8522a", 0.36, 0.14, 0.36, Vector3.ZERO, Vector3(0, PI / 4, 0))
			_b(g, "#e07b3a", 0.34, 0.04, 0.34, Vector3(0, 0.09, 0), Vector3(0, PI / 4, 0))
			for i in [-1, 0, 1]:
				_b(g, "#f2b07a", 0.42, 0.02, 0.02, Vector3(0, 0.115, i * 0.08), Vector3(0, PI / 4, 0))
			_e(g, "#7a4a22", 0.05, 0.035, 0.05, Vector3(0, 0.13, 0))
			g.rotation.x = 0.6
		"finduq": # three hazelnuts with green husks
			for xy in [[-0.12, 0], [0.12, 0], [0, 0.17]]:
				_e(g, "#9a5a26", 0.12, 0.13, 0.12, Vector3(xy[0], xy[1], 0))
				_c(g, "#7aa83a", 0.1, 0.12, Vector3(xy[0], xy[1] + 0.13, 0), Vector3.ZERO, 0.0)
		"bottle": # Badamlı mineral water
			_c(g, Kit.mat(Color(0.37, 0.7, 0.91, 0.85)), 0.13, 0.42, Vector3.ZERO)
			_c(g, Kit.mat(Color(0.37, 0.7, 0.91, 0.85)), 0.05, 0.14, Vector3(0, 0.28, 0))
			_c(g, "#1d4f9a", 0.06, 0.05, Vector3(0, 0.37, 0))
			_c(g, "#f6f2ea", 0.135, 0.14, Vector3.ZERO)
		"tangerine":
			_e(g, "#f28a1a", 0.26, 0.23, 0.26, Vector3.ZERO)
			_e(g, "#2f7a2e", 0.12, 0.03, 0.07, Vector3(0.08, 0.24, 0), Vector3(0, 0, 0.5))
		_: # apple
			_e(g, "#c8221d", 0.26, 0.24, 0.26, Vector3.ZERO)
			_c(g, "#6b4220", 0.02, 0.12, Vector3(0, 0.27, 0))
			_e(g, "#4a9a3a", 0.1, 0.03, 0.06, Vector3(0.08, 0.3, 0), Vector3(0, 0, 0.5))


## Nənə's təndir (story pictures).
static func tendir() -> Node3D:
	var g := Node3D.new()
	_e(g, "#b8743e", 0.5, 0.4, 0.5, Vector3(0, 0.38, 0))
	_c(g, "#8a5428", 0.2, 0.12, Vector3(0, 0.8, 0), Vector3.ZERO, 0.24)
	_e(g, Kit.mat("#ff8a1a", true), 0.17, 0.06, 0.17, Vector3(0, 0.84, 0))
	Kit.ink(g)
	Kit.shadow(g, 0.5)
	return g
