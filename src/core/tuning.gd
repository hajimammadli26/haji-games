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
@export var jump_height: float = 1.6 ## m apex: clears baskets (0.85); a well-timed jump also lands on a cart roof (1.6)
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
@export var caravan_speed: float = 6.0 ## m/s a caravan walks toward you (it stops once Cırtdan climbs on)
@export var after_caravan_gap: float = 1.6 ## s after a caravan passes when rows block at most one lane
@export var caravan_ramp_chance: float = 0.7 ## a hay cart beside a caravan, to jump across onto the camels
@export var view_ahead: float = 150.0 ## m of street built ahead

@export_group("Pickups and score")
@export var bread_line: int = 6 ## yağ çörəyi in a line
@export var nar_chance: float = 0.04 ## chance per row of a nar
@export var power_chance: float = 0.1 ## chance per row of a power-up
@export var simurq_share: float = 0.3 ## share of power-ups that are a Simurq feather
@export var simurq_first_row: int = 14 ## the row by which every run has met one Simurq feather
@export var start_nar: int = 2 ## nar a new player is given by Nənə
@export var continue_cost: int = 1 ## nar for the first continue in a run; doubles each time

@export_group("Power-ups")
@export var power_time: float = 10.0 ## s a power-up lasts at shop level 0
@export var upgrade_step: float = 2.5 ## s added per shop level
@export var simurq_time: float = 8.0 ## s the Simurq carries Cırtdan over the street
@export var simurq_height: float = 4.8 ## m he flies at: above every obstacle, under the city gate's arch
@export var super_jump_height: float = 3.6 ## m apex with the magic çarıq
@export var pole_height: float = 4.2 ## m apex of a jump with the kəndirbaz pole (it also springs off obstacle tops)
@export var magnet_radius: float = 6.0 ## m grandma's tray pulls bread from
@export var carpet_time: float = 30.0 ## s the flying carpet shields one hit
@export var carpets_per_run: int = 1 ## flying carpets free at the start of each run
@export var boost_time: float = 7.0 ## s the bought start boost carries Cırtdan through the air
@export var boost_window: float = 6.0 ## s at a run's start when the boost button shows

@export_group("Score")
@export var mult_every: float = 500.0 ## m per +1 multiplier
@export var mult_cap: int = 10

@export_group("Prices and rewards (bread)")
@export var max_level: int = 5 ## shop levels per power-up
@export var upgrade_cost: int = 500 ## bread for level 1; each next level doubles
@export var carpet_cost: int = 400 ## one flying carpet to keep
@export var boost_cost: int = 600 ## one 'Xalça ilə uçuş' start boost
@export var box_cost: int = 800 ## Nənənin bağlaması, a random gift
@export var costume_cost: int = 1500 ## each of Cırtdan's costumes
@export var confirm_from: int = 1 ## purchases at or above this price ask twice (all of them, for children)
@export var mission_reward: int = 150 ## bread for claiming a finished mission (grows with each new one)
@export var mission_scale: float = 0.5 ## how much harder each new mission gets
@export var mission_mult_cap: int = 10 ## the most missions can raise the base multiplier to
@export var kecel_claims: int = 9 ## missions claimed that unlock Keçəl for free
@export var league_silver: int = 5000
@export var league_gold: int = 15000
@export var league_div: int = 40000

@export_group("City treats")
@export var treat_share: float = 0.25 ## share of bread lines made of the city's own treat (halva, fındıq ...)
@export var treat_worth: int = 3 ## bread one treat is worth
@export var halva_worth: int = 5 ## bread a piece of Şəki halvası is worth

@export_group("Hunts and gifts")
@export var letter_chance: float = 0.16 ## chance per row of the next letter of the day's word
@export var hunt_target: int = 40 ## buta stones to find in a week's hunt
@export var hunt_chance: float = 0.12 ## chance per row of a buta stone while the week's hunt is open
@export var hunt_bread: int = 1000 ## bread for a finished hunt once Məlikməmməd is already open
@export var stone_chance: float = 0.03 ## chance per row of a magic stone (sehrli daş)
@export var peri_stones: int = 25 ## magic stones that open Pəri qız for free
@export var word_streak_cap: int = 3 ## the most gifts a streak of days gives for the day's first word

@export_group("Sound")
@export var music_bpm: float = 132.0 ## the run music's eighth-note pulse at the start speed (as made by the audio tool)
@export var music_bpm_gain: float = 2.5 ## bpm added per m/s of extra speed (the run music plays faster)
