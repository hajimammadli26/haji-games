# Sound List: Cırtdan: Köhnə Bakıda Qaçış

Every sound is synthesised by `tools/audio/make_audio.gd` (instruments in `tools/audio/synth.gd`); there are
no recordings. After changing a recipe, run
`godot --headless --path . -s res://tools/audio/make_audio.gd`, then `godot --headless --path . --import`.
The game plays the sounds through `src/game/sound.gd` (`Sound.play(name)`, `Sound.music(mode)`).

## Loudness targets

| What | Format | Target | How |
|---|---|---|---|
| Big moments (crash, stumble, voices, power, shield, word, mission, record) | mono 22050 Hz, 16-bit | peak about -3 dBFS, RMS about -16 dBFS | `Synth.finish(peak_db)`: RMS set 13 dB under the peak level, plectrum and drum transients rounded off by up to 6 dB, never over the peak |
| Everyday pickups and moves (bread, jump, no, power_end) | same | peak -6 to -8 dBFS | `PEAK_DB` in make_audio.gd |
| Constant small sounds (slide, land, lane, tap) | same | peak -9 to -13 dBFS | heard many times a minute, so kept quiet |
| Music loops (menu, run, fly) | mono 16000 Hz, 16-bit | RMS -16 dBFS, peak at most -3 dBFS, then played at -8 dB (`Sound.MUSIC_DB`) | `Synth.finish_loop()`; about 8 dB under the effects in the game |

All effects: 4 ms attack on every note, 5 ms fade at both ends, the silent tail trimmed, a 6.5 kHz low-pass
(music: 5 kHz) so nothing is shrill for young ears, a 60 Hz high-pass (no DC, no rumble a phone speaker
cannot play). Music loops: notes ringing past the end fold back into the start, and the filters are run round
the loop, so the wrap point is seamless. All files import as QOA (`compress/mode=2`).

Repeated effects (jump, slide, land, lane, tap, stumble) get a small random pitch change in `Sound.VARY`; bread
already rises in pitch through a run of five.

## Music

The tune is in the Şur mode on D (D Eb F G A Bb C), 6/8, 8 bars.

| Loop | Length | Tempo | Instruments |
|---|---|---|---|
| `music_menu` | 4 bars, 15.0 s | 96 eighths/min | balaban melody, tar answers an octave up, tar bass, soft nağara (dum, ka, tek) |
| `music_run` | 8 bars, 21.8 s | 132 eighths/min, sped up with the run (`set_speed_ratio`) | tar melody (Karplus-Strong, two courses), tar bass on beats 1 and 4, nağara DUM . tek DUM ka tek with a soft kick |
| `music_fly` | 4 bars (bars 5-8), 10.9 s | 132 | balaban melody, tar sparkle an octave up, lighter nağara |

## Effects

| Event (where) | Sound | Description |
|---|---|---|
| Bread or a city treat taken (`sim.bread_taken`) | `bread` | two-note bell; pitch rises through five pickups |
| Pomegranate taken (`sim.nar_taken`) | `nar` | three tar plucks up the scale |
| Letter taken (`_on_item` letter) | `nar` at pitch 1.2 | |
| **Word complete** (last letter, gifts given) | `word` (new) | tar arpeggio D-F-A-Bb-D with a bell on top |
| Buta stone (`_on_item` buta) | `bread` at pitch 0.8 | |
| Magic stone (`_on_item` stone) | `power` at pitch 1.3 | |
| Power-up or boost taken (`sim.power_taken`) | `power` | rising triangle arpeggio with bell sparkle |
| **Power-up wears off** (number of running powers drops) | `power_end` (new) | soft two-step falling "wooo" |
| Carpet shield saves him (`sim.shield_used`) | `shield` | falling sine whoomp with a swell of air |
| Jump (`sim.jumped`) | `jump` | triangle slide up 300 to 640 Hz |
| Slide (`sim.slid`) | `slide` | swelling band-passed noise |
| Landing (grounded again) | `land` | soft low thud |
| Lane change | `lane` | short soft whoosh |
| Stumble (`sim.stumbled`) | `stumble` + voice `ay_cirtdan` | low "boing" thud, the Div shouts "Ay Cırtdan!" (recorded: ElevenLabs voice "Grav", eleven_v4; take 1 of 2 in tools/audio/recorded/) |
| **Div gives up** (`sim.escaped`) | `escape` (new) | whoosh away and a happy two-note tar "da-dum" |
| Crash (`sim.crashed`) | `crash` | nağara dum, noise burst, falling low tone |
| Caught by the Div (`sim.caught`) | voice `hamm` | "Hamm!" |
| **New record** on the game-over panel | `record` (new) | tar run up an octave and a ringing chord, 0.7 s after the crash |
| Continue with pomegranates | `power` at pitch 0.9 | |
| **Mission done** (`prog.mission_done`) | `mission` (new) | balaban call over nağara dum-dum-tek |
| Menu tap | `tap` | tiny sine pop |
| Purchase | `buy` | two coin bells |
| Purchase refused / not enough | `no` | soft "uh-uh", two falling notes |
| Story pages | voices `hi_hi`, `yene_sensen` | |

## Not yet covered

- The Div coming close after a stumble has no warning of its own (the stumble and "Ay Cırtdan!" voice mark it).
- No separate game-over jingle when there is no new record (the crash or "Hamm!" ends the run).
