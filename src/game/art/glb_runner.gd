## Cırtdan as a rigged, textured model: assets/models/char_cirtdan.glb (made in Tripo3D, prepared for the game by
## tools/blender/prep_cirtdan.py; the older Blender-built pilot is assets/models/char_cirtdan_blender.glb). Plays
## the model's clips (run, jump, slide, stumble, fall, idle, fly) from the same run state the code Animator reads,
## and adds the code-side touches: a lean into lane changes, a squash on landing and, on a rig with eye bones named
## eye.L / eye.R, a blink. The procedural Characters.runner() stays the default; game.gd picks this one behind a flag.
##
## Usage:
##   var glb := GlbRunner.new(sqrt(2.0 * tune.gravity * tune.jump_height))
##   var fig := glb.build()              # faces -z, feet at the origin
##   glb.drive({"t": t, "dt": dt, "speed": 12.0, "grounded": true, ...})   # the keys Animator.runner() takes
class_name GlbRunner
extends RefCounted

const PATH := "res://assets/models/char_cirtdan.glb"
const LOOPS := ["run", "idle", "fly", "stumble"]
const FALLBACK := {"fall": "stumble", "stumble": "run", "fly": "idle", "slide": "run", "jump": "run", "idle": "run"} ## a clip the model lacks plays this one
const BLEND := 0.12 ## seconds to cross-fade between clips
const RUN_FREQ_MAX := 18.0 ## rad/s, the same stride cap as Animator.runner()

var _jump_speed := 9.8 ## m/s up at take-off: maps vertical speed onto the jump clip
var _model: Node3D
var _player: AnimationPlayer
var _skel: Skeleton3D
var _root := -1 ## the skeleton's root bone (hips): pinned over the origin so no clip drifts him off his spot
var _root_rest := Vector3.ZERO
var _clip := ""
var _eyes: Array[int] = []
var _eye_axis := Vector3.FORWARD ## the eye bones' local axis that points up (squashed to blink)
var _lean := 0.0
var _prev_x := 0.0
var _squash := 0.0
var _was_grounded := true
var _blink_t := 2.0


## jump_speed: the take-off speed of a normal jump (m/s); the jump clip runs from it to minus it.
func _init(jump_speed := 9.8) -> void:
	_jump_speed = maxf(1.0, jump_speed)


## True when the model file is in the project (imported).
static func available() -> bool:
	return ResourceLoader.exists(PATH)


## Builds the figure: the model under a holder node, the shared toon look (the model's painted texture on Kit's
## toon shading, an ink outline) and a blob shadow. Returns the holder; place and show it like Characters.runner().
func build() -> Node3D:
	var g := Node3D.new()
	_model = (load(PATH) as PackedScene).instantiate()
	g.add_child(_model)
	for n in _model.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		mi.material_override = _toon_of(mi)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if mi.mesh != null and (mi.mesh.get_aabb().size * _scale_to_model(mi)).length() >= 0.25:
			mi.material_overlay = _ink_for(mi) # small parts (a separate face) stay unoutlined, as in Kit.ink()
	_player = _model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for c in LOOPS:
		if _player.has_animation(c):
			_player.get_animation(c).loop_mode = Animation.LOOP_LINEAR
	_skel = _model.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	for i in _skel.get_bone_count():
		if _skel.get_bone_parent(i) < 0:
			_root = i
			_root_rest = _skel.get_bone_rest(i).origin
			break
	for b in ["eye.L", "eye.R"]:
		var i := _skel.find_bone(b)
		if i >= 0:
			_eyes.append(i)
			var up := _skel.get_bone_global_rest(i).basis.inverse() * Vector3.UP
			_eye_axis = up.abs()
	Kit.shadow(g, 0.34)
	_play("idle")
	_player.advance(0.0)
	return g


