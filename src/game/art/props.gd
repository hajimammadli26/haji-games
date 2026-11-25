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
## Art bible §4: Antique Gold trims (bright gold is bread's), Power-up Turquoise and its halo, Nar Crimson, cream.
const AGOLD := "#c89b45"
const TURQ := "#19b3a6"
const HALO := "#e9fffb"
const NAR := "#a0173f"
const NAR_HI := "#e0405f"
const CREAM := "#f0dfb4"
const ROCK := "#8a7560" ## Qobustan's dusty ochre rock


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


## A carpet hung on a rope across the lane: slide under it. Its bottom edge (1.15 m) wears a row of big tassels
## and the posts carry a cream band at that height, so the gap underneath reads from far off.
static func carpet_rope(tex: String) -> Node3D:
	var g := Node3D.new()
	for x in [-1.05, 1.05]:
		_c(g, Kit.tex("wood"), 0.07, 2.9, Vector3(x, 1.45, 0))
		_e(g, AGOLD, 0.11, 0.11, 0.11, Vector3(x, 2.94, 0))
		_c(g, "#6b4220", 0.16, 0.12, Vector3(x, 0.06, 0), Vector3.ZERO, 0.11) # a foot so the post stands
	_c(g, "#d9c79c", 0.03, 2.1, Vector3(0, 2.66, 0), Vector3(0, 0, PI / 2))
	var c := Kit.part(g, Kit.plane(1.8, 1.42), Kit.tex(tex, Vector2.ONE, Color.WHITE, true), Vector3(0, 1.9, 0))
	c.set_meta("no_ink", true)
	c.set_meta("sway", true)
	_b(g, "#6b1f2d", 1.84, 0.06, 0.05, Vector3(0, 2.62, 0)) # the wine rod the carpet hangs from
	for i in 7: # tassels in Antique Gold: the bottom edge, clear against the street
		var x := -0.81 + i * 0.27
		_c(g, AGOLD, 0.035, 0.2, Vector3(x, 1.12, 0.02), Vector3.ZERO, 0.0).set_meta("ink", true)
		_e(g, AGOLD, 0.04, 0.04, 0.04, Vector3(x, 1.2, 0.02))
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
	_e(g, NAR, 0.14, 0.13, 0.14, Vector3(0, 1.0, 0.2)) # a nar on top
	Kit.ink(g)
	Kit.shadow(g, 1.1)
	return g


## Fayton: a black lacquer carriage, red seats, a canopy, the horse in front (toward you).
## Parts: wheels (spin), horse.
static func phaeton() -> Node3D:
	var root := Node3D.new()
	var g := Kit.joint(root, Vector3(0, 0, -1.6)) # the horse stands inside the obstacle's box
	var lac := "#2a2224"
	var gold := AGOLD
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
		_b(g, Kit.tex("hay", Vector2.ONE, Color("#b9b29c")), 1.6, 0.68, 1.3, Vector3(0, 1.24, z)) # toned: bread owns bright gold
		_b(g, "#9c6b25", 1.62, 0.7, 0.08, Vector3(0, 1.24, z))
		z += 1.4
	for x in [-0.95, 0.95]:
		for zz in [-length / 2.0 + 0.9, length / 2.0 - 0.9]:
			Kit.part(g, Kit.ring(0.5, 0.07), Kit.mat("#6b2a1a"), Vector3(x, 0.55, zz), Vector3(0, 0, PI / 2))
			_c(g, AGOLD, 0.08, 0.1, Vector3(x, 0.55, zz), Vector3(0, 0, PI / 2))
	_e(g, "#c9a46a", 0.35, 0.3, 0.35, Vector3(0.4, 1.7, length / 2.0 - 0.6))
	Kit.ink(g)
	Kit.shadow(g, 1.2, length / 2.0)
	return g


