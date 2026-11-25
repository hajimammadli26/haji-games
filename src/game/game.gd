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
##   --menu=SCREEN    with --shot: open that menu screen (home, shop, chars ...) and shoot it instead of a run
##   --bread=N        that throwaway save starts with N bread
##   --char=ID --costume=ID --city=ID   that throwaway save wears this look
##   --lang=CODE      that save's language (az, tr, en, ru); --untranslated prints untranslated texts at the shot
##   --story=N        with --shot: show the story at picture N (0-4) and shoot it
extends Node3D

const TUNING_PATH := "res://src/data/tuning.tres"
const POWER_NAMES := {"magnet": "Nənənin sinisi", "shoe": "Sehrli çarıq", "double": "Qoşa təndir: x2",
	"pole": "Kəndirbaz çubuğu", "simurq": "Simurq quşu", "fly": "Xalça ilə uçuş", "carpet": "Uçan xalça"}

var tune: Tuning
var save: SaveData
var prog: Progress
var menu: Menu
var recorded := true ## the last run is already in the leaderboard
var roof_t := 0.0 ## seconds on cart roofs, counted toward the roof mission in whole seconds
var dist_t := 0.0
var sim: RunSim
var gen: TrackGen
var input := RunSim.RunInput.new()
var runner: Node3D
var div_fig: Node3D
var bird: Node3D
var fly_carpet: Node3D
var camera: Camera3D
var world: World
var fx: Fx
var anim := Animator.new()
var shake := 0.0 ## seconds of camera shake left (a stumble, a crash)
var escaped_now := false ## the Div was just shaken off (Cırtdan sticks out his tongue)
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
var hud_layer: CanvasLayer
var story: Story
var snd: Sound
var _was_grounded := true
var _was_lane := 1
var hud_score: Label
var hud_bread: Label
var hud_nar: Label
var hud_counts: VBoxContainer
var hud_banner: Label
var banner_t := 0.0
var word_box: HBoxContainer ## the day's word as tiles, shown for a moment when a letter is taken
var word_t := 0.0
var count_label: Label ## buta stones or magic stones, shown for a moment
var count_t := 0.0
var power_box: VBoxContainer
var power_rows := {} ## kind -> [row, bar]
var carpet_btn: Button
var boost_btn: Button
var pause_btn: Button
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
		save.put("bread", int(args.get("bread", "0")))
		for k in ["char", "costume", "city"]: # a look to check, without buying it
			if args.has(k):
				save.put(k, args[k])
	else:
		save = SaveData.new(SaveData.PATH, tune.start_nar)
	prog = Progress.new(save, tune)
	if args.has("lang"):
		save.put("lang", args["lang"])
	Lang.install(String(save.get_value("lang")))
	prog.mission_done.connect(func(_t: String) -> void: _banner("Tapşırıq bitdi!"))
	snd = Sound.new(save)
	add_child(snd)
	_build_world()
	_build_hud()
	_apply_look()
	_new_run()
	var g := prog.daily_gift() if not args.has("shot") else ""
	if g != "":
		menu.toast("Nənənin bu günkü hədiyyəsi: %s" % g, 4.0)
		menu.refresh()
	if args.has("story") and args.has("shot"):
		_show_story(false)
		for i in int(args["story"]):
			story._advance()
		await get_tree().create_timer(1.0).timeout
		_shoot()
	elif args.has("menu") and args.has("shot"):
		menu.open(args["menu"])
		await get_tree().create_timer(1.0).timeout
		_shoot()
	elif args.has("shot"): # an unattended check starts at once
		_start()


# --- world -------------------------------------------------------------------------------------

func _build_world() -> void:
	world = World.new(tune)
	add_child(world)
	world.letter_text = func() -> String:
		var dw := prog.day_word()
		return String(dw["word"])[dw["got"]]
	fx = Fx.new()
	add_child(fx)
	fly_carpet = Characters.flying_carpet()
	fly_carpet.position.y = 0.08
	fly_carpet.visible = false
	div_fig = Characters.div()
	div_fig.scale = Vector3.ONE * 0.85
	div_fig.rotation.y = PI # runs toward -z, his back to the camera
	add_child(div_fig)
	bird = Characters.simurq()
	bird.visible = false
	add_child(bird)
	camera = Camera3D.new()
	camera.fov = 60
	camera.far = 500
	add_child(camera)


