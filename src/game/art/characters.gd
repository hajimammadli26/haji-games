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
const PLAYER_RED := "#c8221d" ## the papaq, and a band on every other hat — nothing else in the game layer (art bible §4)


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


## Proportions per hat (the hat names the character): [leg length, body width, torso height], 1 = Cırtdan.
## Each playable gets its own outline class at phone size; Cırtdan's costumes keep his (art bible §5).
const BODY := {
	"tall": [1.32, 0.84, 1.12], # Kəndirbaz: tall and slim, a rope-walker
	"crown": [1.16, 1.1, 1.1], # Məlikməmməd: taller and broad, the hero
	"scarf": [1.0, 0.94, 0.96], # Tıq-Tıq: a little slighter, a skirt
	"kosa": [0.96, 1.1, 1.0], # Kosa: a round old fellow
}
const AGOLD := "#c89b45" ## Antique Gold: trims (art bible §4)
const MADDER := "#8f2b2b" ## the dye red of belts and capes, clearly apart from Player Red
const WOOL := "#efe6cf"


## A playable character from a look (Catalog look plus costume): hat, hat_color, vest, trim, shirt, pants,
## braids, sprig. Faces -z. Parts: rig, hip, torso, head, leg_l, leg_r, arm_l, arm_r, sack, hat, tongue, brow_l, brow_r,
## knee_l/r, elbow_l/r, eye_l/r, smile, gasp. The hat picks the body (BODY) and the face (_face).
static func runner(look: Dictionary = {}) -> Node3D:
	var vest := String(look.get("vest", "#1f4f8f"))
	var trim := String(look.get("trim", AGOLD))
	var shirt := String(look.get("shirt", "#f3ecd8"))
	var pants := String(look.get("pants", "#4b3221"))
	var hat := String(look.get("hat", "papaq"))
	var hat_c := String(look.get("hat_color", PLAYER_RED))
	var body: Array = BODY.get(hat, [1.0, 1.0, 1.0])
	var ll: float = body[0]
	var w: float = body[1]
	var th: float = body[2]
	var face := _face(hat)
	var g := Node3D.new()
	var rig := Kit.joint(g)
	var hip_y := 0.1 + 0.42 * ll
	var hip := Kit.joint(rig, Vector3(0, hip_y, 0))
	var legs := []
	var knees := []
	for sx in [-0.12 * w, 0.12 * w]: # two-bone legs: thigh, knee, shin, a çarıq with a turned-up toe
		var leg := Kit.joint(hip, Vector3(sx, 0, 0))
		Kit.part(leg, Kit.capsule(0.085, 0.24 * ll), Kit.mat(pants), Vector3(0, -0.1 * ll, 0))
		var knee := Kit.joint(leg, Vector3(0, -0.2 * ll, 0))
		Kit.part(knee, Kit.capsule(0.075, 0.24 * ll), Kit.mat(pants), Vector3(0, -0.1 * ll, 0))
		var foot := -0.22 * ll
		_egg(knee, "#7a3b16", 0.1, 0.07, 0.16, Vector3(0, foot, -0.04)) # çarıq, toe forward
		_ink(_cyl(knee, "#7a3b16", 0.03, 0.08, Vector3(0, foot + 0.02, -0.2), Vector3(-1.0, 0, 0), 0.0)) # the turned-up toe
		_ink(_cyl(knee, MADDER, 0.075, 0.03, Vector3(0, foot + 0.05, 0))) # the çarıq's tie
		legs.append(leg)
		knees.append(knee)
	var torso := Kit.joint(rig, Vector3(0, hip_y, 0))
	# a rounded body in the shirt, and the vest wrapped round it, open down the front so the shirt shows;
	# the vest texture's border becomes the trim along the opening, the hem and the armholes
	Kit.part(torso, Kit.shell(_prof([[0.19, -0.04], [0.205, 0.1], [0.2, 0.26], [0.175, 0.37], [0.12, 0.45], [0.01, 0.48]], w, th), 0.0, TAU, 0.08, 14), Kit.mat(shirt))
	var vm := Kit.tex("vest_%s_%s" % [vest.trim_prefix("#"), trim.trim_prefix("#")])
	var gap := 0.42 # half the front opening, radians
	Kit.part(torso, Kit.shell(_prof([[0.226, -0.1], [0.236, 0.05], [0.232, 0.22], [0.205, 0.35], [0.158, 0.43], [0.118, 0.47]], w, th),
		-PI / 2 + gap, PI * 1.5 - gap, 0.03, 18), vm)
	_cyl(torso, MADDER, 0.25 * w, 0.075, Vector3(0, 0.03, 0)) # belt
	_ink(_egg(torso, AGOLD, 0.045, 0.04, 0.02, Vector3(0, 0.03, -0.252 * w))) # buckle
	var sash := 0.6 # the sack's strap, diagonal round the body
	Kit.part(torso, Kit.ring(0.255 * w, 0.022), Kit.mat("#8a6a44"), Vector3(0, 0.24 * th, 0), Vector3(0, 0, sash), Vector3(1.0 / cos(sash), 1, 1))
	if hat == "scarf": # Tıq-Tıq's skirt, flared, with a gold hem
		var sk := String(look.get("skirt", pants))
		Kit.part(torso, Kit.shell(_prof([[0.38, -0.3], [0.31, -0.17], [0.255, -0.03], [0.238, 0.05]], w, 1.0), 0.0, TAU, 0.025, 16), Kit.mat(sk))
		Kit.part(torso, Kit.ring(0.37 * w, 0.025), Kit.mat(AGOLD), Vector3(0, -0.29, 0))
	var sack := Kit.joint(torso, Vector3(0, 0.26 * th, 0.22 * w))
	_egg(sack, "#c9a46a", 0.24, 0.27, 0.16, Vector3.ZERO)
	_ink(_box(sack, "#7d5a9b", 0.12, 0.12, 0.02, Vector3(0.06, 0.05, 0.155))) # a patch
	_ink(_cyl(sack, "#8a6a44", 0.04, 0.06, Vector3(0, 0.27, 0))) # the knot
	var arms := []
	var elbows := []
	for sx in [-0.25 * w, 0.25 * w]: # two-bone arms: puffed sleeve, elbow, forearm, a hand with a thumb
		var arm := Kit.joint(torso, Vector3(sx, 0.38 * th, 0))
		Kit.part(arm, Kit.capsule(0.07, 0.2), Kit.mat(shirt), Vector3(0, -0.07, 0))
		var elbow := Kit.joint(arm, Vector3(0, -0.15, 0))
		Kit.part(elbow, Kit.capsule(0.058, 0.18), Kit.mat(shirt), Vector3(0, -0.07, 0))
		_ink(_egg(elbow, SKIN, 0.07, 0.07, 0.07, Vector3(0, -0.18, 0)))
		_ink(_egg(elbow, SKIN, 0.03, 0.03, 0.03, Vector3(-signf(sx) * 0.05, -0.16, -0.03)))
		arms.append(arm)
		elbows.append(elbow)
	var head := Kit.joint(torso, Vector3(0, 0.2 + 0.42 * th, 0))
	_egg(head, SKIN, 0.3, 0.29, 0.28, Vector3(0, 0.18, 0), Vector3.ZERO, 24)
	var ear: float = face["ear"]
	for sx in [-0.29, 0.29]:
		_egg(head, SKIN, 0.05 * ear, 0.08 * ear, 0.05 * ear, Vector3(sx * (0.7 + ear * 0.3), 0.17, 0))
	var eyes := []
	for sx in [-0.11, 0.11]: # big eyes, facing where he runs (-z); each in a joint that squashes to blink
		var eye := Kit.joint(head, Vector3(sx, 0.2, -0.24))
		_egg(eye, "#ffffff", 0.085, 0.1, 0.06, Vector3.ZERO)
		_egg(eye, "#2a1a10", 0.045, 0.055, 0.03, Vector3(0, -0.01, -0.05))
		_egg(eye, "#ffffff", 0.014, 0.014, 0.01, Vector3(0.015, 0.01, -0.075)) # a glint
		var lid: float = face["lid"]
		if lid > 0.0: # a lazy lid: a cheeky or kindly look
			_egg(eye, SKIN, 0.098, 0.07, 0.085, Vector3(0, 0.17 - lid * 0.2, -0.005), Vector3(0, 0, signf(sx) * 0.12))
		if face["lashes"]: # three lashes at the outer corner
			var so: float = signf(sx)
			for a in [1.05, 0.7, 0.35]:
				var rim := Vector2(0.085 * cos(a) * so, 0.1 * sin(a))
				_box(eye, "#2a1a10", 0.05, 0.016, 0.016, Vector3(rim.x + 0.02 * cos(a) * so, rim.y + 0.02 * sin(a), -0.03), Vector3(0, 0, a * so))
		var ck: Array = face["cheek"]
		_egg(head, ck[0], ck[1], ck[1] * 0.6, 0.02, Vector3(sx * 1.6, 0.08, -0.24)) # rosy cheeks
		eyes.append(eye)
	if face["tufts"] != "": # tufts of hair at the temples
		for sx in [-0.2, 0.2]:
			_egg(head, face["tufts"], 0.06, 0.08, 0.06, Vector3(sx, 0.26, -0.12))
	var brows := []
	var bt: Array = face["brow_tilt"]
	var bs: Array = face["brow_size"]
	for i in 2:
		var at := Vector3([-0.11, 0.11][i], 0.32, -0.27)
		var b: MeshInstance3D
		if face["bushy"]:
			b = _egg(head, face["brow"], bs[0] * 0.5, bs[1] * 0.5, 0.03, at, Vector3(0, 0, bt[i]))
		else:
			b = _box(head, face["brow"], bs[0], bs[1], 0.02, at, Vector3(0, 0, bt[i]))
		brows.append(b)
	_egg(head, "#e9a776", 0.05, 0.04, 0.04, Vector3(0, 0.12, -0.28))
	var m: Array = face["mouth"] # kind, half width, depth, thickness, teeth, tilt, height
	var smile := _mouth(head, m[0], m[1], m[2], m[3], m[4], m[5], m[6], "#6a1a14" if m[0] == "grin" else "#8a2a1c")
	var gasp := _mouth(head, "o", 0.04, 0.05, 0.0, 0.0, 0.0, m[6], "#5a1410") # an "O" for jumps and frights
	gasp.visible = false
	var tongue := _box(head, "#e05a6a", 0.08, 0.03, 0.12, Vector3(0, m[6] - 0.01, -0.32))
	tongue.visible = false
	for k in brows + [smile, gasp, tongue]: # the animator moves these: they stay separate pieces
		k.set_meta("keep", true)
	var hatn := Kit.joint(head)
	_hat(hatn, head, torso, hat, hat_c, look, w, th)
	g.set_meta("parts", {"rig": rig, "hip": hip, "torso": torso, "head": head, "leg_l": legs[0], "leg_r": legs[1],
		"arm_l": arms[0], "arm_r": arms[1], "sack": sack, "hat": hatn, "tongue": tongue, "brow_l": brows[0], "brow_r": brows[1],
		"knee_l": knees[0], "knee_r": knees[1], "elbow_l": elbows[0], "elbow_r": elbows[1], "eye_l": eyes[0], "eye_r": eyes[1],
		"smile": smile, "gasp": gasp})
	Kit.ink(g)
	Kit.shadow(g, 0.34 * w)
	Kit.merge_joints(g)
	return g


