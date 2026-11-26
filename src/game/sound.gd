## Plays the game's sounds: short effects from a small pool of players, three music loops (menu, run, fly)
## that crossfade, and the tempo of the run music rising with the speed. Obeys the music and sound settings.
## The WAV files are made by tools/audio/make_audio.gd (synthesised: Şur-mode tar, balaban and nağara music);
## the list of sounds, what plays them and their levels: design/audio/sound-list.md.
##
## Usage:
##   var snd := Sound.new(save); add_child(snd)
##   snd.play("bread"); snd.music("run"); snd.set_speed_ratio(1.2)
class_name Sound
extends Node

const DIR := "res://assets/audio/"
const SFX := ["bread", "nar", "jump", "slide", "land", "lane", "stumble", "crash", "power", "shield", "buy", "tap",
	"no", "ay_cirtdan", "hamm", "yene_sensen", "hi_hi", "word", "mission", "power_end", "escape", "record"]
## Effects heard over and over get a small random pitch change, so repeats do not sound mechanical.
const VARY := {"jump": 0.04, "slide": 0.04, "land": 0.06, "lane": 0.06, "tap": 0.03, "stumble": 0.03}
const MUSIC := ["menu", "run", "fly"]
const POOL := 8
const MUSIC_DB := -8.0 ## the loops are mastered at -16 dBFS RMS: about 8 dB under the effects
const FADE := 0.6 ## seconds of a music crossfade
const RECORDED_SPEEDUP_MAX := 1.06 ## recorded run music plays at most this much faster (and higher)

var save: SaveData
var _streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _music := {} ## mode -> AudioStreamPlayer
var _mode := ""
var _rate := 1.0
var _rng := RandomNumberGenerator.new()


func _init(save_data: SaveData) -> void:
	save = save_data


func _ready() -> void:
	for n in SFX:
		_streams[n] = load(DIR + n + ".wav")
	for i in POOL:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	for m in MUSIC:
		var p := AudioStreamPlayer.new()
		p.stream = _music_stream(m)
		p.volume_db = -80.0
		add_child(p)
		_music[m] = p


## Plays an effect (a name in SFX) at a pitch (1.0 = as made); effects in VARY are varied a little more.
func play(name: String, pitch: float = 1.0) -> void:
	if not bool(save.get_value("sound")) or not _streams.has(name):
		return
	var p := _pool[_next]
	_next = (_next + 1) % POOL
	p.stream = _streams[name]
	p.pitch_scale = pitch * (1.0 + _rng.randf_range(-1.0, 1.0) * float(VARY.get(name, 0.0)))
	p.play()


## Switches the music to a mode (menu, run, fly; "" for none) with a short crossfade.
func music(mode: String) -> void:
	if mode == _mode:
		return
	_mode = mode
	for m in _music:
		var p: AudioStreamPlayer = _music[m]
		var on: bool = m == mode and bool(save.get_value("music"))
		if on and not p.playing:
			p.play()
		var tw := create_tween()
		tw.tween_property(p, "volume_db", MUSIC_DB if on else -80.0, FADE)
		if not on:
			tw.tween_callback(p.stop)


## The run music speeds up with the run (1.0 at the start speed). Recorded music (OGG) only a little, since
## speeding it up raises its pitch too.
func set_speed_ratio(r: float) -> void:
	if absf(r - _rate) < 0.01:
		return
	_rate = r
	var p := _music["run"] as AudioStreamPlayer
	p.pitch_scale = minf(RECORDED_SPEEDUP_MAX, 1.0 + (r - 1.0) * 0.25) if p.stream is AudioStreamOggVorbis else r


## The loop for a music mode: a recorded music_<mode>.ogg (ElevenLabs Music, owner 2026-11-26) when one exists,
## else the synthesised music_<mode>.wav. The fly mode reuses the run recording when it has none of its own.
func _music_stream(m: String) -> AudioStream:
	for name in [m, "run" if m == "fly" else m]:
		if ResourceLoader.exists(DIR + "music_" + name + ".ogg"):
			var o: AudioStreamOggVorbis = load(DIR + "music_" + name + ".ogg")
			o.loop = true
			return o
	var w: AudioStreamWAV = load(DIR + "music_" + m + ".wav")
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD # the loop is cut to whole bars by the tool
	w.loop_begin = 0
	w.loop_end = int(w.get_length() * w.mix_rate)
	return w


## Re-reads the settings after the player turned music or sound on or off.
func settings_changed() -> void:
	var m := _mode
	_mode = "-"
	music(m)