## Draws Cırtdan as the chosen character and costume, and the street as the chosen city.
func _apply_look() -> void:
	if runner != null:
		runner.remove_child(fly_carpet)
		runner.queue_free()
	runner = Characters.runner(prog.look())
	add_child(runner)
	runner.add_child(fly_carpet)
	var city := String(save.get_value("city"))
	if city != world.city:
		world.set_city(city)
		if sim != null and not started:
			_new_run() # the new city's street


func _new_run() -> void:
	for o in (sim.obstacles if sim else []):
		if o.node:
			o.node.queue_free()
	for p in (sim.pickups if sim else []):
		if p.node:
			p.node.queue_free()
	var seed_value := int(args.get("seed", str(Time.get_ticks_usec() % 100000)))
	world.reset(seed_value)
	sim = RunSim.new(tune)
	sim.levels = save.get_value("levels")
	sim.carpets += int(save.get_value("carpets"))
	sim.boosts = int(save.get_value("boosts"))
	sim.base_mult = int(save.get_value("mmult"))
	sim.bread_taken.connect(func(total: int) -> void:
		snd.play("bread", 0.96 + 0.08 * float(total % 5) / 4.0)
		fx.burst(runner.position + Vector3(0, 0.9, -0.4), Color("#ffd34a"), 8)
		prog.mission("run_bread", total)
		prog.mission("bread", 1))
	sim.passed.connect(func(kind: String) -> void:
		if kind == "basket" or kind == "carpet":
			prog.mission(kind, 1))
	sim.escaped.connect(func() -> void:
		prog.mission("escape", 1)
		escaped_now = true)
	sim.item_taken.connect(_on_item)
	sim.stumbled.connect(func() -> void:
		_banner("Ay Cırtdaaan!")
		snd.play("stumble")
		snd.play("ay_cirtdan")
		shake = 0.35)
	sim.crashed.connect(func(k: String) -> void:
		snd.play("crash")
		shake = 0.6
		_on_dead(k))
	sim.caught.connect(func() -> void:
		snd.play("hamm")
		shake = 0.4
		_on_dead(""))
	sim.jumped.connect(snd.play.bind("jump"))
	sim.slid.connect(snd.play.bind("slide"))
	sim.shield_used.connect(snd.play.bind("shield"))
	sim.power_taken.connect(_on_power)
	sim.nar_taken.connect(_on_nar)
	sim.shield_used.connect(_banner.bind("Uçan xalça səni qorudu!"))
	sim.landed_from_flight.connect(_banner.bind("Yerə endin"))
	gen = TrackGen.new(sim, seed_value)
	gen.hunt_open = prog.hunt()["open"]
	gen.treats = Props.TREATS.has(world.city)
	gen.fill()
	banked = 0
	over_panel.visible = false
	anim = Animator.new()
	_sync(0.0)


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
	if sim.grounded and not _was_grounded and sim.dead == "":
		snd.play("land")
		fx.burst(Vector3(sim.x, sim.y + 0.05, -sim.s), Color(0.85, 0.72, 0.52, 0.8), 10)
	if sim.lane != _was_lane:
		snd.play("lane")
	_was_grounded = sim.grounded
	_was_lane = sim.lane
	if sim.carpets < carpets_before and sim.free_carpets == free_before: # a bought carpet was used
		save.set_value("carpets", maxi(0, int(save.get_value("carpets")) - 1))
	if sim.boosts < boosts_before:
		save.set_value("boosts", sim.boosts)
	if sim.on_roof == "cart" and sim.grounded:
		roof_t += dt
		if roof_t >= 1.0:
			roof_t -= 1.0
			prog.mission("roof", 1)
	dist_t += dt
	if dist_t >= 0.5:
		dist_t = 0.0
		prog.mission("run_dist", sim.s)
	gen.fill()
	if args.has("shot") and sim.time >= float(args.get("shot_at", "3")) and not shooting:
		shooting = true
		_shoot()


func _process(dt: float) -> void:
	anim_t += dt
	banner_t = maxf(0.0, banner_t - dt)
	hud_banner.visible = banner_t > 0.0 and started and not menu.visible
	word_t = maxf(0.0, word_t - dt)
	word_box.visible = word_t > 0.0 and started
	word_box.modulate.a = minf(1.0, word_t / 0.5)
	count_t = maxf(0.0, count_t - dt)
	count_label.visible = count_t > 0.0 and started
	_sync(dt)
	_update_hud()
	if not started or (sim.dead != "" and over_panel.visible) or story != null:
		snd.music("menu")
	else:
		snd.music("fly" if sim.is_flying() else "run")
		snd.set_speed_ratio(1.0 + (sim.speed - tune.speed_start) * tune.music_bpm_gain / tune.music_bpm)


