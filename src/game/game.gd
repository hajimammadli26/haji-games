## The run, drawn and played: builds the street, draws RunSim's obstacles and pickups, follows Cırtdan with the
## camera, reads swipes, taps and keys, shows the HUD (score, bread, nar, power-up bars, the carpet and boost
## buttons, pause), and the game-over panel with the nar continue. Banks bread and the best score in SaveData.
## Spec: the web prototype prototypes/cirtdan/ (design/game-brief.md, Build order step 5: the Godot version).
##
## Developer flags after "--" on the command line (players never pass them):
##   --seed=N         the street's seed
##   --autopilot      a simple bot dodges, for unattended checks
##   --fresh          a throwaway save (user://check_save.json), started empty
##   --boosts=N       that throwaway save starts with N start boosts (the autopilot uses one)
##   --auto_continue  after the first game over, spend nar on the continue at once
##   --shot=PATH      save a screenshot to PATH ...
##   --shot_at=SEC    ... after SEC seconds of running, then quit (or a second after a game over)
extends Node3D

const TUNING_PATH := "res://src/data/tuning.tres"
const POWER_NAMES := {"magnet": "Nənənin sinisi", "shoe": "Sehrli çarıq", "double": "Qoşa təndir: x2",
	"pole": "Kəndirbaz çubuğu", "simurq": "Simurq quşu", "fly": "Xalça ilə uçuş", "carpet": "Uçan xalça"}

