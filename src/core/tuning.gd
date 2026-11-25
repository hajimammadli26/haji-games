## Every gameplay value of the run, in one resource (res://src/data/tuning.tres).
## The numbers are the web prototype's config.js (prototypes/cirtdan/), which the owner played and kept:
## "Sürət yerində" pins speed_start 10, speed_max 22, speed_ramp 0.08.
class_name Tuning
extends Resource

@export_group("Running")
@export var speed_start: float = 10.0 ## m/s at the start of a run
@export var speed_max: float = 22.0 ## m/s cap
@export var speed_ramp: float = 0.08 ## m/s gained per second of running
@export var lane_width: float = 2.2 ## m between lane centres
@export var lane_change_speed: float = 16.0 ## m/s sideways when switching lanes

@export_group("Jump and slide")
@export var gravity: float = 30.0 ## m/s²
@export var jump_height: float = 1.6 ## m apex: clears baskets (0.85), not cart roofs (1.6)
@export var fast_fall_speed: float = 22.0 ## m/s down when sliding in the air
@export var slide_time: float = 0.65 ## s a slide lasts
@export var input_buffer: float = 0.12 ## s an early jump press before landing still counts
@export var coyote_time: float = 0.08 ## s a late jump off an edge still counts

@export_group("The Div")
@export var div_near_time: float = 6.0 ## s the Div stays close after a stumble; a second stumble in it = caught
@export var div_near_gap: float = 2.4 ## m behind Cırtdan when close
@export var div_far_gap: float = 16.0 ## m behind when far (off screen)
@export var div_intro_time: float = 3.0 ## s the Div chases on screen at the start of a run

@export_group("The street")
@export var safe_start: float = 8.0 ## s with no obstacle at the start
@export var row_gap_start: float = 1.6 ## s between obstacle rows at the start
@export var row_gap_end: float = 0.85 ## s between rows at full difficulty
@export var ramp_time: float = 150.0 ## s from easy to full difficulty
@export var double_block_after: float = 45.0 ## s before two lanes are blocked at once
@export var caravan_after: float = 38.0 ## s before the first camel caravan
@export var caravan_speed: float = 6.0 ## m/s a caravan walks toward you
@export var caravan_ramp_chance: float = 0.7 ## a hay cart beside a caravan, to jump across onto the camels
@export var view_ahead: float = 150.0 ## m of street built ahead

@export_group("Pickups and score")
@export var bread_line: int = 6 ## yağ çörəyi in a line
@export var mult_every: float = 500.0 ## m per +1 multiplier
@export var mult_cap: int = 10