## Places every drawing where the run says it is, between the last two steps so the view never judders,
## and poses the figures.
func _sync(dt: float) -> void:
	var a := Engine.get_physics_interpolation_fraction() if started and not paused else 1.0
	var s := lerpf(sim.prev_s, sim.s, a)
	var x := lerpf(sim.prev_x, sim.x, a)
	var y := lerpf(sim.prev_y, sim.y, a)
	runner.position = Vector3(x, y, -s)
	runner.visible = sim.invuln <= 0.0 or int(anim_t * 12.0) % 2 == 0
	var flying := sim.is_flying() or sim.carpet_t > 0.0
	anim.runner(runner, {"t": anim_t, "dt": dt, "speed": sim.speed, "x": x, "grounded": sim.grounded or not started,
		"vy": sim.vy, "sliding": sim.is_sliding(), "flying": sim.is_flying(), "stumbling": sim.stumble_t > 0.0,
		"dead": sim.dead, "idle": not started, "escaped": escaped_now})
	escaped_now = false
	fly_carpet.visible = sim.carpet_t > 0.0 or sim.power["fly"] > 0.0
	if fly_carpet.visible:
		fly_carpet.rotation.z = sin(anim_t * 2.0) * 0.05
		fly_carpet.rotation.x = sin(anim_t * 1.6) * 0.04
	bird.visible = sim.power["simurq"] > 0.0 and sim.dead == ""
	if bird.visible: # Cırtdan hangs from its talons
		bird.position = Vector3(x, y + 1.6, -s)
		Animator.simurq(bird, anim_t)
	var gap := sim.div_gap
	if sim.intro_t > 0.0 and sim.div_t <= 0.0:
		gap = maxf(gap, 4.5) # the opening chase: further back and to the side
	if not started:
		gap = 30.0 # behind the menu he is out of sight
	div_fig.position = Vector3(x * 0.6 - (1.9 if sim.intro_t > 0.0 else 0.9), 0, -(s - gap))
	div_fig.visible = gap < tune.div_far_gap - 1.0
	anim.div(div_fig, anim_t, sim.speed, sim.div_t > 0.0, sim.dead == "caught")
	world.update(sim, s, anim_t)
	fx.follow(runner.position, started and sim.grounded and sim.dead == "" and not flying and not sim.is_sliding(), started and flying)
	var tall := get_viewport().get_visible_rect().size.aspect() < 1.0 # a phone held upright: closer, lower
	var follow := 0.85 if tall else 0.55
	var boost_kick := 6.0 if sim.power["fly"] > 0.0 else 0.0
	camera.fov = lerpf(camera.fov, (75.0 if tall else 60.0) + boost_kick + (sim.speed - tune.speed_start) * 0.4, minf(1.0, dt * 3.0))
	shake = maxf(0.0, shake - dt)
	var jolt := Vector3(sin(anim_t * 60.0), cos(anim_t * 47.0), 0) * shake * 0.25
	if not started: # the menu: a slow turn around Cırtdan dancing
		var a2 := sin(anim_t * 0.3) * 0.5
		camera.position = Vector3(x + sin(a2) * 3.5, 1.9, -s - cos(a2) * 3.8) # in front: he faces -z
		camera.look_at(Vector3(x, 1.75, -s)) # he stands low in the picture, under the menu
		return
	camera.position = Vector3(x * follow, (4.3 if tall else 3.7) + y * 0.6, -s + (4.9 if tall else 6.2)) + jolt
	camera.look_at(Vector3(x * (0.75 if tall else 0.3), (0.9 if tall else 1.0) + y * 0.55, -s - (8.0 if tall else 7.0)))


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
				if (not started and menu.screen == "home") or sim.dead != "":
					_start()
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_done = false
		elif not touch_done: # a tap
			touch_done = true
			if not started:
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
		_finish_run()
		_new_run()
	started = true
	paused = false
	pause_panel.visible = false
	menu.visible = false
	recorded = false


## Oyna: the first time, the story comes first.
func _on_play() -> void:
	if not bool(save.get_value("story")):
		_show_story(true)
	else:
		_start()


## Shows the story over everything; then starts a run (then_play) or returns to the menu.
func _show_story(then_play: bool) -> void:
	story = Story.new(prog.cirtdan_look(), then_play)
	story.sfx.connect(snd.play)
	hud_layer.add_child(story)
	story.finished.connect(func() -> void:
		story.queue_free()
		story = null
		save.set_value("story", true)
		if then_play:
			_start())


