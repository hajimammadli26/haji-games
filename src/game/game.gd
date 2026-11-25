## The run, drawn and played: builds the street, draws RunSim's obstacles and pickups, follows Cırtdan with the
## camera, reads swipes and keys, and shows the score, the bread count and the game-over panel.
## Spec: the web prototype prototypes/cirtdan/ (design/game-brief.md, Build order step 5: the Godot version).
##
## Developer flags after "--" on the command line (players never pass them):
##   --seed=N         the street's seed
##   --autopilot      a simple bot dodges, for unattended checks
##   --shot=PATH      save a screenshot to PATH ...
##   --shot_at=SEC    ... after SEC seconds of running, then quit
extends Node3D

const TUNING_PATH := "res://src/data/tuning.tres"

var tune: Tuning
var sim: RunSim
var gen: TrackGen
var input := RunSim.RunInput.new()
var runner: Node3D
var div_fig: Node3D
var camera: Camera3D
var street: MeshInstance3D
var houses: Array = [] ## [node, far end s]
var house_next := {-1: -20.0, 1: -20.0}
var house_rng := RandomNumberGenerator.new()
var anim_t := 0.0
var started := false
var hud_score: Label
var hud_bread: Label
var hud_banner: Label
var banner_t := 0.0
var title_panel: Control
var over_panel: Control
var over_text: Label
var touch_start := Vector2.ZERO
var touch_done := true
var args := {}
var shooting := false
var dead_t := 0.0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	tune = load(TUNING_PATH)
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
	div_fig = Figures.div()
	div_fig.scale = Vector3.ONE * 0.85
	div_fig.rotation.y = PI # runs toward -z, his back to the camera
	add_child(div_fig)
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
	sim.stumbled.connect(_on_stumbled)
	sim.crashed.connect(_on_dead)
	sim.caught.connect(_on_dead.bind(""))
	gen = TrackGen.new(sim, seed_value)
	gen.fill()
	_fill_houses()
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
	if not started or sim.dead != "":
		input.clear()
		if started and args.has("shot") and not shooting: # a check that ends in a game over: shoot it a second later
			dead_t += dt
			if dead_t > 1.0:
				shooting = true
				_shoot()
		return
	if args.has("autopilot"):
		_autopilot()
	sim.step(dt, input)
	input.clear()
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


## Places every drawing where the run says it is, between the last two steps so the view never judders.
func _sync() -> void:
	var a := Engine.get_physics_interpolation_fraction() if started else 1.0
	var s := lerpf(sim.prev_s, sim.s, a)
	var x := lerpf(sim.prev_x, sim.x, a)
	var y := lerpf(sim.prev_y, sim.y, a)
	runner.position = Vector3(x, y, -s)
	_pose_runner()
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
		o.node.position = Vector3(sim.lane_x(o.lane), 0, -(o.s0 + o.length * 0.5))
	for p in sim.pickups:
		if p.node == null:
			p.node = Figures.bread()
			add_child(p.node)
		if p.taken:
			p.node.scale = p.node.scale * 0.8
			p.node.position.y += 0.1
			p.node.visible = p.node.scale.x > 0.05
		else:
			p.node.position = Vector3(p.x, p.y, -p.s)
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
	hud_score.text = "%06d" % int(sim.score)
	hud_bread.text = "çörək: %d" % sim.bread


func _pose_runner() -> void:
	var parts: Dictionary = runner.get_meta("parts")
	var rig: Node3D = parts["rig"]
	var run := sin(anim_t * minf(18.0, 6.0 + sim.speed * 0.5))
	rig.rotation.x = 0.0
	rig.position.y = 0.0
	if sim.is_sliding() and sim.grounded: # slide: lean back
		rig.rotation.x = -1.15
		rig.position.y = 0.18
	elif not sim.grounded: # jump: knees up
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
			KEY_ENTER:
				if not started or sim.dead != "":
					_start()
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_done = false
		elif not touch_done: # a tap
			touch_done = true
			if not started or sim.dead != "":
				_start()
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


# --- events from the run ------------------------------------------------------------------------

func _on_stumbled() -> void:
	_banner("Ay Cırtdaaan!")


func _on_dead(kind: String) -> void:
	over_text.text = "Div səni tutdu!\nXal: %d\nYağ çörəyi: %d\n\nToxun və ya Enter: yenidən qaç" % [int(sim.score), sim.bread]
	over_panel.visible = true


func _banner(t: String) -> void:
	hud_banner.text = t
	banner_t = 1.6


# --- HUD ----------------------------------------------------------------------------------------

func _label(parent: Control, size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color("#3c140a"))
	l.add_theme_constant_override("outline_size", maxi(4, size / 5))
	parent.add_child(l)
	return l


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	hud_score = _label(root, 44, Color("#fff4dc"))
	hud_score.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	hud_score.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_bread = _label(root, 32, Color("#ffd77a"))
	hud_bread.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	hud_bread.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_bread.position.y += 64
	hud_banner = _label(root, 46, Color("#ffd77a"))
	hud_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	hud_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_banner.position.y = 220
	hud_banner.visible = false
	title_panel = _panel(root, "Cırtdan\nKöhnə Bakıda Qaçış\n\nToxun və ya Enter: Qaç!\nSürüşdür: ← → zolaq, ↑ tullan, ↓ sürüş")
	var over := _panel(root, "")
	over_panel = over
	over_text = over.get_child(0)
	over_panel.visible = false


func _panel(root: Control, t: String) -> Control:
	var shade := ColorRect.new()
	shade.color = Color(0.16, 0.05, 0.03, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	var l := _label(shade, 38, Color("#ffd77a"))
	l.text = t
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 24) # fills the screen, 24 px in
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return shade


# --- unattended checks (developer flags only) --------------------------------------------------

func _autopilot() -> void: # dodges what is right ahead in its lane: enough to reach later rows in a check
	for o in sim.obstacles:
		if o.lane != sim.lane or o.ramp or o.hit:
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
		if o.lane == l and not o.ramp and o.s1() > sim.s - 1.0 and o.s0 < sim.s + 12.0:
			return false
	return true


func _shoot() -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args["shot"])
	print("SHOT %s time=%.1f s=%.0f bread=%d dead=%s" % [args["shot"], sim.time, sim.s, sim.bread, sim.dead])
	get_tree().quit()