var tune: Tuning
var save: SaveData
var sim: RunSim
var gen: TrackGen
var input := RunSim.RunInput.new()
var runner: Node3D
var div_fig: Node3D
var bird: Node3D
var fly_carpet: Node3D
var camera: Camera3D
var street: MeshInstance3D
var houses: Array = [] ## [node, far end s]
var house_next := {-1: -20.0, 1: -20.0}
var house_rng := RandomNumberGenerator.new()
var anim_t := 0.0
var started := false
var paused := false
var banked := 0 ## bread of this run already in the save (a continue never banks it twice)
var last_tap := -1.0
var touch_start := Vector2.ZERO
var touch_done := true
var args := {}
var shooting := false
var dead_t := 0.0
# HUD
var hud_root: Control
var hud_score: Label
var hud_bread: Label
var hud_nar: Label
var hud_banner: Label
var banner_t := 0.0
var power_box: VBoxContainer
var power_rows := {} ## kind -> [row, bar]
var carpet_btn: Button
var boost_btn: Button
var pause_btn: Button
var title_panel: Control
var pause_panel: Control
var over_panel: Control
var over_text: Label
var continue_btn: Button


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	tune = load(TUNING_PATH)
	if args.has("fresh"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://check_save.json"))
		save = SaveData.new("user://check_save.json", tune.start_nar)
		save.put("boosts", int(args.get("boosts", "0")))
	else:
		save = SaveData.new(SaveData.PATH, tune.start_nar)
	_build_world()
	_build_hud()
	_new_run()
	if args.has("shot"): # an unattended check starts at once
		_start()


# --- world -------------------------------------------------------------------------------------

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("#3d8fd6")
	sm.sky_horizon_color = Color("#f6dfae")
	sm.ground_horizon_color = Color("#f3d6a4")
	sm.ground_bottom_color = Color("#c98a4a")
	sky.sky_material = sm
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.9
	e.fog_enabled = true
	e.fog_light_color = Color("#f3d6a4")
	e.fog_density = 0.004
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.2
	sun.light_color = Color("#fff1d6")
	add_child(sun)
	street = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(8, 400)
	street.mesh = pm
	street.material_override = Figures.mat(Color("#bfa27a"))
	add_child(street)
	for sx in [-1.1, 1.1]: # lane grooves
		var gr := MeshInstance3D.new()
		var gb := BoxMesh.new()
		gb.size = Vector3(0.08, 0.02, 400)
		gr.mesh = gb
		gr.material_override = Figures.mat(Color("#7d6a4f"))
		gr.position.x = sx * tune.lane_width / 2.2
		gr.set_meta("follow", true)
		add_child(gr)
	runner = Figures.cirtdan()
	add_child(runner)
	fly_carpet = Figures.flying_carpet()
	fly_carpet.position.y = 0.08
	fly_carpet.visible = false
	runner.add_child(fly_carpet)
	div_fig = Figures.div()
	div_fig.scale = Vector3.ONE * 0.85
	div_fig.rotation.y = PI # runs toward -z, his back to the camera
	add_child(div_fig)
	bird = Figures.simurq()
	bird.visible = false
	add_child(bird)
	camera = Camera3D.new()
	camera.fov = 60
	camera.far = 400
	add_child(camera)


func _new_run() -> void:
	for o in (sim.obstacles if sim else []):
		if o.node:
			o.node.queue_free()
	for p in (sim.pickups if sim else []):
		if p.node:
			p.node.queue_free()
	for h in houses:
		h[0].queue_free()
	houses.clear()
	house_next = {-1: -20.0, 1: -20.0}
	var seed_value := int(args.get("seed", str(Time.get_ticks_usec() % 100000)))
	house_rng.seed = seed_value + 17
	sim = RunSim.new(tune)
	sim.levels = save.get_value("levels")
	sim.carpets += int(save.get_value("carpets"))
	sim.boosts = int(save.get_value("boosts"))
	sim.stumbled.connect(_banner.bind("Ay Cırtdaaan!"))
	sim.crashed.connect(_on_dead)
	sim.caught.connect(_on_dead.bind(""))
	sim.power_taken.connect(_on_power)
	sim.nar_taken.connect(_on_nar)
	sim.shield_used.connect(_banner.bind("Uçan xalça səni qorudu!"))
	sim.landed_from_flight.connect(_banner.bind("Yerə endin"))
	gen = TrackGen.new(sim, seed_value)
	gen.fill()
	_fill_houses()
	banked = 0
	over_panel.visible = false
	_sync()


func _fill_houses() -> void:
	for side in [-1, 1]:
		while house_next[side] < sim.s + tune.view_ahead + 20.0:
			var made: Array = Figures.house(side, house_rng)
			var node: Node3D = made[0]
			var w: float = made[1]
			node.position = Vector3(side * 4.3, 0, -(house_next[side] + w * 0.5))
			add_child(node)
			houses.append([node, house_next[side] + w])
			house_next[side] += w + (2.5 if house_rng.randf() < 0.15 else 0.05)
	for i in range(houses.size() - 1, -1, -1):
		if houses[i][1] < sim.s - 25.0:
			houses[i][0].queue_free()
			houses.remove_at(i)


# --- the step ----------------------------------------------------------------------------------

func _physics_process(dt: float) -> void:
	if not started or paused or sim.dead != "":
		input.clear()
		if started and args.has("auto_continue") and sim.dead != "" and sim.continues == 0 and over_panel.visible: # a check of the nar continue
			_on_continue()
			return
		if started and args.has("shot") and sim.dead != "" and not shooting: # a check that ends in a game over
			dead_t += dt
			if dead_t > 1.0:
				shooting = true
				_shoot()
		return
	if args.has("autopilot"):
		_autopilot()
	var carpets_before := sim.carpets
	var free_before := sim.free_carpets
	var boosts_before := sim.boosts
	sim.step(dt, input)
	input.clear()
	if sim.carpets < carpets_before and sim.free_carpets == free_before: # a bought carpet was used
		save.set_value("carpets", maxi(0, int(save.get_value("carpets")) - 1))
	if sim.boosts < boosts_before:
		save.set_value("boosts", sim.boosts)
	gen.fill()
	_fill_houses()
	if args.has("shot") and sim.time >= float(args.get("shot_at", "3")) and not shooting:
		shooting = true
		_shoot()


func _process(dt: float) -> void:
	anim_t += dt
	banner_t = maxf(0.0, banner_t - dt)
	hud_banner.visible = banner_t > 0.0
	_sync()
	_update_hud()


## Places every drawing where the run says it is, between the last two steps so the view never judders.
func _sync() -> void:
	var a := Engine.get_physics_interpolation_fraction() if started and not paused else 1.0
	var s := lerpf(sim.prev_s, sim.s, a)
	var x := lerpf(sim.prev_x, sim.x, a)
	var y := lerpf(sim.prev_y, sim.y, a)
	runner.position = Vector3(x, y, -s)
	runner.visible = sim.invuln <= 0.0 or int(anim_t * 12.0) % 2 == 0
	_pose_runner()
	fly_carpet.visible = sim.carpet_t > 0.0 or sim.power["fly"] > 0.0
	bird.visible = sim.power["simurq"] > 0.0 and sim.dead == ""
	if bird.visible: # Cırtdan hangs from its talons
		bird.position = Vector3(x, y + 1.6, -s)
		var flap := sin(anim_t * 9.0) * 0.5
		var wings: Array = bird.get_meta("parts")["wings"]
		wings[0].rotation.z = flap
		wings[1].rotation.z = -flap
	var gap := sim.div_gap
	if sim.intro_t > 0.0 and sim.div_t <= 0.0:
		gap = maxf(gap, 4.5) # the opening chase: further back and to the side
	div_fig.position = Vector3(x * 0.6 - (1.9 if sim.intro_t > 0.0 else 0.9), 0, -(s - gap))
	div_fig.visible = gap < tune.div_far_gap - 1.0
	_pose_div()
	for o in sim.obstacles:
		if o.node == null:
			o.node = Figures.obstacle(o.kind, o.length)
			add_child(o.node)
		o.node.visible = not o.cleared
		o.node.position = Vector3(sim.lane_x(o.lane), 0, -(o.s0 + o.length * 0.5))
	for p in sim.pickups:
		if p.node == null:
			p.node = Figures.pickup(p.kind)
			add_child(p.node)
		if p.taken:
			p.node.scale = p.node.scale * 0.8
			p.node.position.y += 0.1
			p.node.visible = p.node.scale.x > 0.05
		else:
			var bob := 0.0 if p.kind == "bread" else sin(anim_t * 3.0 + p.s) * 0.12
			p.node.position = Vector3(p.x, p.y + bob, -p.s)
			p.node.rotation.y = anim_t * 3.0 + p.s
	street.position = Vector3(0, 0, -s - 150.0)
	for c in get_children():
		if c.has_meta("follow"):
			c.position.z = -s - 150.0
	var tall := get_viewport().get_visible_rect().size.aspect() < 1.0 # a phone held upright: closer, lower
	var follow := 0.85 if tall else 0.55
	camera.fov = 75.0 if tall else 60.0
	camera.position = Vector3(x * follow, (4.3 if tall else 3.7) + y * 0.6, -s + (4.9 if tall else 6.2))
	camera.look_at(Vector3(x * (0.75 if tall else 0.3), (0.9 if tall else 1.0) + y * 0.55, -s - (8.0 if tall else 7.0)))


func _pose_runner() -> void:
	var parts: Dictionary = runner.get_meta("parts")
	var rig: Node3D = parts["rig"]
	var run := sin(anim_t * minf(18.0, 6.0 + sim.speed * 0.5))
	rig.rotation.x = 0.0
	rig.position.y = 0.0
	if sim.is_sliding() and sim.grounded: # slide: lean back
		rig.rotation.x = -1.15
		rig.position.y = 0.18
	elif not sim.grounded: # jump or flight: knees up, arms up
		parts["leg_l"].rotation.x = -0.9
		parts["leg_r"].rotation.x = -0.3
		parts["arm_l"].rotation.x = -2.6
		parts["arm_r"].rotation.x = -2.4
	else:
		parts["leg_l"].rotation.x = run * 0.9
		parts["leg_r"].rotation.x = -run * 0.9
		parts["arm_l"].rotation.x = -run * 0.9
		parts["arm_r"].rotation.x = run * 0.9
		rig.position.y = absf(run) * 0.06
	if sim.dead == "crash":
		runner.rotation.x = minf(1.4, runner.rotation.x + 0.1)
	elif sim.dead == "":
		runner.rotation.x = 0.0


func _pose_div() -> void:
	var parts: Dictionary = div_fig.get_meta("parts")
	var run := sin(anim_t * (4.0 + sim.speed * 0.3))
	parts["leg_l"].rotation.x = run * 0.7
	parts["leg_r"].rotation.x = -run * 0.7
	parts["arm_l"].rotation.x = -run * 0.8 - 0.3
	parts["arm_r"].rotation.x = run * 0.5 - 1.2
	parts["rig"].position.y = absf(run) * 0.12


# --- input: keys for development, swipes and taps on the phone ------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_LEFT, KEY_A: input.left = true
			KEY_RIGHT, KEY_D: input.right = true
			KEY_UP, KEY_W, KEY_SPACE: input.jump = true
			KEY_DOWN, KEY_S: input.slide = true
			KEY_SHIFT, KEY_E: input.carpet = true
			KEY_B: input.boost = true
			KEY_P, KEY_ESCAPE: _set_paused(not paused)
			KEY_ENTER:
				if not started or sim.dead != "":
					_start()
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_done = false
		elif not touch_done: # a tap
			touch_done = true
			if not started:
				_start()
				return
			var now := Time.get_ticks_msec() / 1000.0
			if now - last_tap < 0.32: # two taps: the flying carpet
				input.carpet = true
				last_tap = -1.0
			else:
				last_tap = now
	elif event is InputEventScreenDrag and not touch_done:
		var d: Vector2 = event.position - touch_start
		var size := get_viewport().get_visible_rect().size
		var m := minf(size.x, size.y) * 0.06
		if absf(d.x) < m and absf(d.y) < m:
			return
		touch_done = true # one swipe per touch, as soon as it is clear
		if absf(d.x) > absf(d.y):
			if d.x > 0: input.right = true
			else: input.left = true
		elif d.y > 0:
			input.slide = true
		else:
			input.jump = true


func _start() -> void:
	if sim.dead != "":
		_new_run()
	started = true
	title_panel.visible = false


func _set_paused(on: bool) -> void:
	if not started or sim.dead != "":
		return
	paused = on
	pause_panel.visible = on
	if on:
		_bank() # leaving the app or the run never loses its bread


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_set_paused(true)


# --- events from the run ------------------------------------------------------------------------

func _on_dead(_kind: String) -> void:
	_bank()
	if int(sim.score) > int(save.get_value("best")):
		save.set_value("best", int(sim.score))
	var cost := sim.continue_cost()
	var have := int(save.get_value("nar"))
	over_text.text = "%s\n\nXal: %d\nYağ çörəyi: %d\nRekord: %d" % [
		"Hamm! Div səni tutdu!" if sim.dead == "caught" else "Bam! Div səni tutdu!",
		int(sim.score), sim.bread, int(save.get_value("best"))]
	continue_btn.text = "Nar ilə davam et (%d)" % cost
	continue_btn.disabled = have < cost
	over_panel.visible = true


func _on_power(kind: String) -> void:
	_banner(POWER_NAMES.get(kind, kind) + "!")


func _on_nar() -> void:
	save.set_value("nar", int(save.get_value("nar")) + 1)
	_banner("Nar!")


func _on_continue() -> void:
	var cost := sim.continue_cost()
	if int(save.get_value("nar")) < cost:
		return
	save.set_value("nar", int(save.get_value("nar")) - cost)
	sim.continue_run()
	over_panel.visible = false
	dead_t = 0.0
	_banner("Nar ilə davam!")


func _bank() -> void: # adds this run's new bread to the save, once
	var add := sim.bread - banked
	if add > 0:
		save.set_value("bread", int(save.get_value("bread")) + add)
		banked = sim.bread


func _banner(t: String) -> void:
	hud_banner.text = t
	banner_t = 1.6


# --- HUD ----------------------------------------------------------------------------------------

func _label(parent: Control, size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color("#3c140a"))
	l.add_theme_constant_override("outline_size", maxi(6, size / 4))
	parent.add_child(l)
	return l


func _button(parent: Control, t: String, color: Color, size: int = 34) -> Button:
	var b := Button.new()
	b.text = t
	b.add_theme_font_size_override("font_size", size)
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, sb)
	var dis := sb.duplicate()
	dis.bg_color = Color(color, 0.4)
	b.add_theme_stylebox_override("disabled", dis)
	b.focus_mode = Control.FOCUS_NONE
	parent.add_child(b)
	return b


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud_root)
	var root := hud_root
	hud_score = _label(root, 52, Color("#fff4dc"))
	hud_score.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	hud_score.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_bread = _label(root, 38, Color("#ffd77a"))
	hud_bread.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	hud_bread.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_bread.position.y += 76
	hud_nar = _label(root, 34, Color("#ffb3bd"))
	hud_nar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	hud_nar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_nar.position.y += 130
	pause_btn = _button(root, "II", Color(0.27, 0.1, 0.06, 0.75), 40)
	pause_btn.position = Vector2(24, 24)
	pause_btn.custom_minimum_size = Vector2(96, 96)
	pause_btn.pressed.connect(_set_paused.bind(true))
	power_box = VBoxContainer.new()
	power_box.position = Vector2(24, 140)
	power_box.add_theme_constant_override("separation", 10)
	power_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(power_box)
	for k in ["magnet", "shoe", "double", "pole", "simurq", "fly", "carpet"]:
		var row := VBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var l := _label(row, 26, Color("#fff4dc"))
		l.text = POWER_NAMES[k]
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(240, 18)
		bar.show_percentage = false
		bar.max_value = 1.0
		bar.step = 0.0
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(bar)
		power_box.add_child(row)
		power_rows[k] = [row, bar]
	carpet_btn = _button(root, "", Color(0.17, 0.48, 0.28, 0.85), 30)
	carpet_btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 24)
	carpet_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	carpet_btn.pressed.connect(func() -> void: input.carpet = true)
	boost_btn = _button(root, "Uçuş!", Color(0.17, 0.48, 0.28, 0.95), 40)
	boost_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 200)
	boost_btn.grow_horizontal = Control.GROW_DIRECTION_BOTH
	boost_btn.grow_vertical = Control.GROW_DIRECTION_BEGIN
	boost_btn.pressed.connect(func() -> void: input.boost = true)
	hud_banner = _label(root, 50, Color("#ffd77a"))
	hud_banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 0)
	hud_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_banner.position.y = 300
	hud_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_banner.visible = false
	title_panel = _panel(root, "Cırtdan\nKöhnə Bakıda Qaçış\n\nToxun və ya Enter: Qaç!\n\nSürüşdür: ← → zolaq, ↑ tullan, ↓ sürüş\nİki dəfə toxun: uçan xalça")
	pause_panel = _panel(root, "Fasilə")
	var go := _button(pause_panel.get_child(1), "Davam", Color("#2b7a48"), 44)
	go.pressed.connect(_set_paused.bind(false))
	pause_panel.visible = false
	over_panel = _panel(root, "")
	over_text = over_panel.get_child(0)
	var box: VBoxContainer = over_panel.get_child(1)
	continue_btn = _button(box, "Nar ilə davam et", Color("#8e1d22"), 38)
	continue_btn.pressed.connect(_on_continue)
	var again := _button(box, "Yenidən qaç", Color("#2b7a48"), 44)
	again.pressed.connect(_start)
	over_panel.visible = false


