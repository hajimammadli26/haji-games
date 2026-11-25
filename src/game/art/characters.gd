## The living figures: Cırtdan and the other playable characters (one builder, a look decides the hat and
## colours), the Div, Nənə, the caravan's camel, the phaeton's horse, the Simurq and the flying carpet.
## Each has joints for the animator (see Animator) in its meta "parts". Built from Kit pieces, inked.
## Spec: the web prototype's makeCirtdan / makeDiv / makeNene / makeCamel / makeHorse / makeSimurq.
##
## Usage:
##   var c := Characters.runner(progress.look())   # faces -z (where he runs)
##   var d := Characters.div()                       # faces +z
class_name Characters
extends RefCounted

const SKIN := "#f2c08f"


## An ellipsoid piece: radii rx, ry, rz (sizes baked in so outlines stay even).
static func _egg(parent: Node3D, color: Variant, rx: float, ry: float, rz: float, pos: Vector3, rot := Vector3.ZERO, segs := 18) -> MeshInstance3D:
	var m: Material = color if color is Material else Kit.mat(color)
	return Kit.part(parent, Kit.ball(rx, ry * 2.0, segs), m, pos, rot, Vector3(1, 1, rz / rx))


static func _cyl(parent: Node3D, color: Variant, r: float, h: float, pos: Vector3, rot := Vector3.ZERO, r_top := -1.0) -> MeshInstance3D:
	var m: Material = color if color is Material else Kit.mat(color)
	return Kit.part(parent, Kit.cyl(r if r_top < 0.0 else r_top, r, h), m, pos, rot)


