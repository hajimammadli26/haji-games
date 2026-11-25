## The story (nağıl): the GDD's opening in five staged pictures with a caption, "Növbəti" and "Keç".
## Drawn in its own small 3D world (a SubViewport) so the street behind stays as it is.
## Spec: design/source/Cirtdan_Oyun_Senedi.pdf (the story), web prototype STORY.
##
## Usage:
##   var s := Story.new(look); layer.add_child(s); s.finished.connect(_after_story)
class_name Story
extends Control

## The last picture was closed or Keç was tapped.
signal finished
## A voice for a picture (hi_hi, yene_sensen).
signal sfx(name: String)

const PAGES := [
	{"cap": "Çox-çox qədimlərdə, Xəzərin sahilində, qala divarları ilə əhatə olunmuş köhnə Bakıda Cırtdan adlı balaca bir oğlan yaşayırdı. O, boyca balaca idi, amma ağılda hamıdan böyük idi.", "night": false, "stage": "home"},
	{"cap": "Nənəsi hər səhər təndirdə isti, ətirli yağ çörəkləri bişirir, Cırtdan da onları məhəllənin uşaqlarına paylayırdı.", "night": false, "stage": "bake"},
	{"cap": "Bir gecə dağlarda yaşayan nəhəng və acgöz Div çörəklərin ətrini hiss etdi. Gizlicə şəhərə enib bütün çörəkləri oğurladı, üstəlik nənənin sehrli təndirini də apardı!", "night": true, "stage": "steal"},
	{"voice": "hi_hi", "cap": "Cırtdan qorxmadı. Gecə yarısı Divin mağarasına girdi və Div xoruldayıb yatanda çörəklərlə dolu torbanı götürdü... Amma ayağı Divin nəhəng çarığına ilişdi!", "night": true, "stage": "cave"},
	{"voice": "yene_sensen", "cap": "— Ay Cırtdan! Yenə sənsən?! Dayan, səni tutub yeyəcəm! Qaç, Cırtdan! Torba yırtıldı, çörəklər Bakının küçələrinə səpələndi. Divdən qaç və nənənin çörəklərini yığ!", "night": true, "stage": "chase"},
]

var page := 0
var look := {}
var _vp: SubViewport
var _stage: Node3D
var _env: Environment
var _sun: DirectionalLight3D
var _cam: Camera3D
var _cap: Label
var _next: Button
var _t := 0.0


func _init(runner_look: Dictionary = {}) -> void:
	look = runner_look


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vc := SubViewportContainer.new()
	vc.stretch = true
	vc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vc)
	_vp = SubViewport.new()
	_vp.own_world_3d = true
	vc.add_child(_vp)
	var we := WorldEnvironment.new()
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	we.environment = _env
	_vp.add_child(we)
	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-45, -25, 0)
	_vp.add_child(_sun)
	_cam = Camera3D.new()
	_cam.fov = 55
	_vp.add_child(_cam)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.box(Color(0.16, 0.05, 0.03, 0.85), 22, 22))
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE, 20)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	panel.add_child(v)
	_cap = UiKit.label(v, 30, Color("#fff4dc"))
	_cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cap.custom_minimum_size = Vector2(600, 0)
	_next = UiKit.button(v, "Növbəti →", Color("#2b7a48"), 38)
	_next.size_flags_horizontal = Control.SIZE_SHRINK_END
	_next.pressed.connect(_advance)
	var skip := UiKit.button(self, "Keç", Color(0.27, 0.1, 0.06, 0.85), 30)
	skip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	skip.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	skip.pressed.connect(func() -> void: finished.emit())
	_show(0)


func _process(dt: float) -> void:
	_t += dt
	if _stage != null: # a slow push-in keeps the picture alive
		_cam.position.z -= dt * 0.12


