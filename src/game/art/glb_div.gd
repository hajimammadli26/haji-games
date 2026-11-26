## The Div as the owner's Tripo3D model (pilot): assets/models/char_div.glb, prepared by tools/blender/prep_div.py
## from assets/incoming/char_div_tripo.glb (8k triangles, one 512 px texture, clips run, idle, catch). Plays the
## clips from the same inputs Animator.div() reads. The procedural Characters.div() stays the default (and the
## story pictures keep it); game.gd picks this one behind a flag.
##
## Usage:
##   var gd := GlbDiv.new()
##   var fig := gd.build()                        # faces +z like Characters.div(), feet at the origin, ~3.75 m
##   gd.drive(t, speed, near, caught)             # the arguments Animator.div() takes
class_name GlbDiv
extends RefCounted

const PATH := "res://assets/models/char_div.glb"
const LOOPS := ["run", "idle"]
const BLEND := 0.15 ## seconds to cross-fade between clips
const NEAR_HURRY := 1.15 ## the run plays this much faster while the Div is right behind Cırtdan

var _player: AnimationPlayer
var _clip := ""
var _last_t := -1.0


## True when the model file is in the project (imported).
static func available() -> bool:
	return ResourceLoader.exists(PATH)


## Builds the figure: the model under a holder node, its own texture with the shared toon shading (Kit's toon
## diffuse, specular and rim) and the ink outline. No blob shadow, like Characters.div(). Returns the holder;
## place, scale and turn it like Characters.div().
func build() -> Node3D:
	var g := Node3D.new()
	var model := (load(PATH) as PackedScene).instantiate() as Node3D
	g.add_child(model)
	for n in model.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var src := mi.get_active_material(0) as StandardMaterial3D
		if src != null:
			var m := src.duplicate() as StandardMaterial3D
			m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
			m.specular_mode = BaseMaterial3D.SPECULAR_TOON
			m.rim_enabled = true
			m.rim = 0.35
			m.rim_tint = 0.6
			m.metallic = 0.0
			m.roughness = 0.85
			mi.material_override = m
		mi.material_overlay = Kit.ink_mat()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_player = model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for c in LOOPS:
		_player.get_animation(c).loop_mode = Animation.LOOP_LINEAR
	_player.get_animation("catch").loop_mode = Animation.LOOP_NONE # lunges once, then holds the grab
	_play("idle")
	_player.advance(0.0)
	return g


## Poses the figure for time t (seconds, the game's animation clock): catch when he has caught Cırtdan, idle
## when the run is not moving, else run with the stride timed like Animator.div() (4 + speed * 0.3 rad/s per
## leg cycle) and a little faster while near.
func drive(t: float, speed: float, near: bool, caught: bool) -> void:
	var dt := clampf(t - _last_t, 0.0, 0.1) if _last_t >= 0.0 else 0.0
	_last_t = t
	var clip := "catch" if caught else ("idle" if speed < 0.5 else "run")
	_play(clip)
	_player.speed_scale = 1.0
	if clip == "run":
		var length := _player.get_animation(clip).length
		var cycles := (4.0 + speed * 0.3) / TAU * (NEAR_HURRY if near else 1.0)
		_player.speed_scale = cycles * length
	_player.advance(dt)


func _play(clip: String) -> void:
	if clip != _clip:
		_player.play(clip, BLEND)
		_clip = clip