## Taxta nərdivan: a plank ramp up onto a cart; side rails and two cream chevrons point the way up.
static func ramp() -> Node3D:
	var g := Node3D.new()
	var length := 4.0
	var h := 1.6
	var slope := atan2(h, length)
	_b(g, Kit.tex("wood", Vector2(1, 2)), 1.5, 0.12, Vector2(length, h).length(), Vector3(0, h / 2.0, 0), Vector3(slope, 0, 0))
	for i in 6:
		_b(g, "#6b4220", 1.55, 0.05, 0.1, Vector3(0, (i + 0.5) / 6.0 * h + 0.08, length / 2.0 - (i + 0.5) / 6.0 * length))
	var deck := Kit.joint(g, Vector3(0, h / 2.0, 0)) # the plank's own frame: +z runs downhill
	deck.rotation.x = slope
	for x in [-0.78, 0.78]:
		_b(deck, "#6b4220", 0.1, 0.16, Vector2(length, h).length(), Vector3(x, 0.08, 0))
	for z in [-0.6, 0.7]:
		for sx in [-1.0, 1.0]:
			_b(deck, CREAM, 0.12, 0.03, 0.62, Vector3(sx * 0.2, 0.08, z), Vector3(0, sx * 0.8, 0)).set_meta("ink", true)
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

## Kötük: a low stump to jump, roots spread, an orange mushroom on top.
static func stump() -> Node3D:
	var g := Node3D.new()
	_c(g, "#7a4a22", 0.55, 0.8, Vector3(0, 0.4, 0), Vector3.ZERO, 0.5)
	_c(g, "#d9a86a", 0.5, 0.04, Vector3(0, 0.81, 0))
	Kit.part(g, Kit.ring(0.3, 0.02), Kit.mat("#a87a44"), Vector3(0, 0.83, 0))
	for i in 4: # roots
		var a := i * TAU / 4.0 + 0.4
		_e(g, "#6b4220", 0.3, 0.12, 0.13, Vector3(cos(a) * 0.55, 0.08, sin(a) * 0.55), Vector3(0, -a, 0))
	_c(g, "#f3ecd8", 0.05, 0.18, Vector3(0.3, 0.9, 0.2))
	_e(g, "#d0552a", 0.15, 0.08, 0.15, Vector3(0.3, 1.0, 0.2))
	for i in 4:
		_e(g, "#fff3dc", 0.025, 0.02, 0.025, Vector3(0.3 + cos(i * 1.7) * 0.08, 1.06, 0.2 + sin(i * 1.7) * 0.08))
	Kit.ink(g)
	Kit.shadow(g, 0.7)
	return g


## A fallen log caught between two forked trunks: slide under it. Leaves and vines hang to 1.2 m.
static func branch() -> Node3D:
	var g := Node3D.new()
	for x in [-1.05, 1.05]:
		_c(g, "#6b4220", 0.13, 1.75, Vector3(x, 0.87, 0), Vector3.ZERO, 0.1)
		_c(g, "#6b4220", 0.08, 0.55, Vector3(x - signf(x) * 0.12, 1.95, 0), Vector3(0, 0, signf(x) * 0.5), 0.05)
		_c(g, "#6b4220", 0.08, 0.5, Vector3(x + signf(x) * 0.1, 1.95, 0), Vector3(0, 0, -signf(x) * 0.4), 0.05)
		_e(g, "#5b3a22", 0.2, 0.08, 0.2, Vector3(x, 0.04, 0))
	_c(g, "#5b3a22", 0.28, 2.7, Vector3(0, 1.6, 0), Vector3(0, 0, PI / 2))
	for x in [-1.35, 1.35]:
		_c(g, "#d9a86a", 0.25, 0.02, Vector3(x, 1.6, 0), Vector3(0, 0, PI / 2)) # cut ends
	for i in 5:
		_e(g, "#3f7f52", 0.34, 0.24, 0.3, Vector3(-1.0 + i * 0.5, 1.9, 0.05), Vector3.ZERO, 8)
	for i in 6: # leaves hanging below the log: the low edge
		var x := -0.9 + i * 0.36
		_c(g, "#2f6b4f", 0.02, 0.3, Vector3(x, 1.38, 0.18))
		_e(g, "#3f7f52", 0.09, 0.12, 0.05, Vector3(x, 1.24, 0.18))
	Kit.ink(g)
	return g