## A full-screen shaded panel: text in the upper half, a column of buttons (its child 1) under it.
func _panel(root: Control, t: String) -> Control:
	var shade := ColorRect.new()
	shade.color = Color(0.16, 0.05, 0.03, 0.6)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	var l := _label(shade, 44, Color("#ffd77a"))
	l.text = t
	l.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 24)
	l.position.y = 180
	l.custom_minimum_size.y = 460
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 260)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.add_theme_constant_override("separation", 24)
	shade.add_child(box)
	return shade


func _update_hud() -> void:
	hud_score.text = "%06d" % int(sim.score)
	hud_bread.text = "çörək %d" % sim.bread
	hud_nar.text = "nar %d" % int(save.get_value("nar"))
	for k in power_rows:
		var left: float = sim.carpet_t if k == "carpet" else sim.power[k]
		var full: float = tune.carpet_time if k == "carpet" else sim.power_time(k)
		power_rows[k][0].visible = left > 0.0
		power_rows[k][1].value = left / full
	carpet_btn.visible = sim.carpets > 0 and sim.carpet_t <= 0.0 and sim.dead == "" and started
	carpet_btn.text = "Xalça x%d" % sim.carpets
	boost_btn.visible = sim.boost_open() and started
	boost_btn.text = "Uçuş! x%d" % sim.boosts
	pause_btn.visible = started and sim.dead == ""


