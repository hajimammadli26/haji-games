## Brings the figures to life every frame from the run's state, with no keyframes: Cırtdan's run cycle
## (arms and legs, a bouncing sack, a bobbing head), the jump's tuck and the fall's reach, the slide, a squash
## on landing, a lean into lane changes, a flail when he stumbles, flight poses; the Div's lumbering chase
## with his club up; Cırtdan's idle dance behind the menu. Smooths between poses so nothing snaps.
##
## Usage:
##   var anim := Animator.new()
##   anim.runner(runner_node, {"t": t, "dt": dt, "speed": 12.0, "grounded": true, ...})
##   anim.div(div_node, t, speed, near)
class_name Animator
extends RefCounted

var _lean := 0.0
var _squash := 0.0
var _was_grounded := true
var _slide := 0.0
var _air := 0.0
var _prev_x := 0.0
var _tongue_t := 0.0


## Poses a runner (Characters.runner) from st: t, dt, speed, x, grounded, vy, sliding, flying, stumbling,
## dead ("", "crash", "caught"), idle (menu), escaped (just got away: sticks out his tongue).
func runner(fig: Node3D, st: Dictionary) -> void:
	var p: Dictionary = fig.get_meta("parts")
	var t: float = st.get("t", 0.0)
	var dt: float = maxf(0.0001, st.get("dt", 0.016))
	var k := minf(1.0, dt * 12.0)
	var grounded: bool = st.get("grounded", true)
	var flying: bool = st.get("flying", false)
	var dead: String = st.get("dead", "")
	var x: float = st.get("x", 0.0)
	# lean into lane changes
	var vx := (x - _prev_x) / dt
	_prev_x = x
	_lean = lerpf(_lean, clampf(-vx * 0.035, -0.35, 0.35), k)
	# squash on landing
	if grounded and not _was_grounded and not flying:
		_squash = 1.0
	_was_grounded = grounded
	_squash = maxf(0.0, _squash - dt * 5.0)
	_slide = lerpf(_slide, 1.0 if st.get("sliding", false) and grounded else 0.0, minf(1.0, dt * 18.0))
	_air = lerpf(_air, 0.0 if grounded or flying else 1.0, minf(1.0, dt * 14.0))
	if st.get("escaped", false):
		_tongue_t = 1.2
	_tongue_t = maxf(0.0, _tongue_t - dt)
	var rig: Node3D = p["rig"]
	var torso: Node3D = p["torso"]
	var head: Node3D = p["head"]
	var hip: Node3D = p["hip"]
	var idle: bool = st.get("idle", false)
	var speed: float = st.get("speed", 10.0)
	var freq := 2.2 if idle else minf(18.0, 6.0 + speed * 0.55)
	var ph := t * freq
	var run := sin(ph)
	var bounce := absf(cos(ph))
	# base: the run cycle
	var leg_l := run * 0.95
	var leg_r := -run * 0.95
	var arm_l := -run * 1.0
	var arm_r := run * 1.0
	var body_y := bounce * 0.07
	var torso_x := -0.18 # leaning forward into the run
	var head_x := 0.1 + sin(ph * 2.0) * 0.05
	if idle: # behind the menu: a little dance, arms waving
		leg_l = maxf(0.0, run) * 0.6
		leg_r = maxf(0.0, -run) * 0.6
		arm_l = -2.4 + sin(t * 4.4) * 0.4
		arm_r = -2.4 - sin(t * 4.4) * 0.4
		body_y = bounce * 0.1
		torso_x = 0.0
		head_x = sin(t * 2.2) * 0.12
		torso.rotation.z = sin(t * 2.2) * 0.12
	else:
		torso.rotation.z = _lean * 0.6
	# the jump: knees tucked going up, legs reaching down coming down
	var vy: float = st.get("vy", 0.0)
	var up := clampf(vy / 6.0, -1.0, 1.0)
	leg_l = lerpf(leg_l, -1.2 if up > 0.0 else -0.4, _air)
	leg_r = lerpf(leg_r, -0.5 if up > 0.0 else 0.3, _air)
	arm_l = lerpf(arm_l, -2.7, _air)
	arm_r = lerpf(arm_r, -2.2 + up * 0.4, _air)
	torso_x = lerpf(torso_x, -0.3 * up, _air)
	# the slide: lean back, legs forward
	leg_l = lerpf(leg_l, -1.5, _slide)
	leg_r = lerpf(leg_r, -1.3, _slide)
	arm_l = lerpf(arm_l, -0.9, _slide)
	arm_r = lerpf(arm_r, -0.9, _slide)
	torso_x = lerpf(torso_x, 1.0, _slide)
	body_y = lerpf(body_y, -0.25, _slide)
	if flying: # on the carpet or under the Simurq: arms out, legs dangling, a happy sway
		leg_l = 0.25 + sin(t * 3.0) * 0.15
		leg_r = -0.1 + sin(t * 3.0 + 1.0) * 0.15
		arm_l = -2.9
		arm_r = -2.9
		torso_x = 0.05
		body_y = sin(t * 2.5) * 0.04
	if st.get("stumbling", false): # arms flailing
		arm_l = -2.0 + sin(t * 30.0) * 0.8
		arm_r = -2.0 - sin(t * 30.0) * 0.8
		head_x = -0.3
	p["leg_l"].rotation.x = leg_l
	p["leg_r"].rotation.x = leg_r
	p["arm_l"].rotation.x = arm_l
	p["arm_r"].rotation.x = arm_r
	p["arm_l"].rotation.z = -0.15 - _air * 0.3
	p["arm_r"].rotation.z = 0.15 + _air * 0.3
	torso.rotation.x = torso_x
	hip.rotation.x = torso_x * 0.3
	head.rotation.x = head_x
	head.rotation.y = 0.0 if idle else -_lean * 0.5
	rig.position.y = body_y
	var sq := sin(_squash * PI) * 0.25
	rig.scale = Vector3(1.0 + sq * 0.6, 1.0 - sq, 1.0 + sq * 0.6)
	rig.rotation.z = _lean * 0.4
	# secondary motion: the sack swings behind, the hat lags
	(p["sack"] as Node3D).rotation.x = -bounce * 0.25 - _air * 0.4 * up
	(p["hat"] as Node3D).rotation.x = -bounce * 0.06 + _air * 0.12 * up
	var brow := 0.2 if st.get("stumbling", false) else 0.0
	(p["brow_l"] as Node3D).position.y = 0.32 + brow * 0.1
	(p["brow_r"] as Node3D).position.y = 0.32 + brow * 0.1
	(p["tongue"] as Node3D).visible = _tongue_t > 0.0
	if dead == "crash":
		fig.rotation.x = minf(1.4, fig.rotation.x + dt * 5.0)
	elif dead == "caught":
		fig.rotation.x = 0.0
		rig.position.y = 0.3 + sin(t * 20.0) * 0.05 # lifted up, wriggling
		p["leg_l"].rotation.x = sin(t * 20.0) * 0.8
		p["leg_r"].rotation.x = -sin(t * 20.0) * 0.8
	else:
		fig.rotation.x = 0.0
	for c in torso.get_children(): # Pəri's wings flutter
		if c.has_meta("wing"):
			c.rotation.y = float(c.get_meta("wing")) * (0.4 + sin(t * 14.0) * 0.35)