## Back to the menu: the run so far is banked and recorded, and a fresh street waits behind the menu.
func _to_menu() -> void:
	_bank()
	_finish_run()
	started = false
	paused = false
	pause_panel.visible = false
	_new_run()
	menu.open("home")
	menu.visible = true


## Puts the finished run on the leaderboard, once.
func _finish_run() -> void:
	if recorded:
		return
	recorded = true
	prog.mission("run_dist", sim.s)
	prog.record_run(int(sim.score), int(sim.s), sim.bread)


func _set_paused(on: bool) -> void:
	if not started or sim.dead != "" or menu.visible:
		return
	paused = on
	pause_panel.visible = on
	if on:
		_bank() # leaving the app or the run never loses its bread


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_set_paused(true)
		save.flush()


# --- events from the run ------------------------------------------------------------------------

func _on_dead(_kind: String) -> void:
	_bank()
	prog.mission("run_dist", sim.s)
	save.flush()
	var best := maxi(int(sim.score), int(save.get_value("best")))
	var cost := sim.continue_cost()
	var have := int(save.get_value("nar"))
	var lines := [tr("Hamm! Div səni tutdu!" if sim.dead == "caught" else "Bam! Toqquşdun!"), "",
		tr("Xal: %d" % int(sim.score)), tr("Yağ çörəyi: %d" % sim.bread), tr("Rekord: %d" % best)]
	if int(sim.score) > int(save.get_value("best")):
		lines.insert(1, tr("Yeni rekord!"))
	over_text.text = "\n".join(lines)
	continue_btn.text = "Nar ilə davam et (%d)" % cost if have >= cost else tr("Nar çatmır: %d lazımdır, səndə %d" % [cost, have])
	continue_btn.disabled = have < cost
	over_panel.visible = true


func _on_power(kind: String) -> void:
	snd.play("power")
	if kind != "fly" and kind != "carpet":
		prog.mission("powers", 1)
	if kind == "simurq":
		prog.mission("simurq", 1)
	_banner(POWER_NAMES.get(kind, kind) + "!")


## A letter, a buta stone or a magic stone.
func _on_item(kind: String) -> void:
	match kind:
		"letter":
			snd.play("nar", 1.2)
			var r := prog.take_letter()
			_show_word(r["word"], r["got"])
			if not (r["gifts"] as Array).is_empty():
				_banner("%s! Hədiyyə: %s" % [r["word"], ", ".join(r["gifts"])], 3.0)
		"buta":
			snd.play("bread", 0.8)
			var msg := prog.take_buta()
			var h := prog.hunt()
			_show_count("buta %d/%d" % [mini(h["got"], h["need"]), h["need"]], Color("#7fe0dc"))
			if msg != "":
				_banner(msg, 3.5)
				gen.hunt_open = false
		"stone":
			snd.play("power", 1.3)
			var msg := prog.take_stone()
			_show_count("sehrli daş %d" % prog.get_int("stones"), Color("#d9b8ff"))
			if msg != "":
				_banner(msg, 3.0)


func _show_word(word: String, got: int) -> void:
	for c in word_box.get_children():
		c.queue_free()
	for i in word.length():
		var l := _label(word_box, 34, Color("#4a2a0c") if i < got else Color(1, 0.96, 0.86, 0.5))
		l.text = word[i]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size = Vector2(46, 52)
		l.add_theme_stylebox_override("normal", UiKit.box(Color("#e0b06a") if i < got else Color(0.3, 0.12, 0.05, 0.6), 8, 2))
		l.add_theme_constant_override("outline_size", 0 if i < got else 6)
	word_t = 2.5


func _show_count(t: String, c: Color) -> void:
	count_label.text = t
	count_label.add_theme_color_override("font_color", c)
	count_t = 1.5


func _on_nar() -> void:
	snd.play("nar")
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


func _banner(t: String, secs: float = 1.6) -> void:
	hud_banner.text = t
	banner_t = secs


# --- HUD ----------------------------------------------------------------------------------------

func _label(parent: Control, size: int, color: Color) -> Label:
	return UiKit.label(parent, size, color)