## Poses the figure for this frame from st (the keys Animator.runner() takes: t, dt, speed, x, grounded, vy,
## sliding, flying, stumbling, dead, idle). Picks the clip, times it, and blends between clips.
func drive(st: Dictionary) -> void:
	var dt: float = maxf(0.0001, st.get("dt", 0.016))
	var grounded: bool = st.get("grounded", true)
	var flying: bool = st.get("flying", false)
	var clip := "run"
	if st.get("idle", false):
		clip = "idle"
	elif String(st.get("dead", "")) != "":
		clip = "fall" # plays once and holds: he stays down
	elif st.get("stumbling", false):
		clip = "stumble"
	elif flying:
		clip = "fly"
	elif not grounded:
		clip = "jump"
	elif st.get("sliding", false):
		clip = "slide"
	clip = _play(clip)
	var length := _player.get_animation(clip).length
	_player.speed_scale = 1.0
	if clip == "run": # stride matches the code animator: faster running, faster legs
		var freq := minf(RUN_FREQ_MAX, 6.0 + float(st.get("speed", 10.0)) * 0.55)
		_player.speed_scale = freq / (TAU / length)
	elif clip == "jump": # posed by vertical speed: take-off at the start, the apex mid-clip, landing at the end
		var u := clampf(0.5 - float(st.get("vy", 0.0)) / (2.0 * _jump_speed), 0.0, 1.0)
		_player.seek(maxf(0.0, u * length - dt), false)
	_player.advance(dt)
	if _root >= 0: # keep the hips over the origin (the height and the clip's sway stay)
		var p := _skel.get_bone_pose_position(_root)
		_skel.set_bone_pose_position(_root, Vector3(_root_rest.x, p.y, _root_rest.z))
	# a lean into lane changes and a squash on landing, on the model under the holder
	var x: float = st.get("x", 0.0)
	var k := minf(1.0, dt * 12.0)
	_lean = lerpf(_lean, clampf(-(x - _prev_x) / dt * 0.035, -0.35, 0.35), k)
	_prev_x = x
	if grounded and not _was_grounded and not flying:
		_squash = 1.0
	_was_grounded = grounded
	_squash = maxf(0.0, _squash - dt * 5.0)
	_model.rotation.z = 0.0 if clip == "idle" else _lean * 0.6
	_model.scale = Vector3(1.0 + _squash * 0.12, 1.0 - _squash * 0.18, 1.0 + _squash * 0.12)
	# a blink now and then (on top of whatever the clip did with the eyes), on rigs with eye bones
	if _eyes.is_empty():
		return
	_blink_t -= dt
	if _blink_t < -0.12:
		_blink_t = 2.0 + fmod(float(st.get("t", 0.0)) * 7.13, 2.5)
	if _blink_t < 0.0:
		for i in _eyes:
			_skel.set_bone_pose_scale(i, Vector3.ONE - _eye_axis * 0.88)


## Plays clip (or its stand-in when the model lacks it, see FALLBACK); returns the clip that plays.
func _play(clip: String) -> String:
	while not _player.has_animation(clip) and FALLBACK.has(clip):
		clip = FALLBACK[clip]
	if clip != _clip:
		_player.play(clip, BLEND)
		_clip = clip
	return clip


## Kit's toon material carrying the mesh's own painted texture (the glTF material's albedo), or Kit's plain
## vertex-colour toon material when the mesh has no texture (the Blender pilot).
func _toon_of(mi: MeshInstance3D) -> StandardMaterial3D:
	var src := mi.get_active_material(0) as BaseMaterial3D
	if src == null or src.albedo_texture == null:
		var tint := Kit.tint_mat().duplicate() as StandardMaterial3D
		tint.vertex_color_is_srgb = false # glTF vertex colours arrive linear
		return tint
	var m := Kit.mat(Color.WHITE).duplicate() as StandardMaterial3D
	m.albedo_texture = src.albedo_texture
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return m


## Kit's ink shell, thinned by the scale between the mesh and the model root (the rig carries its own scale, and
## the shell grows in the mesh's units), so the outline is as thick as on every other figure.
func _ink_for(mi: MeshInstance3D) -> StandardMaterial3D:
	var s := _scale_to_model(mi)
	if is_equal_approx(s, 1.0):
		return Kit.ink_mat()
	var ink := Kit.ink_mat().duplicate() as StandardMaterial3D
	ink.grow_amount = Kit.INK_GROW / s
	return ink


func _scale_to_model(n: Node) -> float:
	var s := 1.0
	while n != null and n != _model:
		if n is Node3D:
			s *= (n as Node3D).scale.x
		n = n.get_parent()
	return s