static func _box(parent: Node3D, color: Variant, sx: float, sy: float, sz: float, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var m: Material = color if color is Material else Kit.mat(color)
	return Kit.part(parent, Kit.box(sx, sy, sz), m, pos, rot)


## A playable character from a look (Catalog look plus costume): hat, hat_color, vest, trim, shirt, pants,
## braids, sprig. Faces -z. Parts: rig, hip, torso, head, leg_l, leg_r, arm_l, arm_r, sack, hat, tongue, brow_l, brow_r.
static func runner(look: Dictionary = {}) -> Node3D:
	var vest := String(look.get("vest", "#1f4f8f"))
	var trim := String(look.get("trim", "#f1c34a"))
	var shirt := String(look.get("shirt", "#f3ecd8"))
	var pants := String(look.get("pants", "#4b3221"))
	var hat := String(look.get("hat", "papaq"))
	var hat_c := String(look.get("hat_color", "#c8221d"))
	var g := Node3D.new()
	var rig := Kit.joint(g)
	var hip := Kit.joint(rig, Vector3(0, 0.52, 0))
	var legs := []
	for sx in [-0.12, 0.12]:
		var leg := Kit.joint(hip, Vector3(sx, 0, 0))
		_cyl(leg, pants, 0.085, 0.38, Vector3(0, -0.19, 0), Vector3.ZERO, 0.075)
		_egg(leg, "#7a3b16", 0.1, 0.07, 0.16, Vector3(0, -0.42, -0.04)) # çarıq, toe forward
		_cyl(leg, "#c0302a", 0.07, 0.03, Vector3(0, -0.37, 0)) # the çarıq's red tie
		legs.append(leg)
	var torso := Kit.joint(rig, Vector3(0, 0.52, 0))
	_cyl(torso, shirt, 0.2, 0.42, Vector3(0, 0.21, 0), Vector3.ZERO, 0.17)
	var vm := Kit.tex("vest_%s_%s" % [vest.trim_prefix("#"), trim.trim_prefix("#")])
	_box(torso, vm, 0.42, 0.36, 0.34, Vector3(0, 0.24, 0))
	_cyl(torso, "#c0302a", 0.215, 0.07, Vector3(0, 0.04, 0)) # belt
	_egg(torso, "#d8a53a", 0.04, 0.04, 0.02, Vector3(0, 0.04, -0.21)) # buckle
	var sack := Kit.joint(torso, Vector3(0, 0.26, 0.22))
	_egg(sack, "#c9a46a", 0.24, 0.27, 0.16, Vector3.ZERO)
	_box(sack, "#7d5a9b", 0.12, 0.12, 0.02, Vector3(0.06, 0.05, 0.155)) # a patch
	_cyl(sack, "#8a6a44", 0.04, 0.06, Vector3(0, 0.27, 0)) # the knot
	_box(torso, "#8a6a44", 0.04, 0.5, 0.03, Vector3(0.14, 0.22, -0.16), Vector3(0, 0, 0.55)) # the strap across the chest
	var arms := []
	for sx in [-0.25, 0.25]:
		var arm := Kit.joint(torso, Vector3(sx, 0.38, 0))
		_cyl(arm, shirt, 0.06, 0.3, Vector3(0, -0.15, 0), Vector3.ZERO, 0.065)
		_egg(arm, SKIN, 0.07, 0.07, 0.07, Vector3(0, -0.32, 0))
		arms.append(arm)
	var head := Kit.joint(torso, Vector3(0, 0.62, 0))
	_egg(head, SKIN, 0.3, 0.29, 0.28, Vector3(0, 0.18, 0), Vector3.ZERO, 24)
	for sx in [-0.29, 0.29]:
		_egg(head, SKIN, 0.05, 0.08, 0.05, Vector3(sx, 0.17, 0))
	for sx in [-0.11, 0.11]: # big eyes, facing where he runs (-z)
		_egg(head, "#ffffff", 0.085, 0.1, 0.06, Vector3(sx, 0.2, -0.24))
		_egg(head, "#2a1a10", 0.045, 0.055, 0.03, Vector3(sx, 0.2, -0.29))
		_egg(head, "#ffffff", 0.014, 0.014, 0.01, Vector3(sx + 0.015, 0.22, -0.315)) # a glint
		_egg(head, "#f08a8a", 0.05, 0.03, 0.02, Vector3(sx * 1.6, 0.08, -0.24)) # rosy cheeks
	var brows := []
	for sx in [-0.11, 0.11]:
		brows.append(_box(head, "#3b2414", 0.1, 0.022, 0.02, Vector3(sx, 0.32, -0.27), Vector3(0, 0, -signf(sx) * 0.15)))
	_egg(head, "#e9a776", 0.05, 0.04, 0.04, Vector3(0, 0.12, -0.28))
	var smile := _egg(head, "#8a2a1c", 0.07, 0.025, 0.02, Vector3(0, 0.03, -0.265))
	if hat == "bald":
		smile.scale.x = 1.4 # Keçəl's cheeky grin
	var tongue := _box(head, "#e05a6a", 0.08, 0.03, 0.12, Vector3(0, 0.02, -0.32))
	tongue.visible = false
	var hatn := Kit.joint(head)
	_hat(hatn, head, torso, hat, hat_c, look)
	g.set_meta("parts", {"rig": rig, "hip": hip, "torso": torso, "head": head, "leg_l": legs[0], "leg_r": legs[1],
		"arm_l": arms[0], "arm_r": arms[1], "sack": sack, "hat": hatn, "tongue": tongue, "brow_l": brows[0], "brow_r": brows[1]})
	Kit.ink(g)
	Kit.shadow(g, 0.34)
	return g


static func _hat(h: Node3D, head: Node3D, torso: Node3D, hat: String, c: String, look: Dictionary) -> void:
	match hat:
		"papaq": # Cırtdan's red araxçın with a fur band
			_egg(head, "#3b2414", 0.27, 0.16, 0.2, Vector3(0, 0.3, 0.1))
			_cyl(h, c, 0.26, 0.22, Vector3(0, 0.42, 0), Vector3.ZERO, 0.24)
			Kit.part(h, Kit.ring(0.25, 0.06), Kit.mat("#7a1512"), Vector3(0, 0.32, 0))
			_egg(h, c, 0.24, 0.07, 0.24, Vector3(0, 0.53, 0))
			_egg(h, "#f1c34a", 0.035, 0.035, 0.035, Vector3(0, 0.6, 0)) # a little gold knot on top
		"scarf": # Tıq-Tıq: a red kəlağayı tied at the back, two long braids
			_egg(head, "#2a160c", 0.31, 0.25, 0.29, Vector3(0, 0.27, 0.03))
			_egg(h, c, 0.32, 0.17, 0.3, Vector3(0, 0.37, 0.02))
			_cyl(h, c, 0.08, 0.2, Vector3(0, 0.32, 0.32), Vector3(1.9, 0, 0), 0.0)
			for sx in [-0.17, 0.17]:
				_cyl(h, "#2a160c", 0.05, 0.42, Vector3(sx, -0.05, 0.16))
				_egg(h, c, 0.06, 0.05, 0.06, Vector3(sx, -0.27, 0.16))
		"bald": # Keçəl: a shiny bald head
			_egg(h, "#ffe7c4", 0.1, 0.06, 0.08, Vector3(-0.08, 0.44, -0.12))
		"winter": # a white fur hat with ear flaps
			_egg(h, c, 0.3, 0.22, 0.3, Vector3(0, 0.38, 0))
			for sx in [-0.27, 0.27]:
				_egg(h, c, 0.08, 0.16, 0.12, Vector3(sx, 0.16, 0))
			_egg(h, "#c8221d", 0.07, 0.07, 0.07, Vector3(0, 0.62, 0))
		"sailor": # a white cap with a blue band and two ribbons
			_cyl(h, c, 0.3, 0.1, Vector3(0, 0.42, 0))
			_cyl(h, "#1d4f9a", 0.27, 0.07, Vector3(0, 0.36, 0))
			for sx in [-0.05, 0.05]:
				_box(h, "#1d4f9a", 0.04, 0.2, 0.02, Vector3(sx, 0.24, 0.28))
		"crown": # Məlikməmməd: a golden crown, a red cape, a sword
			_cyl(h, c, 0.22, 0.16, Vector3(0, 0.45, 0), Vector3.ZERO, 0.24)
			for i in 5:
				var a := i / 5.0 * TAU
				_cyl(h, c, 0.05, 0.14, Vector3(cos(a) * 0.2, 0.58, sin(a) * 0.2), Vector3.ZERO, 0.0)
			_egg(h, "#c8221d", 0.05, 0.05, 0.03, Vector3(0, 0.46, -0.22))
			_egg(head, "#2a160c", 0.28, 0.14, 0.2, Vector3(0, 0.3, 0.1))
			_box(torso, "#a3241f", 0.46, 0.55, 0.04, Vector3(0, 0.12, 0.2))
			_box(torso, "#c8d0d8", 0.04, 0.5, 0.05, Vector3(0.24, -0.1, 0.05), Vector3(0, 0, 0.3))
			_box(torso, c, 0.14, 0.04, 0.06, Vector3(0.18, 0.13, 0.05), Vector3(0, 0, 0.3))
		"peri": # Pəri qız: long light hair, a flower crown, glassy wings
			_egg(head, "#e8c27a", 0.32, 0.3, 0.3, Vector3(0, 0.25, 0.05))
			_box(head, "#e8c27a", 0.5, 0.55, 0.12, Vector3(0, -0.05, 0.2))
			for i in 6:
				var a := i / 6.0 * TAU
				_egg(h, "#f2a6c8" if i % 2 else "#ffffff", 0.06, 0.05, 0.06, Vector3(cos(a) * 0.27, 0.42, sin(a) * 0.27))
			for sd in [-1.0, 1.0]:
				var w := _egg(torso, Color(0.81, 0.91, 1.0, 0.65), 0.32, 0.45, 0.04, Vector3(sd * 0.25, 0.35, 0.3), Vector3(0, 0, sd * 0.5))
				w.set_meta("wing", sd)
		"kosa": # Kosa: a tall pointed sheepskin hat with a bell, a woolly beard
			_cyl(h, c, 0.24, 0.7, Vector3(0, 0.66, 0), Vector3.ZERO, 0.0)
			Kit.part(h, Kit.ring(0.24, 0.07), Kit.mat("#efe6cf"), Vector3(0, 0.33, 0))
			_egg(h, "#d8a53a", 0.06, 0.06, 0.06, Vector3(0, 1.0, 0))
			_egg(head, "#efe6cf", 0.2, 0.1, 0.1, Vector3(0, -0.04, -0.24))
		_: # Kəndirbaz: a tall white felt hat with a tassel
			_cyl(h, c, 0.2, 0.42, Vector3(0, 0.5, 0), Vector3.ZERO, 0.17)
			_cyl(h, c, 0.3, 0.04, Vector3(0, 0.32, 0))
			_egg(h, "#c8322c", 0.07, 0.07, 0.07, Vector3(0, 0.75, 0))
			_cyl(h, "#1f9e9a", 0.205, 0.05, Vector3(0, 0.38, 0))
	if look.get("braids", false) and hat != "scarf":
		for sx in [-0.17, 0.17]:
			_cyl(head, "#2a160c", 0.05, 0.42, Vector3(sx, -0.05, 0.16))
	if look.get("sprig", false): # Novruz: a green səməni sprig in the hat
		_cyl(h, "#5fbf3a", 0.04, 0.22, Vector3(0.12, 0.62, 0), Vector3.ZERO, 0.0)


## The Div: huge, furry, horned, a round belly, a wooden club. Comic, not scary. Faces +z.
## Parts: rig, body, head, leg_l, leg_r, arm_l, arm_r, mouth, club, brow_l, brow_r.
static func div() -> Node3D:
	var g := Node3D.new()
	var rig := Kit.joint(g)
	var fur := Kit.tex("fur", Vector2(2, 2))
	var fur_d := Kit.tex("fur", Vector2(2, 2), Color(0.78, 0.8, 0.72))
	var legs := []
	for sx in [-0.45, 0.45]:
		var leg := Kit.joint(rig, Vector3(sx, 1.0, 0))
		_egg(leg, fur_d, 0.3, 0.55, 0.3, Vector3(0, -0.45, 0), Vector3.ZERO, 12)
		_egg(leg, "#3e2a17", 0.32, 0.16, 0.45, Vector3(0, -0.95, 0.12))
		for t in 3: # toes
			_egg(leg, "#f1e6c8", 0.06, 0.05, 0.06, Vector3(-0.15 + t * 0.15, -0.95, 0.52))
		legs.append(leg)
	var body := Kit.joint(rig, Vector3(0, 1.0, 0))
	_egg(body, fur, 1.0, 1.05, 0.85, Vector3(0, 0.9, 0), Vector3.ZERO, 14)
	_egg(body, "#d9c48a", 0.72, 0.78, 0.5, Vector3(0, 0.8, 0.42))
	_egg(body, "#9a7c45", 0.06, 0.06, 0.04, Vector3(0, 0.7, 0.92))
	_box(body, "#7a4a22", 1.9, 0.18, 1.6, Vector3(0, 0.35, 0)) # a leather belt
	var head := Kit.joint(body, Vector3(0, 2.0, 0))
	_egg(head, fur, 0.62, 0.55, 0.55, Vector3(0, 0.1, 0.05), Vector3.ZERO, 14)
	for sd in [-1.0, 1.0]:
		_cyl(head, "#f1e6c8", 0.13, 0.5, Vector3(sd * 0.38, 0.62, 0), Vector3(0, 0, -sd * 0.5), 0.0)
		_egg(head, fur_d, 0.14, 0.2, 0.08, Vector3(sd * 0.6, 0.2, 0), Vector3(0, 0, -sd * 0.4)) # ears
	var brows := []
	for x in [-0.2, 0.2]: # big goofy eyes, different sizes
		var s := 0.17 if x < 0 else 0.13
		_egg(head, "#ffffff", s, s * 1.1, 0.08, Vector3(x, 0.22, 0.52))
		_egg(head, "#2a1a10", s * 0.45, s * 0.5, 0.05, Vector3(x + 0.02, 0.2, 0.6))
		brows.append(_box(head, "#3b4a1a", 0.26, 0.07, 0.06, Vector3(x, 0.42, 0.55), Vector3(0, 0, signf(x) * 0.3)))
	_egg(head, "#c96b4a", 0.16, 0.13, 0.13, Vector3(0, 0.02, 0.6))
	var mouth := _egg(head, "#5a1410", 0.28, 0.1, 0.06, Vector3(0, -0.22, 0.52))
	for x in [-0.1, 0.12]:
		_box(head, "#fff6dc", 0.07, 0.08, 0.03, Vector3(x, -0.17, 0.56))
	var arms := []
	for sx in [-0.95, 0.95]:
		var arm := Kit.joint(body, Vector3(sx, 1.35, 0))
		_egg(arm, fur, 0.24, 0.6, 0.24, Vector3(0, -0.5, 0), Vector3.ZERO, 12)
		_egg(arm, fur_d, 0.22, 0.2, 0.22, Vector3(0, -1.05, 0), Vector3.ZERO, 12)
		arms.append(arm)
	var club := Kit.joint(arms[1], Vector3(0, -1.05, 0.1)) # ağac gürz
	_cyl(club, Kit.tex("wood"), 0.07, 0.9, Vector3(0, 0.35, 0.2), Vector3(0.5, 0, 0))
	_egg(club, Kit.tex("wood"), 0.22, 0.32, 0.22, Vector3(0, 0.75, 0.42), Vector3.ZERO, 10)
	for i in 4: # knots on the club
		_egg(club, "#5a3416", 0.05, 0.05, 0.05, Vector3(cos(i * 1.6) * 0.2, 0.75 + sin(i * 2.1) * 0.2, 0.42 + sin(i * 1.6) * 0.2))
	g.set_meta("parts", {"rig": rig, "body": body, "head": head, "leg_l": legs[0], "leg_r": legs[1],
		"arm_l": arms[0], "arm_r": arms[1], "mouth": mouth, "club": club, "brow_l": brows[0], "brow_r": brows[1]})
	Kit.ink(g)
	Kit.shadow(g, 1.0)
	return g


## Nənə: Cırtdan's grandmother in a kəlağayı headscarf, floury hands, kind. Faces +z.
static func nene() -> Node3D:
	var g := Node3D.new()
	_cyl(g, "#7a2c3e", 0.42, 1.0, Vector3(0, 0.5, 0), Vector3.ZERO, 0.12)
	_cyl(g, "#efe6cf", 0.3, 0.6, Vector3(0, 0.45, 0.2), Vector3.ZERO, 0.2)
	for i in 3: # apron pattern
		_egg(g, "#b3262a", 0.04, 0.04, 0.02, Vector3(-0.1 + i * 0.1, 0.35, 0.42))
	_egg(g, SKIN, 0.22, 0.22, 0.21, Vector3(0, 1.18, 0))
	_egg(g, "#e8e0d0", 0.26, 0.24, 0.25, Vector3(0, 1.24, -0.04))
	_cyl(g, "#e8e0d0", 0.3, 0.45, Vector3(0, 0.98, -0.14), Vector3.ZERO, 0.0)
	_cyl(g, "#b3262a", 0.25, 0.05, Vector3(0, 1.33, -0.02))
	for x in [-0.07, 0.07]:
		_egg(g, "#2a1a10", 0.025, 0.03, 0.02, Vector3(x, 1.2, 0.2))
		_egg(g, "#f08a8a", 0.04, 0.025, 0.02, Vector3(x * 1.8, 1.12, 0.18))
	_egg(g, "#8a2a1c", 0.05, 0.015, 0.02, Vector3(0, 1.1, 0.21))
	for sd in [-1.0, 1.0]:
		_cyl(g, "#7a2c3e", 0.07, 0.45, Vector3(sd * 0.3, 0.8, 0.12), Vector3(-0.9, 0, 0))
		_egg(g, "#fbf5e6", 0.08, 0.08, 0.08, Vector3(sd * 0.3, 0.68, 0.32))
	Kit.ink(g)
	Kit.shadow(g, 0.45)
	return g


## One camel of the caravan, walking toward you (+z is its face). Parts: rig, legs (4), head.
static func camel() -> Node3D:
	var g := Node3D.new()
	var rig := Kit.joint(g)
	var hide := "#c99a5b"
	var hide_d := "#a8783e"
	_egg(rig, hide, 0.42, 0.42, 0.95, Vector3(0, 1.45, 0), Vector3.ZERO, 12)
	_egg(rig, hide_d, 0.32, 0.4, 0.32, Vector3(0, 1.85, -0.25), Vector3.ZERO, 12)
	_box(rig, Kit.tex("carpet_red"), 0.9, 0.05, 0.7, Vector3(0, 1.78, 0.2), Vector3(0.1, 0, 0))
	for sd in [-1.0, 1.0]: # saddle bags
		_box(rig, Kit.tex("carpet_blue"), 0.08, 0.4, 0.5, Vector3(sd * 0.46, 1.55, 0.2))
	_cyl(rig, hide, 0.13, 0.85, Vector3(0, 1.95, 0.95), Vector3(0.55, 0, 0))
	var head := Kit.joint(rig, Vector3(0, 2.3, 1.3))
	_egg(head, hide, 0.17, 0.16, 0.33, Vector3.ZERO, Vector3.ZERO, 12)
	for x in [-0.14, 0.14]:
		_egg(head, "#2a1a10", 0.04, 0.04, 0.04, Vector3(x, 0.08, 0))
		_cyl(head, hide_d, 0.05, 0.12, Vector3(x * 0.7, 0.2, -0.1), Vector3.ZERO, 0.0)
	_egg(rig, "#d8a53a", 0.08, 0.1, 0.08, Vector3(0, 1.72, 1.12))
	var legs := []
	for xz in [[-0.22, 0.6], [0.22, 0.6], [-0.22, -0.6], [0.22, -0.6]]:
		var l := Kit.joint(rig, Vector3(xz[0], 1.2, xz[1]))
		_cyl(l, hide, 0.07, 1.15, Vector3(0, -0.58, 0))
		_egg(l, hide_d, 0.1, 0.06, 0.13, Vector3(0, -1.16, 0.03))
		legs.append(l)
	g.set_meta("parts", {"rig": rig, "legs": legs, "head": head})
	Kit.ink(g)
	Kit.shadow(g, 0.8, 1.6)
	return g


## The phaeton's horse, facing +z. Parts: legs (4), head.
static func horse() -> Node3D:
	var g := Node3D.new()
	var coat := "#5b3a22"
	var mane := "#20140b"
	_egg(g, coat, 0.32, 0.36, 0.8, Vector3(0, 1.15, 0), Vector3.ZERO, 12)
	_cyl(g, coat, 0.15, 0.7, Vector3(0, 1.6, 0.65), Vector3(0.6, 0, 0))
	var head := Kit.joint(g, Vector3(0, 1.92, 0.95))
	_box(head, coat, 0.2, 0.22, 0.48, Vector3.ZERO, Vector3(0.5, 0, 0))
	for x in [-0.07, 0.07]:
		_cyl(head, mane, 0.05, 0.1, Vector3(x, 0.2, -0.15), Vector3.ZERO, 0.0)
		_egg(head, "#000000", 0.03, 0.03, 0.03, Vector3(x * 1.6, 0.06, 0.0))
	_box(g, mane, 0.06, 0.5, 0.3, Vector3(0, 1.75, 0.55), Vector3(0.6, 0, 0))
	_cyl(g, mane, 0.05, 0.6, Vector3(0, 1.05, -0.85), Vector3(-0.6, 0, 0))
	var legs := []
	for xz in [[-0.17, 0.5], [0.17, 0.5], [-0.17, -0.5], [0.17, -0.5]]:
		var l := Kit.joint(g, Vector3(xz[0], 0.93, xz[1]))
		_cyl(l, coat, 0.06, 0.9, Vector3(0, -0.45, 0))
		_cyl(l, mane, 0.07, 0.08, Vector3(0, -0.89, 0))
		legs.append(l)
	_box(g, "#b3262a", 0.68, 0.08, 0.1, Vector3(0, 1.35, 0.3))
	_egg(g, "#d8a53a", 0.05, 0.05, 0.05, Vector3(0.36, 1.35, 0.3))
	g.set_meta("parts", {"legs": legs, "head": head})
	return g


## The Simurq: the fairy-tale bird, gold and turquoise, wings out, a long fanned tail. Faces -z.
## Parts: wings (two joints to flap), tail.
static func simurq() -> Node3D:
	var g := Node3D.new()
	var gold := "#f2b632"
	var teal := "#1f9e9a"
	var red := "#c8322c"
	_egg(g, gold, 0.55, 0.45, 0.9, Vector3.ZERO)
	_egg(g, "#ffe3a0", 0.4, 0.32, 0.6, Vector3(0, -0.15, 0.1))
	_cyl(g, gold, 0.18, 0.7, Vector3(0, 0.35, -0.75), Vector3(-0.8, 0, 0))
	_egg(g, gold, 0.3, 0.28, 0.34, Vector3(0, 0.6, -1.15))
	_cyl(g, "#e07b22", 0.09, 0.35, Vector3(0, 0.55, -1.5), Vector3(-PI / 2, 0, 0), 0.0)
	for x in [-0.14, 0.14]:
		_egg(g, "#ffffff", 0.08, 0.08, 0.06, Vector3(x, 0.68, -1.38))
		_egg(g, "#2a1a10", 0.04, 0.04, 0.03, Vector3(x, 0.68, -1.43))
	for i in 5:
		_cyl(g, red if i % 2 else teal, 0.05, 0.4, Vector3((i - 2) * 0.08, 0.92, -1.05), Vector3(0, 0, (i - 2) * 0.25), 0.0)
	var wings := []
	for sd in [-1.0, 1.0]:
		var w := Kit.joint(g, Vector3(sd * 0.45, 0.15, -0.1))
		for i in 4:
			_box(w, [teal, gold, red, teal][i], 1.6 - i * 0.25, 0.06, 0.35, Vector3(sd * (0.8 - i * 0.12), -i * 0.02, -0.25 + i * 0.25))
		wings.append(w)
	var tail := Kit.joint(g)
	for i in 5:
		_box(tail, [teal, red, gold, red, teal][i], 0.18, 0.04, 1.9, Vector3((i - 2) * 0.2, 0.05, 1.6), Vector3(0.15, (i - 2) * 0.12, 0))
		_egg(tail, "#2c4fa0", 0.11, 0.03, 0.14, Vector3((i - 2) * 0.32, 0.12, 2.45))
	for x in [-0.2, 0.2]:
		_cyl(g, "#e07b22", 0.04, 0.5, Vector3(x, -0.6, 0.1))
	g.set_meta("parts", {"wings": wings, "tail": tail})
	Kit.ink(g)
	return g


## The flying carpet under the runner: a carpet curled at the edges, fringes at the ends.
static func flying_carpet() -> Node3D:
	var g := Node3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nx := 6
	var nz := 8
	for i in nx:
		for j in nz:
			var quad := []
			for d in [[0, 0], [1, 0], [1, 1], [0, 1]]:
				var u := float(i + d[0]) / nx
				var v := float(j + d[1]) / nz
				var x := (u - 0.5) * 1.4
				var z := (v - 0.5) * 1.9
				var y := 0.06 * sin(z * 3.0) + (0.12 if absf(x) > 0.6 else 0.0)
				quad.append([Vector3(x, y, z), Vector2(u, v)])
			for k in [0, 1, 2, 0, 2, 3]:
				st.set_uv(quad[k][1])
				st.add_vertex(quad[k][0])
	st.generate_normals()
	var mi := Kit.part(g, st.commit(), Kit.tex("carpet_green", Vector2.ONE, Color.WHITE, true))
	mi.set_meta("no_ink", true)
	for z in [-0.98, 0.98]:
		_box(g, "#f4e2b8", 1.4, 0.04, 0.08, Vector3(0, 0, z))
	g.set_meta("parts", {"cloth": mi})
	return g
