## Cırtdan as a rigged model built in Blender (pilot): assets/models/char_cirtdan.glb, made by
## tools/blender/make_cirtdan.py. Plays the model's clips (run, jump, slide, stumble, idle, fly) from the same
## run state the code Animator reads, and adds the code-side touches: a lean into lane changes, a squash on
## landing and a blink. The procedural Characters.runner() stays the default; game.gd picks this one behind a flag.
##
## Usage:
##   var glb := GlbRunner.new(sqrt(2.0 * tune.gravity * tune.jump_height))
##   var fig := glb.build()              # faces -z, feet at the origin
##   glb.drive({"t": t, "dt": dt, "speed": 12.0, "grounded": true, ...})   # the keys Animator.runner() takes
class_name GlbRunner
extends RefCounted

const PATH := "res://assets/models/char_cirtdan.glb"
const LOOPS := ["run", "idle", "fly", "stumble"]
const BLEND := 0.12 ## seconds to cross-fade between clips
const RUN_FREQ_MAX := 18.0 ## rad/s, the same stride cap as Animator.runner()

var _jump_speed := 9.8 ## m/s up at take-off: maps vertical speed onto the jump clip
var _model: Node3D
var _player: AnimationPlayer
var _skel: Skeleton3D
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


## Builds the figure: the model under a holder node, the shared toon look (vertex colours, ink outline on the
## body, none on the face) and a blob shadow. Returns the holder; place and show it like Characters.runner().
func build() -> Node3D:
	var g := Node3D.new()
	_model = (load(PATH) as PackedScene).instantiate()
	g.add_child(_model)
	var mat := Kit.tint_mat().duplicate() as StandardMaterial3D
	mat.vertex_color_is_srgb = false # glTF vertex colours arrive linear
	for n in _model.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if mi.name == "Body":
			mi.material_overlay = Kit.ink_mat()
	_player = _model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for c in LOOPS:
		_player.get_animation(c).loop_mode = Animation.LOOP_LINEAR
	_skel = _model.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
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
	elif st.get("stumbling", false) or String(st.get("dead", "")) != "":
		clip = "stumble"
	elif flying:
		clip = "fly"
	elif not grounded:
		clip = "jump"
	elif st.get("sliding", false):
		clip = "slide"
	_play(clip)
	var length := _player.get_animation(clip).length
	_player.speed_scale = 1.0
	if clip == "run": # stride matches the code animator: faster running, faster legs
		var freq := minf(RUN_FREQ_MAX, 6.0 + float(st.get("speed", 10.0)) * 0.55)
		_player.speed_scale = freq / (TAU / length)
	elif clip == "jump": # posed by vertical speed: take-off at the start, the apex mid-clip, landing at the end
		var u := clampf(0.5 - float(st.get("vy", 0.0)) / (2.0 * _jump_speed), 0.0, 1.0)
		_player.seek(maxf(0.0, u * length - dt), false)
	_player.advance(dt)
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
	# a blink now and then (on top of whatever the clip did with the eyes)
	_blink_t -= dt
	if _blink_t < -0.12:
		_blink_t = 2.0 + fmod(float(st.get("t", 0.0)) * 7.13, 2.5)
	if _blink_t < 0.0:
		for i in _eyes:
			_skel.set_bone_pose_scale(i, Vector3.ONE - _eye_axis * 0.88)


func _play(clip: String) -> void:
	if clip != _clip:
		_player.play(clip, BLEND)
		_clip = clip
