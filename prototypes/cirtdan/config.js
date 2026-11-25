// PROTOTYPE - NOT FOR PRODUCTION
// Question: Does dodging through old-Baku streets with the Div closing in feel fun and readable at speed, on a phone and on keys?
// Date: 2026-11-24
// Every tuning value lives here, each with value, min, max and step. The game reads them live
// through tune.<name> (index.html); the tweak panel, an add-on, writes them back here.
window.CONFIG = {
  seed: 1, // every gameplay random call reads rng(), seeded from this (or ?seed= in the address)
  volume: { value: 0.5, min: 0, max: 1, step: 0.05 },
  music_volume: { value: 0.35, min: 0, max: 1, step: 0.05 },  // the music under the sound effects
  music_bpm: { value: 132, min: 80, max: 200, step: 2 },      // eighth-note pulse of the 6/8 run music at the start
  music_bpm_gain: { value: 2.5, min: 0, max: 6, step: 0.5 },  // bpm added per m/s of extra speed

  // --- Running ---------------------------------------------------------------------------
  speed_start: { value: 10, min: 5, max: 20, step: 0.5 },     // m/s at the start of a run
  speed_max: { value: 22, min: 12, max: 40, step: 0.5 },      // m/s cap
  speed_ramp: { value: 0.08, min: 0, max: 0.5, step: 0.01 },  // m/s gained per second of running (cap at ~150 s)
  lane_width: { value: 2.2, min: 1.5, max: 3.5, step: 0.1 },  // m between lane centres
  lane_change_speed: { value: 16, min: 6, max: 40, step: 1 }, // m/s sideways when switching lanes

  // --- Jump and slide --------------------------------------------------------------------
  gravity: { value: 30, min: 10, max: 60, step: 1 },          // m/s²
  jump_height: { value: 1.6, min: 0.8, max: 3, step: 0.05 },  // m apex: clears baskets (0.8), not cart roofs (1.7)
  super_jump_height: { value: 3.6, min: 2, max: 6, step: 0.1 }, // m apex with the magic çarıq
  fast_fall_speed: { value: 22, min: 5, max: 50, step: 1 },   // m/s down when sliding in the air
  slide_time: { value: 0.65, min: 0.3, max: 1.5, step: 0.05 },// s a slide lasts
  input_buffer: { value: 0.12, min: 0, max: 0.4, step: 0.01 },// s an early jump press before landing still counts
  coyote_time: { value: 0.08, min: 0, max: 0.3, step: 0.01 }, // s a late jump off an edge still counts

  // --- The Div ---------------------------------------------------------------------------
  div_near_time: { value: 6, min: 2, max: 15, step: 0.5 },    // s the Div stays close after a stumble; a second stumble in it = caught
  div_near_gap: { value: 2.4, min: 1, max: 6, step: 0.1 },    // m behind Cırtdan when close
  div_far_gap: { value: 16, min: 8, max: 30, step: 1 },       // m behind when far (off screen)
  div_intro_time: { value: 3, min: 0, max: 8, step: 0.5 },    // s the Div chases on screen at the start of a run

  // --- The street ------------------------------------------------------------------------
  safe_start: { value: 8, min: 2, max: 20, step: 1 },         // s with no obstacle at the start
  row_gap_start: { value: 1.6, min: 0.6, max: 3, step: 0.05 },// s between obstacle rows at the start
  row_gap_end: { value: 0.85, min: 0.4, max: 2, step: 0.05 }, // s between rows at full difficulty
  ramp_time: { value: 150, min: 30, max: 400, step: 10 },     // s from easy to full difficulty
  double_block_after: { value: 45, min: 0, max: 200, step: 5 },// s before two lanes are blocked at once
  caravan_after: { value: 38, min: 0, max: 200, step: 2 },    // s before the first camel caravan
  caravan_ramp_chance: { value: 0.7, min: 0, max: 1, step: 0.05 }, // a hay cart beside a caravan, to jump across onto the camels
  caravan_speed: { value: 6, min: 0, max: 15, step: 0.5 },    // m/s a caravan walks toward you
  view_ahead: { value: 150, min: 60, max: 300, step: 10 },    // m of street built ahead

  // --- Pickups and power-ups -------------------------------------------------------------
  bread_line: { value: 6, min: 2, max: 12, step: 1 },         // yağ çörəyi in a line
  nar_chance: { value: 0.04, min: 0, max: 0.3, step: 0.01 },  // chance per row of a nar
  power_chance: { value: 0.1, min: 0, max: 0.4, step: 0.01 },// chance per row of a power-up
  power_time: { value: 10, min: 3, max: 30, step: 1 },        // s a power-up lasts (level 1 of 5 in Nənənin dükanı, later)
  simurq_time: { value: 8, min: 3, max: 20, step: 0.5 },     // s the Simurq carries Cırtdan over the street
  simurq_height: { value: 7, min: 4, max: 12, step: 0.5 },    // m he flies at, above every obstacle
  simurq_share: { value: 0.3, min: 0, max: 1, step: 0.01 },   // share of power-ups that are a Simurq
  simurq_first_row: { value: 14, min: 6, max: 60, step: 1 }, // the row by which every run has met one Simurq feather
  pole_height: { value: 4.2, min: 2, max: 8, step: 0.1 },     // m apex of each kəndirbaz hop
  magnet_radius: { value: 6, min: 2, max: 15, step: 0.5 },    // m grandma's tray pulls bread from
  carpet_time: { value: 30, min: 5, max: 60, step: 1 },       // s the flying carpet shields one hit
  carpets_per_run: { value: 1, min: 0, max: 5, step: 1 },     // flying carpets at the start of each run (shop later)
  start_nar: { value: 2, min: 0, max: 10, step: 1 },          // nar a new player is given by Nənə

  // --- Nənənin dükanı, characters, missions ----------------------------------------------
  upgrade_step: { value: 2.5, min: 0.5, max: 6, step: 0.5 },  // s added to a power-up per shop level (levels 0-4)
  upgrade_cost: { value: 500, min: 100, max: 3000, step: 50 },// bread for level 1; each next level doubles
  carpet_cost: { value: 400, min: 50, max: 3000, step: 50 },  // bread for one flying carpet to keep
  box_cost: { value: 800, min: 100, max: 5000, step: 50 },    // bread for Nənənin bağlaması (a random gift)
  tiqtiq_cost: { value: 5000, min: 0, max: 50000, step: 500 },// bread to unlock Tıq-Tıq xanım (GDD: 5 000)
  kendirbaz_cost: { value: 10000, min: 0, max: 50000, step: 500 }, // bread to unlock Kəndirbaz (GDD: 10 000)
  kecel_sets: { value: 3, min: 1, max: 20, step: 1 },         // mission sets finished to unlock Keçəl
  mission_scale: { value: 0.5, min: 0, max: 2, step: 0.1 },   // how much harder each new set of missions gets

  // --- Daily word and festivals -----------------------------------------------------------
  letter_chance: { value: 0.16, min: 0, max: 1, step: 0.01 }, // chance per row of the next letter of the day's word
  kosa_tokens: { value: 60, min: 1, max: 500, step: 1 },      // şəkərbura and paxlava collected in Novruz to unlock Kosa
  token_lines: { value: 0.3, min: 0, max: 1, step: 0.05 },    // share of bread lines that are Novruz sweets instead
  bonfire_share: { value: 0.5, min: 0, max: 1, step: 0.05 },  // share of jump obstacles that are bonfires in Novruz
  snow_count: { value: 600, min: 0, max: 3000, step: 50 },    // snowflakes around the camera in winter

  halva_share: { value: 0.25, min: 0, max: 1, step: 0.05 },  // share of bread lines that are Şəki halvası in Şəki
  halva_worth: { value: 5, min: 1, max: 20, step: 1 },        // bread a piece of Şəki halvası is worth

  nut_share: { value: 0.25, min: 0, max: 1, step: 0.05 },    // share of bread lines that are fındıq (hazelnuts) in Qəbələ
  nut_worth: { value: 3, min: 1, max: 20, step: 1 },          // bread a handful of fındıq is worth

  treat_share: { value: 0.25, min: 0, max: 1, step: 0.05 },  // share of bread lines that are the city's own treat (duz, naringi, alma)
  treat_worth: { value: 3, min: 1, max: 20, step: 1 },        // bread each of those treats is worth
  rain_count: { value: 700, min: 0, max: 3000, step: 50 },    // raindrops around the camera in Lənkəran

  // --- Score -----------------------------------------------------------------------------
  mult_every: { value: 500, min: 100, max: 2000, step: 50 },  // m per +1 multiplier (stand-in for missions)
  mult_cap: { value: 10, min: 1, max: 30, step: 1 },
  continue_cost: { value: 1, min: 1, max: 5, step: 1 },       // nar for the first continue in a run; doubles each time
};