func _button(parent: Control, t: String, color: Color, size: int = 34) -> Button:
	return UiKit.button(parent, t, color, size)


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
	hud_counts = VBoxContainer.new()
	hud_counts.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	hud_counts.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud_counts.position.y += 76
	hud_counts.alignment = BoxContainer.ALIGNMENT_END
	hud_counts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud_counts)
	hud_bread = UiKit.counts(hud_counts, ["bread"], 38, Color("#ffd77a"))[0]
	hud_nar = UiKit.counts(hud_counts, ["nar"], 32, Color("#ffb3bd"))[0]
	for l in [hud_bread, hud_nar]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
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
	hud_banner = _label(root, 44, Color("#ffd77a"))
	hud_banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 0)
	hud_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_banner.position.y = 300
	hud_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_banner.visible = false
	word_box = HBoxContainer.new()
	word_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	word_box.position.y = 560
	word_box.alignment = BoxContainer.ALIGNMENT_CENTER
	word_box.add_theme_constant_override("separation", 4)
	word_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	word_box.visible = false
	root.add_child(word_box)
	count_label = _label(root, 32, Color("#7fe0dc"))
	count_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	count_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	count_label.position.y += 180
	count_label.visible = false
	pause_panel = _panel(root, "Fasilə")
	var go := _button(pause_panel.get_child(1), "Davam", Color("#2b7a48"), 44)
	go.pressed.connect(_set_paused.bind(false))
	var pm := _button(pause_panel.get_child(1), "Menyu", Color(0.27, 0.1, 0.06, 0.9), 38)
	pm.pressed.connect(_to_menu)
	pause_panel.visible = false
	over_panel = _panel(root, "")
	over_text = over_panel.get_child(0)
	var box: VBoxContainer = over_panel.get_child(1)
	continue_btn = _button(box, "Nar ilə davam et", Color("#8e1d22"), 38)
	continue_btn.pressed.connect(_on_continue)
	var again := _button(box, "Yenidən qaç", Color("#2b7a48"), 44)
	again.pressed.connect(_start)
	var om := _button(box, "Menyu", Color(0.27, 0.1, 0.06, 0.9), 38)
	om.pressed.connect(_to_menu)
	over_panel.visible = false
	menu = Menu.new(prog)
	root.add_child(menu)
	menu.play.connect(_on_play)
	menu.look_changed.connect(_apply_look)
	menu.story.connect(_show_story.bind(false))
	menu.sfx.connect(snd.play)
	menu.settings_changed.connect(snd.settings_changed)
	hud_layer = layer


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
	l.add_theme_stylebox_override("normal", UiKit.carpet(30))
	l.offset_left = 40
	l.offset_right = -40
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 260)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.add_theme_constant_override("separation", 24)
	shade.add_child(box)
	return shade


func _update_hud() -> void:
	hud_counts.visible = started
	for l in [hud_score]:
		l.visible = started
	hud_score.text = "%06d" % int(sim.score)
	hud_bread.text = str(sim.bread)
	hud_nar.text = str(int(save.get_value("nar")))
	for k in power_rows:
		var left: float = sim.carpet_t if k == "carpet" else sim.power[k]
		var full: float = tune.carpet_time if k == "carpet" else sim.power_time(k)
		power_rows[k][0].visible = left > 0.0
		power_rows[k][1].value = left / full
	carpet_btn.visible = sim.carpets > 0 and sim.carpet_t <= 0.0 and sim.dead == "" and started and not paused
	carpet_btn.text = "Xalça x%d" % sim.carpets
	boost_btn.visible = sim.boost_open() and started and not paused
	boost_btn.text = "Uçuş! x%d" % sim.boosts
	pause_btn.visible = started and sim.dead == "" and not paused


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


## Prints every shown text that has no translation (developer flag --untranslated).
func _dump_untranslated(n: Node) -> void:
	for c in n.get_children():
		_dump_untranslated(c)
	var s := ""
	if n is Label or n is Button or n is Label3D:
		s = n.text
	if s != "" and n.is_visible_in_tree() if n is CanvasItem else s != "":
		if tr(s) == s and RegEx.create_from_string("[a-zA-ZəıöüşçğƏİÖÜŞÇĞ]{2}").search(s) != null:
			print("UNTR ", s.replace("\n", "\\n"))


func _shoot() -> void:
	if args.has("untranslated"):
		_dump_untranslated(self)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args["shot"])
	print("SHOT %s time=%.1f s=%.0f bread=%d dead=%s save_bread=%d nar=%d" % [args["shot"], sim.time, sim.s, sim.bread,
		sim.dead, int(save.get_value("bread")), int(save.get_value("nar"))])
	get_tree().quit()