## The face for a hat: brows (colour, tilt left/right, size, bushy), lids, lashes, cheeks, ears, temple tufts and the
## mouth [kind, half width, depth, thickness, teeth, tilt, height]. Brows stay at y 0.32 (the animator lifts them).
static func _face(hat: String) -> Dictionary:
	var f := {"brow": "#3b2414", "brow_tilt": [0.15, -0.15], "brow_size": [0.1, 0.022], "bushy": false, "lid": 0.0,
		"lashes": false, "cheek": ["#f08a8a", 0.05], "ear": 1.0, "tufts": "#3b2414",
		"mouth": ["smile", 0.07, 0.03, 0.026, 0.0, 0.0, 0.03]}
	match hat:
		"scarf": # Tıq-Tıq: lashes, fine arched brows, pink cheeks, a small sweet smile
			f.merge({"brow": "#2a160c", "brow_tilt": [0.28, -0.28], "brow_size": [0.09, 0.018], "lashes": true,
				"cheek": ["#f47f97", 0.058], "tufts": "", "mouth": ["smile", 0.055, 0.03, 0.024, 0.0, 0.0, 0.03]}, true)
		"bald": # Keçəl: big ears, a sly half-lidded look, one brow cocked, a wide toothy grin
			f.merge({"brow": "#8a5a30", "brow_tilt": [-0.38, -0.05], "brow_size": [0.11, 0.026], "lid": 0.42, "ear": 1.4,
				"tufts": "", "mouth": ["grin", 0.1, 0.075, 0.0, 0.024, -0.14, 0.045]}, true)
		"tall": # Kəndirbaz: level, confident brows and a crooked smile
			f.merge({"brow_tilt": [-0.12, 0.3], "brow_size": [0.11, 0.024], "mouth": ["smile", 0.07, 0.025, 0.026, 0.0, 0.18, 0.035]}, true)
		"kosa": # Kosa: white bushy brows, a kindly squint, a laughing mouth inside his beard
			f.merge({"brow": WOOL, "brow_tilt": [0.3, -0.3], "brow_size": [0.15, 0.06], "bushy": true, "lid": 0.3,
				"tufts": WOOL, "mouth": ["grin", 0.065, 0.05, 0.0, 0.016, 0.0, 0.045]}, true)
		"peri": # Pəri: lashes, soft light brows, a small smile
			f.merge({"brow": "#b88a4a", "brow_tilt": [0.22, -0.22], "brow_size": [0.09, 0.018], "lashes": true,
				"cheek": ["#f59ac0", 0.055], "tufts": "", "mouth": ["smile", 0.05, 0.028, 0.022, 0.0, 0.0, 0.03]}, true)
		"crown": # Məlikməmməd: brave brows (inner ends down), a bold open smile
			f.merge({"brow": "#2a160c", "brow_tilt": [-0.28, 0.28], "brow_size": [0.115, 0.03], "tufts": "#2a160c",
				"mouth": ["grin", 0.075, 0.045, 0.0, 0.018, 0.0, 0.04]}, true)
	return f