## Poses the Div chasing: a heavy stride, belly bounce, the club raised when he is close (near), a roar.
func div(fig: Node3D, t: float, speed: float, near: bool, caught: bool) -> void:
	var p: Dictionary = fig.get_meta("parts")
	var ph := t * (4.0 + speed * 0.3)
	var run := sin(ph)
	p["leg_l"].rotation.x = run * 0.7
	p["leg_r"].rotation.x = -run * 0.7
	p["rig"].position.y = absf(run) * 0.14
	p["body"].rotation.x = 0.15 + absf(run) * 0.05
	p["body"].rotation.z = run * 0.06
	p["arm_l"].rotation.x = -run * 0.8 - 0.3
	if caught: # Hamm! both arms up, mouth wide
		p["arm_l"].rotation.x = -2.6
		p["arm_r"].rotation.x = -2.6
		(p["mouth"] as Node3D).scale.y = 2.2
	elif near: # the club up, swinging
		p["arm_r"].rotation.x = -2.4 + sin(t * 8.0) * 0.5
		(p["mouth"] as Node3D).scale.y = 1.6 + sin(t * 10.0) * 0.4
	else:
		p["arm_r"].rotation.x = run * 0.5 - 1.2
		(p["mouth"] as Node3D).scale.y = 1.0
	p["head"].rotation.y = sin(t * 1.3) * 0.15
	var angry := 0.15 if near else 0.0
	(p["brow_l"] as Node3D).rotation.z = -0.3 - angry
	(p["brow_r"] as Node3D).rotation.z = 0.3 + angry


## Flaps the Simurq's wings and waves its tail.
static func simurq(fig: Node3D, t: float) -> void:
	var p: Dictionary = fig.get_meta("parts")
	var flap := sin(t * 9.0) * 0.5
	p["wings"][0].rotation.z = flap
	p["wings"][1].rotation.z = -flap
	(p["tail"] as Node3D).rotation.x = sin(t * 3.0) * 0.08