## Qaya: a tall mossy boulder blocking the lane: swerve round it.
static func boulder() -> Node3D:
	var g := Node3D.new()
	_e(g, "#8a8478", 1.0, 1.3, 0.9, Vector3(0, 1.2, 0), Vector3.ZERO, 7)
	_e(g, "#6f6a60", 0.55, 0.6, 0.5, Vector3(0.55, 0.55, 0.35), Vector3(0, 0.5, 0), 6)
	_e(g, "#4f7a3a", 0.8, 0.3, 0.7, Vector3(0.1, 2.3, 0), Vector3.ZERO, 8)
	_e(g, "#4f7a3a", 0.3, 0.2, 0.25, Vector3(-0.6, 1.9, 0.45), Vector3.ZERO, 6)
	_e(g, "#8a8478", 0.45, 0.4, 0.4, Vector3(-0.7, 0.35, 0.4), Vector3.ZERO, 6)
	Kit.ink(g)
	Kit.shadow(g, 1.1)
	return g


# --- Naxçıvan, Quba, Qobustan ---------------------------------------------------------------------

## Duz: a low heap of Naxçıvan rock salt, pink and white crystals pointing up out of a grey mound. Jump it.
static func salt_pile() -> Node3D:
	var g := Node3D.new()
	_e(g, "#a99a96", 0.75, 0.22, 0.6, Vector3(0, 0.05, 0), Vector3.ZERO, 10)
	var i := 0
	for c in [[0, 0.0, 0.85, 0.2], [-0.38, 0.1, 0.6, 0.15], [0.38, -0.05, 0.65, 0.16], [-0.2, 0.3, 0.45, 0.12],
			[0.22, 0.28, 0.5, 0.13], [-0.6, -0.1, 0.4, 0.11], [0.6, 0.15, 0.38, 0.11]]:
		var tilt := Vector3((c[1]) * 0.6, i * 1.1, -c[0] * 0.5)
		Kit.part(g, Kit.cyl(0.0, c[3], c[2], 5), Kit.mat("#f6eef6" if i % 2 else "#f2b8c6"), Vector3(c[0], c[2] * 0.5, c[1]), tilt).set_meta("ink", true)
		i += 1
	Kit.ink(g)
	Kit.shadow(g, 0.9)
	return g


static func apple_crates() -> Node3D:
	var g := Node3D.new()
	for xy in [[-0.45, 0], [0.45, 0], [0, 0.45]]:
		_b(g, Kit.tex("wood"), 0.8, 0.42, 0.6, Vector3(xy[0], 0.21 + xy[1], 0))
		for k in 4:
			_e(g, "#c2412d" if (k + int(xy[1] > 0.0)) % 3 else "#9fc93c", 0.12, 0.12, 0.12, Vector3(xy[0] - 0.25 + k * 0.17, 0.46 + xy[1], 0))
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
	_e(g, AGOLD, 0.13, 0.13, 0.13, Vector3(-0.5, 0.13, 0.45))
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
	_c(g, "#4a4640", 0.36, 0.18, Vector3(0, 0.66, 0), Vector3.ZERO, 0.235) # the wet dark mud round the crater
	g.set_meta("parts", {"bubble": bub})
	Kit.ink(g)
	return g


## A carved Qobustan boulder (petroglyphs on its face), tall: swerve round it.
static func art_boulder() -> Node3D:
	var g := Node3D.new()
	_b(g, Kit.tex("rock_art"), 1.7, 2.6, 1.2, Vector3(0, 1.3, 0), Vector3(0, 0.15, 0))
	_e(g, ROCK, 0.95, 0.4, 0.68, Vector3(0, 2.55, -0.05), Vector3(0, 0.15, 0), 7) # a rounded crown
	_e(g, ROCK, 0.3, 1.1, 0.55, Vector3(-0.82, 1.15, 0), Vector3(0, 0.15, 0), 7) # rounded flanks
	_e(g, ROCK, 0.3, 1.0, 0.55, Vector3(0.85, 1.1, -0.2), Vector3(0, 0.15, 0), 7)
	_e(g, "#7a6450", 0.5, 0.4, 0.5, Vector3(0.7, 0.3, 0.6), Vector3.ZERO, 6)
	Kit.ink(g)
	Kit.shadow(g, 1.1)
	return g


