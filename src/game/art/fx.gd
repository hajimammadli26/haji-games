## Small effects that make the run feel alive: dust kicked up behind Cırtdan's feet, a puff on landing,
## golden sparks when bread is picked up (and coloured ones for nar, power-ups, letters), a sparkle trail
## while he flies. CPU particles (they work on every phone), pooled so a run never allocates new ones.
##
## Usage:
##   var fx := Fx.new(); add_child(fx)
##   fx.follow(runner_pos, grounded and running)   # every frame
##   fx.burst(pos, Color.GOLD)                        # a pickup
class_name Fx
extends Node3D

const POOL := 10

var _dust: CPUParticles3D
var _trail: CPUParticles3D
var _bursts: Array[CPUParticles3D] = []
var _next := 0


func _ready() -> void:
	_dust = _particles(24, 0.5, Color(0.85, 0.72, 0.52, 0.7), 0.12, false)
	_dust.direction = Vector3(0, 1, 1)
	_dust.spread = 30.0
	_dust.initial_velocity_min = 1.0
	_dust.initial_velocity_max = 2.0
	_dust.gravity = Vector3(0, -1.0, 0)
	_trail = _particles(40, 0.8, Color(1.0, 0.9, 0.5, 1.0), 0.08, false)
	_trail.direction = Vector3(0, 0, 1)
	_trail.spread = 40.0
	_trail.initial_velocity_min = 1.0
	_trail.initial_velocity_max = 3.0
	_trail.gravity = Vector3(0, -0.5, 0)
	for i in POOL:
		var b := _particles(14, 0.45, Color.GOLD, 0.09, true)
		b.direction = Vector3(0, 1, 0)
		b.spread = 180.0
		b.initial_velocity_min = 2.0
		b.initial_velocity_max = 4.0
		b.gravity = Vector3(0, -6.0, 0)
		_bursts.append(b)


func _particles(n: int, life: float, color: Color, size: float, one_shot: bool) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = n
	p.lifetime = life
	p.one_shot = one_shot
	p.explosiveness = 0.9 if one_shot else 0.0
	p.emitting = false
	p.local_coords = false
	var m := SphereMesh.new()
	m.radius = size
	m.height = size * 2.0
	m.radial_segments = 6
	m.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color.WHITE
	m.material = mat
	p.mesh = m
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0.0))
	p.color_ramp = ramp
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0.3))
	p.scale_amount_curve = curve
	add_child(p)
	return p


## Keeps the dust at Cırtdan's feet (kicked up while he runs on the ground) and the trail while he flies.
func follow(at: Vector3, running: bool, flying: bool) -> void:
	_dust.position = at + Vector3(0, 0.05, 0.2)
	_dust.emitting = running
	_trail.position = at + Vector3(0, 0.3, 0.4)
	_trail.emitting = flying


## A burst of sparks at pos in a colour (a pickup, a landing puff).
func burst(pos: Vector3, color: Color, amount := 14) -> void:
	var b := _bursts[_next]
	_next = (_next + 1) % POOL
	b.position = pos
	b.amount = amount
	b.color_ramp.set_color(0, color)
	b.color_ramp.set_color(1, Color(color, 0.0))
	b.restart()
	b.emitting = true