# --- unattended checks (developer flags only) --------------------------------------------------

func _autopilot() -> void: # dodges what is right ahead in its lane: enough to reach later rows in a check
	if sim.boost_open() and sim.time > 1.0:
		input.boost = true
	for o in sim.obstacles:
		if o.lane != sim.lane or o.ramp or o.hit or o.cleared:
			continue
		var ahead := o.s0 - sim.s
		if ahead < 0.0 or ahead > 9.0:
			continue
		if o.kind == "basket" and ahead < 4.0 and sim.grounded:
			input.jump = true
		elif o.kind == "carpet" and ahead < 5.0:
			input.slide = true
		elif o.kind != "basket" and o.kind != "carpet":
			if sim.lane > 0 and _lane_clear(sim.lane - 1): input.left = true
			elif sim.lane < 2 and _lane_clear(sim.lane + 1): input.right = true
		return


func _lane_clear(l: int) -> bool:
	for o in sim.obstacles:
		if o.lane == l and not o.ramp and not o.cleared and o.s1() > sim.s - 1.0 and o.s0 < sim.s + 12.0:
			return false
	return true


func _shoot() -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args["shot"])
	print("SHOT %s time=%.1f s=%.0f bread=%d dead=%s save_bread=%d nar=%d" % [args["shot"], sim.time, sim.s, sim.bread,
		sim.dead, int(save.get_value("bread")), int(save.get_value("nar"))])
	get_tree().quit()