## Shows picture i.
func _show(i: int) -> void:
	page = i
	var p: Dictionary = PAGES[i]
	_cap.text = p["cap"]
	_next.text = "Qaç!" if i == PAGES.size() - 1 else "Növbəti →"
	if p.has("voice"):
		sfx.emit(p["voice"])
	if _stage != null:
		_stage.queue_free()
	_stage = Node3D.new()
	_vp.add_child(_stage)
	var night: bool = p["night"]
	_env.background_color = Color("#1d2550") if night else Color("#8cc8f0")
	_env.ambient_light_color = Color("#6070b0") if night else Color("#f6e2c0")
	_env.ambient_light_energy = 0.5 if night else 0.9
	_sun.light_energy = 0.5 if night else 1.3
	_sun.light_color = Color("#9fb4ff") if night else Color("#fff1d6")
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(40, 40)
	ground.mesh = pm
	ground.material_override = Kit.tex("cobble", Vector2(6, 6))
	_stage.add_child(ground)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for side in [-1, 1]:
		var h: Node3D = Scenery.house("baku", side, rng)[0]
		h.rotation.y = PI / 2
		h.position = Vector3(side * 2.5, 0, -7.5)
		_stage.add_child(h)
	if night:
		Kit.part(_stage, Kit.ball(1.2), Kit.mat("#fff0c0", true), Vector3(6, 9, -20))
	match p["stage"]:
		"home":
			_at(Characters.runner(look), -0.4, 0, PI - 0.3, 1.3)
			_at(Characters.nene(), 1.1, -0.3, -0.3, 1.1)
		"bake":
			_at(Characters.nene(), -0.9, -0.2, 0.4, 1.1)
			_at(Props.tendir(), 0.5, -0.6, 0, 1.4)
			for k in 5:
				var b := Props.pickup("bread")
				b.position = Vector3(1.4 + (k % 3) * 0.35, 0.3 + (k / 3) * 0.2, 0.2)
				_stage.add_child(b)
			_at(Characters.runner(look), 2.4, 0.4, PI - 0.6, 1.3)
		"steal":
			var d := _at(Characters.div(), 0, -0.5, 0.5, 1.0)
			d.get_meta("parts")["arm_l"].rotation.x = -2.2
			d.get_meta("parts")["arm_r"].rotation.x = -2.2
			_at(Props.tendir(), 1.6, 0.6, 0, 1.0).position.y = 1.7
			for k in 4:
				var b := Props.pickup("bread")
				b.position = Vector3(-1.6 + (k % 2) * 0.4, 1.4 + k * 0.25, 0.7)
				_stage.add_child(b)
		"cave":
			for k in 9:
				var r := Kit.part(_stage, Kit.ball(1.2, -1, 7), Kit.mat("#4a4552"), Vector3(-6 + k * 1.6, 1.0, -3.0 - (k % 2)))
				r.scale = Vector3(1.0, 1.3, 0.9)
			var d := _at(Characters.div(), -0.6, -0.8, 0.3, 1.0)
			d.rotation.z = PI / 2 - 0.15
			d.position.y = 0.9
			var c := _at(Characters.runner(look), 1.8, 0.6, PI + 0.9, 1.3)
			c.get_meta("parts")["leg_l"].rotation.x = 0.7
			c.get_meta("parts")["leg_r"].rotation.x = -0.5
			Kit.part(_stage, Kit.ball(0.45, 0.8), Kit.mat("#c9a46a"), Vector3(2.7, 0.45, 0.5))
		_:
			var d := _at(Characters.div(), -1.8, -1.0, 0.7, 1.0)
			d.get_meta("parts")["arm_l"].rotation.x = -2.4
			d.get_meta("parts")["arm_r"].rotation.x = -1.6
			var c := _at(Characters.runner(look), 1.6, 0.6, PI / 2 + 0.2, 1.3)
			var parts: Dictionary = c.get_meta("parts")
			parts["leg_l"].rotation.x = 0.9
			parts["leg_r"].rotation.x = -0.9
			parts["arm_l"].rotation.x = -0.9
			parts["arm_r"].rotation.x = 0.9
			for k in 8:
				var b := Props.pickup("bread")
				b.position = Vector3(0.6 + k * 0.45, 0.25 + absf(sin(k)) * 0.8, 0.3 + (k % 3) * 0.4)
				b.rotation = Vector3(k, k * 2, 0)
				_stage.add_child(b)
	var far: bool = p["stage"] == "steal" or p["stage"] == "chase"
	_cam.position = Vector3(0.4, 2.9 if far else 2.2, 9.5 if far else 7.2)
	_cam.look_at(Vector3(0.4, 1.7 if far else 1.4, 0))
	_cam.position.y -= 1.0 # the caption covers the lower part of the screen: lift the picture
	_cam.look_at(Vector3(0.4, (1.7 if far else 1.4) - 1.4, 0))


func _at(n: Node3D, x: float, z: float, ry: float, sc: float) -> Node3D:
	n.position = Vector3(x, 0, z)
	n.rotation.y = ry
	n.scale = Vector3.ONE * sc
	_stage.add_child(n)
	return n


func _advance() -> void:
	if page + 1 >= PAGES.size():
		finished.emit()
	else:
		_show(page + 1)
