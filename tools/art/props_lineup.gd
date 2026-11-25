## Dev viewer: every obstacle kind (each city's look) and every pickup in one contact sheet, each framed from
## the runner's side (in front, a little above), lit like the street. A grey 1.45 m post beside each obstacle is
## Cırtdan standing (RunSim.PSTAND): a jump clears 0.85, a slide passes under 1.15.
## Needs a renderer (not --headless):
##   xvfb-run -a godot --path . --rendering-driver opengl3 --rendering-method gl_compatibility \
##       -s res://tools/art/props_lineup.gd -- --out=res://production/qa/evidence/items.png
extends SceneTree

const OBST := [["basket", "baku"], ["carpet", "baku"], ["stall", "baku"], ["phaeton", "baku"], ["cart", "baku"],
	["ramp", "baku"], ["caravan", "baku"], ["basket", "qebele"], ["carpet", "qebele"], ["stall", "qebele"],
	["basket", "naxcivan"], ["basket", "quba"], ["stall", "quba"], ["basket", "qobustan"], ["stall", "qobustan"],
	["carpet", "qobustan"]]
const NAMES := ["basket", "carpet", "stall", "phaeton", "cart", "ramp", "caravan", "stump", "branch", "boulder",
	"salt", "crates", "loom", "mud", "art_boulder", "rock_arch"]
const PICK := [["bread", "baku"], ["nar", "baku"], ["magnet", "baku"], ["shoe", "baku"], ["double", "baku"],
	["pole", "baku"], ["simurq", "baku"], ["letter", "baku"], ["buta", "baku"], ["stone", "baku"],
	["treat", "sheki"], ["treat", "qebele"], ["treat", "naxcivan"], ["treat", "lenkeran"], ["treat", "quba"],
	["bread", "baku"]]
const OW := 320
const OH := 260
const PW := 160
const PH := 180

var _cells: Array = [] ## [SubViewport, Vector2i]
var _frames := 0
var _out := "res://production/qa/evidence/items.png"


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.trim_prefix("--out=")
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in OBST.size():
		var length := 6.0 if OBST[i][0] == "cart" else 1.0
		var n := Props.obstacle(OBST[i][0], length, OBST[i][1], rng)
		if n.has_meta("parts"):
			Kit.merge_joints(n)
		else:
			Kit.merge(n)
		var post := Kit.part(n, Kit.capsule(0.16, 1.45), Kit.mat("#7d8aa0"), Vector3(1.6, 0.725, 0))
		post.set_meta("ref", true)
		_cell(n, NAMES[i], Vector2i(i % 4 * OW, i / 4 * OH), Vector2i(OW, OH), true)
	for i in PICK.size():
		var p := Props.pickup(PICK[i][0], "Ə", PICK[i][1])
		if i == 15: # the last cell: a bread line as the runner meets it, three in a row
			for k in 2:
				var b := Props.pickup("bread")
				b.position = Vector3(0, 0, -2.2 * (k + 1))
				p.add_child(b)
		var label: String = PICK[i][0] if PICK[i][0] != "treat" else String(Props.TREATS[PICK[i][1]])
		if i == 15:
			label = "bread line"
		p.rotation.y = 0.35 if i != 15 else 0.0
		_cell(p, label, Vector2i(i % 8 * PW, 4 * OH + i / 8 * PH), Vector2i(PW, PH), false, i == 15)


func _cell(item: Node3D, label: String, at: Vector2i, size: Vector2i, obstacle: bool, line := false) -> void:
	var vp := SubViewport.new()
	vp.size = size
	vp.own_world_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X
	root.add_child(vp)
	var we := WorldEnvironment.new() # the street's light (World._ready)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#9cc7e6") if obstacle else Color("#cfe3ef")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#f3e3c4")
	env.ambient_light_energy = 0.65
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.08
	env.adjustment_contrast = 1.08
	env.adjustment_brightness = 0.94
	we.environment = env
	vp.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.05
	sun.light_color = Color("#fff1d6")
	vp.add_child(sun)
	if obstacle:
		Kit.part(vp_root(vp), Kit.box(12, 0.02, 30), Kit.tex("cobble", Vector2(6, 15)), Vector3(0, -0.01, -6))
	vp_root(vp).add_child(item)
	var cam := Camera3D.new()
	cam.fov = 40
	vp.add_child(cam)
	var box := _aabb(item, Transform3D.IDENTITY, AABB(), false)
	var c := box.get_center()
	var r := maxf(box.size.x * 0.5, box.size.y * 0.5) + 0.2
	if obstacle:
		r = maxf(r, box.size.z * 0.3)
		cam.position = c + Vector3(0.0, 0.35, 1.0).normalized() * r * 3.1
		if box.size.z > 5.0: # long things: from the runner's lane, three-quarter
			cam.position = c + Vector3(0.55, 0.45, 1.0).normalized() * r * 2.9
	elif line:
		cam.position = Vector3(0.9, 0.6, 2.2)
		c = Vector3(0, 0, -2.0)
	else:
		cam.position = c + Vector3(0, 0.25, 1.0).normalized() * maxf(r, 0.4) * 3.6
	cam.look_at_from_position(cam.position, c)
	var l := Label.new()
	l.text = label
	l.position = Vector2(6, 4)
	l.add_theme_font_size_override("font_size", 18 if obstacle else 15)
	l.add_theme_color_override("font_color", Color("#2a140a"))
	l.add_theme_color_override("font_outline_color", Color.WHITE)
	l.add_theme_constant_override("outline_size", 5)
	vp.add_child(l)
	_cells.append([vp, at])


func vp_root(vp: SubViewport) -> Node3D:
	if not vp.has_node("R"):
		var n := Node3D.new()
		n.name = "R"
		vp.add_child(n)
	return vp.get_node("R")


func _aabb(n: Node, xf: Transform3D, acc: AABB, has: bool) -> AABB:
	var t := xf
	if n is Node3D:
		t = xf * (n as Node3D).transform
	if n is MeshInstance3D and (n as MeshInstance3D).mesh != null and not n.has_meta("ref"):
		var b: AABB = t * (n as MeshInstance3D).mesh.get_aabb()
		acc = b if acc.size == Vector3.ZERO and acc.position == Vector3.ZERO else acc.merge(b)
	for ch in n.get_children():
		acc = _aabb(ch, t, acc, has)
	return acc


func _process(_dt: float) -> bool:
	_frames += 1
	if _frames < 8:
		return false
	var img := Image.create(4 * OW, 4 * OH + 2 * PH, false, Image.FORMAT_RGB8)
	img.fill(Color("#2a140a"))
	for cell in _cells:
		var shot: Image = (cell[0] as SubViewport).get_texture().get_image()
		shot.convert(Image.FORMAT_RGB8)
		img.blit_rect(shot, Rect2i(Vector2i.ZERO, shot.get_size() - Vector2i(2, 2)), cell[1] + Vector2i(1, 1))
	var path := ProjectSettings.globalize_path(_out) if _out.begins_with("res://") else _out
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	img.save_png(path)
	print("lineup saved: ", path)
	return true