## A natural rock arch over the lane: slide under. Stacked rock pillars and a carved lintel.
static func rock_arch() -> Node3D:
	var g := Node3D.new()
	for x in [-1.05, 1.05]:
		_e(g, ROCK, 0.42, 0.95, 0.42, Vector3(x, 0.9, 0), Vector3(0, x, 0), 7)
		_e(g, "#7a6450", 0.3, 0.3, 0.3, Vector3(x * 1.2, 0.25, 0.2), Vector3.ZERO, 6)
	_b(g, Kit.tex("rock_art", Vector2(0.5, 0.3)), 2.3, 0.6, 0.6, Vector3(0, 1.85, 0))
	_e(g, ROCK, 1.2, 0.18, 0.34, Vector3(0, 2.18, 0), Vector3.ZERO, 8) # a rounded top
	_e(g, "#7a6450", 1.05, 0.08, 0.28, Vector3(0, 1.55, 0.05), Vector3.ZERO, 8) # the dark underside: the gap's roof
	Kit.ink(g)
	return g


# --- pickups -----------------------------------------------------------------------------------

## A pickup's figure: bread, nar, magnet (Nənə's tray), shoe (çarıq), double (two təndirs), pole, simurq
## (a feather), letter (text), buta, stone, treat (city: the city's own treat). Power-ups sit on a turquoise
## badge in a white halo (art bible §4: "round badge with icon, white halo"), so they read as magic, not food.
## Each is merged to one draw per material (bread: one) (a street can show a dozen pickups at once).
static func pickup(kind: String, text: String = "", city: String = "baku") -> Node3D:
	var g := Node3D.new()
	match kind:
		"bread":
			_bread(g, 1.0)
		"nar":
			_e(g, NAR, 0.34, 0.31, 0.34, Vector3.ZERO)
			_e(g, NAR_HI, 0.12, 0.1, 0.06, Vector3(-0.12, 0.1, 0.29))
			_c(g, "#6b1f2d", 0.1, 0.08, Vector3(0, 0.32, 0))
			for i in 6: # the crown
				var a := i / 6.0 * TAU
				_c(g, "#6b1f2d", 0.05, 0.16, Vector3(cos(a) * 0.07, 0.38, sin(a) * 0.07), Vector3(sin(a) * 0.4, 0, -cos(a) * 0.4), 0.0)
		"magnet": # Nənənin sinisi: a copper tray heaped with buns
			_badge(g, 0.5, -0.06)
			_c(g, "#cf7a38", 0.36, 0.05, Vector3.ZERO, Vector3(PI / 2, 0, 0))
			Kit.part(g, Kit.ring(0.36, 0.035), Kit.mat("#a8572a"), Vector3(0, 0, 0.03), Vector3(PI / 2, 0, 0))
			for i in 3:
				var b := Kit.joint(g, Vector3(-0.14 + i * 0.14, -0.06 + 0.07 * (i % 2), 0.08))
				b.scale = Vector3.ONE * 0.4
				_bread(b, 1.0)
		"shoe": # Sehrli çarıq: a leather moccasin with a curled toe and turquoise wings, side on
			_badge(g, 0.5, -0.22)
			_e(g, "#6b3a1a", 0.34, 0.07, 0.15, Vector3(0, -0.15, 0))
			_e(g, "#9a5524", 0.3, 0.16, 0.16, Vector3(-0.03, -0.05, 0))
			_c(g, "#9a5524", 0.08, 0.26, Vector3(0.31, 0.0, 0), Vector3(0, 0, -0.9), 0.0)
			_e(g, "#4a2410", 0.13, 0.03, 0.1, Vector3(-0.1, 0.1, 0))
			Kit.part(g, Kit.ring(0.14, 0.025), Kit.mat(AGOLD), Vector3(-0.1, 0.1, 0))
			for side in [1.0, -1.0]:
				_e(g, HALO, 0.22, 0.09, 0.03, Vector3(-0.32, 0.15, 0.15 * side), Vector3(0, 0, 0.6))
				_e(g, TURQ, 0.16, 0.06, 0.035, Vector3(-0.3, 0.1, 0.16 * side), Vector3(0, 0, 0.45))
		"double": # Qoşa təndir: two clay ovens, fire in their mouths, a bread on each
			_badge(g, 0.52, -0.24)
			for x in [-0.2, 0.2]:
				_c(g, "#b8743e", 0.2, 0.34, Vector3(x, -0.08, 0.02), Vector3.ZERO, 0.13)
				_c(g, "#8a4f26", 0.14, 0.05, Vector3(x, 0.11, 0.02))
				_e(g, Kit.mat("#ff8a1a", true), 0.08, 0.07, 0.03, Vector3(x, -0.13, 0.2))
				var b := Kit.joint(g, Vector3(x, 0.25, 0.04))
				b.scale = Vector3.ONE * 0.36
				_bread(b, 1.0)
		"pole": # Kəndirbaz çubuğu: a striped balancing pole with turquoise tassels
			_badge(g, 0.62, -0.1)
			_c(g, "#8f2b2b", 0.05, 2.4, Vector3.ZERO, Vector3(0, 0, PI / 2))
			for k in 7:
				Kit.part(g, Kit.ring(0.055, 0.022), Kit.mat(AGOLD), Vector3(-0.9 + k * 0.3, 0, 0), Vector3(0, 0, PI / 2))
			for x in [-1.2, 1.2]:
				_e(g, TURQ, 0.15, 0.15, 0.15, Vector3(x, 0, 0))
				_c(g, HALO, 0.1, 0.26, Vector3(x, -0.2, 0), Vector3(PI, 0, 0), 0.0)
			g.scale = Vector3.ONE * 0.6
		"simurq": # a Simurq feather, flame orange on the turquoise badge
			_badge(g, 0.52, -0.06)
			var f := Kit.joint(g, Vector3(0, -0.05, 0.02))
			f.rotation.z = -0.35
			_c(f, "#f5e6c0", 0.025, 0.95, Vector3(0, -0.02, 0))
			_e(f, "#e86a2a", 0.2, 0.4, 0.04, Vector3(0, 0.16, 0))
			_e(f, AGOLD, 0.13, 0.26, 0.05, Vector3(0, 0.24, 0))
			_e(f, "#2c4fa0", 0.07, 0.09, 0.06, Vector3(0, 0.3, 0))
			_e(f, HALO, 0.03, 0.04, 0.065, Vector3(0, 0.31, 0))
		"letter": # a cream medallion with an Antique Gold rim, the letter in ink, both faces
			_c(g, CREAM, 0.36, 0.08, Vector3.ZERO, Vector3(PI / 2, 0, 0))
			Kit.part(g, Kit.ring(0.38, 0.045), Kit.mat(AGOLD), Vector3.ZERO, Vector3(PI / 2, 0, 0))
			for face in [1.0, -1.0]:
				var l := Label3D.new()
				l.text = text
				l.font_size = 128
				l.pixel_size = 0.004
				l.modulate = Color("#2a1e24")
				l.outline_size = 0
				l.double_sided = false
				l.position.z = 0.045 * face
				l.rotation.y = 0.0 if face > 0 else PI
				g.add_child(l)
		"buta":
			_c(g, Kit.tex("buta_stone"), 0.32, 0.12, Vector3.ZERO, Vector3(PI / 2, 0, 0))
		"stone": # Pəri's magic stone: a violet gem with a glowing facet
			_e(g, "#8e4fd6", 0.2, 0.34, 0.2, Vector3.ZERO, Vector3.ZERO, 4)
			_e(g, Kit.mat("#e3c8ff", true), 0.07, 0.15, 0.04, Vector3(-0.05, 0.05, 0.15), Vector3.ZERO, 4)
		"treat":
			_treat(g, String(TREATS.get(city, "halva")))
	Kit.ink(g)
	Kit.merge(g)
	return g


## A power-up's badge: a turquoise disc in a glowing white halo, behind the icon (z: how far behind).
static func _badge(g: Node3D, r: float, z: float) -> void:
	_c(g, TURQ, r, 0.05, Vector3(0, 0, z), Vector3(PI / 2, 0, 0))
	Kit.part(g, Kit.ring(r + 0.03, 0.035), Kit.mat(HALO, true), Vector3(0, 0, z), Vector3(PI / 2, 0, 0))


static func _bread(g: Node3D, s: float) -> void: # a puffed golden round with a scored top, standing up
	# one material for crust and face, no outline: merged it is a single draw, and a street holds forty
	var m := Kit.tex("bread")
	_c(g, m, 0.33 * s, 0.1 * s, Vector3.ZERO, Vector3(PI / 2, 0, 0)).set_meta("no_ink", true)
	_e(g, m, 0.32 * s, 0.32 * s, 0.1 * s, Vector3(0, 0, 0.04 * s), Vector3(0, 0, 0)).set_meta("no_ink", true)


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
			_e(g, "#c2412d", 0.26, 0.24, 0.26, Vector3.ZERO) # orange-red: Player Red is Cırtdan's alone
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