## Marks a small piece to get an ink outline anyway, so it merges into its joint's inked mesh (no extra draw).
static func _ink(mi: MeshInstance3D) -> MeshInstance3D:
	mi.set_meta("ink", true)
	return mi


## A profile [[radius, height], ...] scaled: radii by w, heights by h.
static func _prof(pts: Array, w: float, h: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(Vector2(p[0] * w, p[1] * h))
	return out


## A mouth painted on the face: a thin patch hugging the head's front (the head egg: centre y 0.18, radii 0.3, 0.29,
## 0.28), coloured in its vertices so a grin and its teeth are one piece and one draw. kind: "smile" (a crescent),
## "grin" (an open D with a row of teeth) or "o". w: half width, h: depth, t: a smile's thickness, teeth: the teeth
## band's height, tilt: radians (a smirk), y: the mouth's height on the head.
static func _mouth(head: Node3D, kind: String, w: float, h: float, t: float, teeth: float, tilt: float, y: float, col: String) -> MeshInstance3D:
	var key := "mouth%s%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%s" % [kind, w, h, t, teeth, tilt, y, col]
	var mesh := Kit.cached(key, func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var n := 16
		var zero := [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
		for i in n:
			var s := [-1.0 + 2.0 * i / n, -1.0 + 2.0 * (i + 1) / n]
			var e0 := _mouth_edge(kind, s[0], h, t)
			var e1 := _mouth_edge(kind, s[1], h, t)
			var lo := [e0.x, e1.x]
			var hi := [e0.y, e1.y]
			var bands := [[lo, hi, Color(col)]]
			if teeth > 0.0:
				var mid := [maxf(lo[0], hi[0] - teeth), maxf(lo[1], hi[1] - teeth)]
				bands = [[lo, mid, Color(col)], [mid, hi, Color("#fff8ea")]]
			for b in bands:
				var pts := []
				var nrm := []
				for c in [[0, 0], [1, 0], [1, 1], [0, 1]]:
					var yy: float = b[0][c[0]] if c[1] == 0 else b[1][c[0]]
					var p := Vector2(s[c[0]] * w, yy).rotated(tilt)
					var dx := p.x / 0.3
					var dy := (y + p.y - 0.18) / 0.29
					var z := -0.28 * sqrt(maxf(0.04, 1.0 - dx * dx - dy * dy))
					var nv := Vector3(p.x / 0.09, (y + p.y - 0.18) / 0.0841, z / 0.0784).normalized()
					pts.append(Vector3(p.x, y + p.y, z) + nv * 0.007)
					nrm.append(nv)
				st.set_color(b[2])
				Kit._quad(st, pts, nrm, zero)
		return st.commit())
	var mi := Kit.part(head, mesh, Kit.tint_mat())
	mi.set_meta("no_ink", true)
	return mi


## A mouth's lower and upper edge (x, y of the result) at s, -1 to 1 across it.
static func _mouth_edge(kind: String, s: float, h: float, t: float) -> Vector2:
	var r := sqrt(maxf(0.0, 1.0 - s * s))
	match kind:
		"grin":
			var top := h * 0.35 * s * s
			return Vector2(top - h * r, top)
		"o":
			return Vector2(-h * r, h * r)
	var mid := h * (s * s - 0.5)
	var half := t * 0.5 * maxf(0.3, r)
	return Vector2(mid - half, mid + half)


## Two long braids from under the hat over the shoulders, each tied with a ribbon bow.
static func _braids(h: Node3D, hair: String, ribbon: String) -> void:
	for sd in [-1.0, 1.0]:
		for k in 4:
			var r: float = 0.068 - k * 0.006
			_ink(_egg(h, hair, r, 0.07, r, Vector3(sd * (0.27 + k * 0.012), 0.06 - k * 0.095, 0.05 - k * 0.012)))
		var by := 0.06 - 4 * 0.095 + 0.04
		var bx: float = sd * 0.316
		for d in [-1.0, 1.0]:
			_ink(_egg(h, ribbon, 0.065, 0.042, 0.035, Vector3(bx + d * 0.05, by, 0.0), Vector3(0, 0, -d * 0.45)))
		_ink(_egg(h, ribbon, 0.03, 0.03, 0.03, Vector3(bx, by, -0.02)))
		_ink(_cyl(h, hair, 0.055, 0.1, Vector3(bx, by - 0.08, 0.0), Vector3.ZERO, 0.025)) # the brush end


static func _hat(h: Node3D, head: Node3D, torso: Node3D, hat: String, c: String, look: Dictionary, w := 1.0, th := 1.0) -> void:
	match hat:
		"papaq": # Cırtdan's red araxçın with a fur band
			_egg(head, "#3b2414", 0.27, 0.16, 0.2, Vector3(0, 0.3, 0.1))
			_cyl(h, c, 0.26, 0.22, Vector3(0, 0.42, 0), Vector3.ZERO, 0.24)
			Kit.part(h, Kit.ring(0.25, 0.06), Kit.mat("#7a1512"), Vector3(0, 0.32, 0))
			_egg(h, c, 0.24, 0.07, 0.24, Vector3(0, 0.53, 0))
			_ink(_egg(h, AGOLD, 0.035, 0.035, 0.035, Vector3(0, 0.6, 0))) # a little gold knot on top
		"scarf": # Tıq-Tıq: a kəlağayı tied at the back, a fringe, two long braids with ribbons
			_egg(head, "#2a160c", 0.31, 0.25, 0.29, Vector3(0, 0.27, 0.03))
			_egg(h, c, 0.32, 0.17, 0.3, Vector3(0, 0.37, 0.02))
			_cyl(h, c, 0.08, 0.2, Vector3(0, 0.32, 0.32), Vector3(1.9, 0, 0), 0.0)
			_braids(h, "#2a160c", "#f48fb1")
		"bald": # Keçəl: a shiny bald head
			_egg(h, "#ffe7c4", 0.1, 0.06, 0.08, Vector3(-0.08, 0.44, -0.12))
		"winter": # a white fur hat with ear flaps
			_egg(h, c, 0.3, 0.22, 0.3, Vector3(0, 0.38, 0))
			for sx in [-0.27, 0.27]:
				_egg(h, c, 0.08, 0.16, 0.12, Vector3(sx, 0.16, 0))
			_egg(h, MADDER, 0.07, 0.07, 0.07, Vector3(0, 0.62, 0))
		"sailor": # a white cap with a blue band and two ribbons
			_cyl(h, c, 0.3, 0.1, Vector3(0, 0.42, 0))
			_cyl(h, "#1d4f9a", 0.27, 0.07, Vector3(0, 0.36, 0))
			for sx in [-0.05, 0.05]:
				_ink(_box(h, "#1d4f9a", 0.04, 0.2, 0.02, Vector3(sx, 0.24, 0.28)))
		"crown": # Məlikməmməd: a golden crown, a cape, a sword on his back
			_cyl(h, c, 0.22, 0.16, Vector3(0, 0.45, 0), Vector3.ZERO, 0.24)
			for i in 5:
				var a := i / 5.0 * TAU
				_cyl(h, c, 0.05, 0.14, Vector3(cos(a) * 0.2, 0.58, sin(a) * 0.2), Vector3.ZERO, 0.0)
			_ink(_egg(h, "#1f6fb8", 0.05, 0.05, 0.03, Vector3(0, 0.46, -0.22))) # a jewel
			_egg(head, "#2a160c", 0.28, 0.14, 0.2, Vector3(0, 0.3, 0.1))
			Kit.part(torso, Kit.shell(_prof([[0.34, -0.44], [0.3, -0.12], [0.265, 0.2], [0.215, 0.38], [0.17, 0.46]], w, th),
				PI / 2 - 1.1, PI / 2 + 1.1, 0.025, 14), Kit.mat(MADDER)) # the cape, round his back
			for sx in [-0.17, 0.17]:
				_ink(_egg(torso, AGOLD, 0.04, 0.04, 0.03, Vector3(sx * w, 0.44 * th, -0.08))) # its clasps
			# the sword across his back, hilt over the right shoulder
			var tilt := -0.78
			var up := Vector3(-sin(tilt), cos(tilt), 0)
			var base := Vector3(0.04, 0.3 * th, 0.42 * w)
			_box(torso, "#d9e0e8", 0.075, 0.66, 0.025, base, Vector3(0, 0, tilt)) # the blade
			_box(torso, "#6b4a2a", 0.09, 0.5, 0.04, base - up * 0.1 + Vector3(0, 0, 0.015), Vector3(0, 0, tilt)) # the scabbard
			_box(torso, AGOLD, 0.22, 0.05, 0.06, base + up * 0.34, Vector3(0, 0, tilt)) # the cross-guard
			_cyl(torso, "#5a3416", 0.03, 0.15, base + up * 0.43, Vector3(0, 0, tilt))
			_ink(_egg(torso, AGOLD, 0.045, 0.045, 0.045, base + up * 0.52)) # the pommel
		"peri": # Pəri qız: long light hair, a flower crown, wings
			_egg(head, "#e8c27a", 0.32, 0.3, 0.3, Vector3(0, 0.25, 0.05))
			_egg(head, "#e8c27a", 0.29, 0.4, 0.15, Vector3(0, -0.06, 0.17)) # hair down her back
			for i in 6:
				var a := i / 6.0 * TAU
				_ink(_egg(h, "#f2a6c8" if i % 2 else "#ffffff", 0.06, 0.05, 0.06, Vector3(cos(a) * 0.27, 0.42, sin(a) * 0.27)))
			for sd in [-1.0, 1.0]: # each wing a joint the animator flutters: two coloured lobes, pale panels, a sparkle
				var wj := Kit.joint(torso, Vector3(sd * 0.1, 0.36 * th, 0.24))
				wj.set_meta("wing", sd)
				var yaw: float = -sd * 0.72 # swept back so it sits out to the side while it flutters (rotation.y 0.05 to 0.75)
				for lobe in [[0.34, 0.21, 0.55, 0.32, "#b9a3ec"], [0.23, 0.15, -0.5, 0.22, "#f2a9cf"]]:
					var rot := Vector3(0, yaw, sd * float(lobe[2]))
					var bas := Basis.from_euler(rot)
					_egg(wj, lobe[4], lobe[0], lobe[1], 0.025, bas * Vector3(sd * lobe[3], 0, 0), rot)
					_egg(wj, "#f6eeff", lobe[0] * 0.55, lobe[1] * 0.5, 0.032, bas * Vector3(sd * lobe[3] * 1.12, 0, 0), rot)
				var rs := Vector3(0, yaw, float(sd) * 0.55)
				var tip := Basis.from_euler(rs) * Vector3(float(sd) * 0.6, 0.06, 0)
				for k in 2: # a four-point sparkle at the tip
					_ink(_box(wj, "#fff1a0", 0.15, 0.035, 0.045, tip, Vector3(0, yaw, k * PI / 2 + 0.785)))
		"kosa": # Kosa: a tall pointed sheepskin hat with a bell, a woolly beard shaped round his mouth
			_cyl(h, c, 0.24, 0.8, Vector3(0, 0.71, 0), Vector3.ZERO, 0.0)
			Kit.part(h, Kit.ring(0.24, 0.07), Kit.mat(WOOL), Vector3(0, 0.33, 0))
			_ink(_egg(h, AGOLD, 0.065, 0.065, 0.065, Vector3(0, 1.13, 0)))
			_egg(head, WOOL, 0.13, 0.085, 0.09, Vector3(0, -0.085, -0.2)) # the chin, under the mouth
			_egg(head, WOOL, 0.075, 0.07, 0.07, Vector3(0, -0.19, -0.15)) # its pointed end
			for sd in [-1.0, 1.0]:
				_egg(head, WOOL, 0.075, 0.14, 0.08, Vector3(sd * 0.155, -0.01, -0.17), Vector3(0, 0, sd * 0.35)) # round the cheeks
				_ink(_egg(head, WOOL, 0.07, 0.03, 0.035, Vector3(sd * 0.065, 0.088, -0.272), Vector3(0, 0, sd * 0.38))) # moustache
		_: # Kəndirbaz: a tall white felt hat with a tassel, the balance pole across his shoulders
			_cyl(h, c, 0.2, 0.42, Vector3(0, 0.5, 0), Vector3.ZERO, 0.17)
			_cyl(h, c, 0.3, 0.04, Vector3(0, 0.32, 0))
			_ink(_egg(h, "#c8322c", 0.07, 0.07, 0.07, Vector3(0, 0.75, 0)))
			_cyl(h, "#1f9e9a", 0.205, 0.05, Vector3(0, 0.38, 0))
			_cyl(torso, "#8a5a2e", 0.024, 1.5, Vector3(0, 0.47 * th, 0.34), Vector3(0, 0, PI / 2))
			for sd in [-1.0, 1.0]:
				_ink(_egg(torso, AGOLD, 0.05, 0.05, 0.05, Vector3(sd * 0.75, 0.47 * th, 0.34)))
	if hat != "papaq": # every other hat carries a band of Player Red: the runner is always findable (art bible §4)
		var band: Array = {"bald": [0.3, 0.295], "scarf": [0.36, 0.31], "tall": [0.34, 0.21], "kosa": [0.38, 0.23],
			"peri": [0.4, 0.3], "crown": [0.39, 0.235], "winter": [0.3, 0.31], "sailor": [0.4, 0.3]}.get(hat, [0.34, 0.3])
		Kit.part(h, Kit.ring(band[1], 0.03), Kit.mat(PLAYER_RED), Vector3(0, band[0], 0))
	if look.get("braids", false) and hat != "scarf":
		_braids(h, "#2a160c", "#f48fb1")
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
		# short horns with rounded nubs: comic, never sharp (art bible §3)
		_cyl(head, "#f1e6c8", 0.13, 0.32, Vector3(sd * 0.36, 0.56, 0), Vector3(0, 0, -sd * 0.5), 0.07)
		_egg(head, "#f1e6c8", 0.075, 0.075, 0.075, Vector3(sd * 0.44, 0.7, 0))
		_egg(head, fur_d, 0.14, 0.2, 0.08, Vector3(sd * 0.6, 0.2, 0), Vector3(0, 0, -sd * 0.4)) # ears
	var brows := []
	var div_eyes := []
	for i in 7: # shaggy tufts on his head and shoulders
		var a := -0.9 + i * 0.3
		_cyl(head, fur_d, 0.09, 0.28, Vector3(sin(a) * 0.45, 0.55 - absf(a) * 0.15, -0.1 + cos(a) * 0.05), Vector3(0, 0, -a * 0.9), 0.0)
	for x in [-0.2, 0.2]: # big goofy eyes, different sizes; each in a joint that squashes to blink
		var s := 0.17 if x < 0 else 0.13
		var eye := Kit.joint(head, Vector3(x, 0.22, 0.52))
		_egg(eye, "#ffffff", s, s * 1.1, 0.08, Vector3.ZERO)
		_egg(eye, "#2a1a10", s * 0.45, s * 0.5, 0.05, Vector3(0.02, -0.02, 0.08))
		_egg(eye, "#ffffff", s * 0.12, s * 0.12, 0.02, Vector3(0.04, 0.02, 0.12))
		div_eyes.append(eye)
		brows.append(_box(head, "#3b4a1a", 0.26, 0.07, 0.06, Vector3(x, 0.42, 0.55), Vector3(0, 0, signf(x) * 0.3)))
	_egg(head, "#c96b4a", 0.16, 0.13, 0.13, Vector3(0, 0.02, 0.6))
	var mouth := _egg(head, "#5a1410", 0.28, 0.1, 0.06, Vector3(0, -0.22, 0.52))
	mouth.set_meta("keep", true)
	for x in [-0.1, 0.12]:
		_box(head, "#fff6dc", 0.07, 0.08, 0.03, Vector3(x, -0.17, 0.56))
	_egg(head, "#e05a6a", 0.12, 0.04, 0.04, Vector3(0.05, -0.25, 0.54)) # his tongue
	for i in 3: # a lumpy chin with bristles
		_egg(head, fur_d, 0.08, 0.08, 0.06, Vector3(-0.12 + i * 0.12, -0.36, 0.42))
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
		"arm_l": arms[0], "arm_r": arms[1], "mouth": mouth, "club": club, "brow_l": brows[0], "brow_r": brows[1],
		"eye_l": div_eyes[0], "eye_r": div_eyes[1]})
	for b in brows:
		b.set_meta("keep", true)
	Kit.ink(g)
	Kit.shadow(g, 1.0)
	Kit.merge_joints(g)
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
		_cyl(l, hide, 0.07, 1.15, Vector3(0, -0.58, 0)).set_meta("no_ink", true) # thin legs: no outline (one draw saved each)
		_egg(l, hide_d, 0.1, 0.06, 0.13, Vector3(0, -1.16, 0.03)).set_meta("no_ink", true)
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
		_cyl(l, coat, 0.06, 0.9, Vector3(0, -0.45, 0)).set_meta("no_ink", true)
		_cyl(l, mane, 0.07, 0.08, Vector3(0, -0.89, 0)).set_meta("no_ink", true)
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
