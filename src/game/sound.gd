## Plays the game's sounds: short effects from a small pool of players, three music loops (menu, run, fly)
## that crossfade, and the tempo of the run music rising with the speed. Obeys the music and sound settings.
## The WAV files are made by tools/audio/make_audio.gd (synthesised, the web prototype's recipes).
##
## Usage:
##   var snd := Sound.new(save); add_child(snd)
##   snd.play("bread"); snd.music("run"); snd.set_speed_ratio(1.2)
class_name Sound
extends Node

const DIR := "res://assets/audio/"
const SFX := ["bread", "nar", "jump", "slide", "land", "lane", "stumble", "crash", "power", "shield", "buy", "tap",
	"no", "ay_cirtdan", "hamm", "yene_sensen", "hi_hi"]
const MUSIC := ["menu", "run", "fly"]
const POOL := 8
const MUSIC_DB := -6.0
const FADE := 0.6 ## seconds of a music crossfade

var save: SaveData
var _streams := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _music := {} ## mode -> AudioStreamPlayer
var _mode := ""
var _rate := 1.0


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
		var w: AudioStreamWAV = load(DIR + "music_" + m + ".wav")
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD # the loop is cut to whole bars by the tool
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
		var p := AudioStreamPlayer.new()
		p.stream = w
		p.volume_db = -80.0
		add_child(p)
		_music[m] = p


## Plays an effect (a name in SFX); pitch varies it slightly so repeats do not sound mechanical.
func play(name: String, pitch: float = 1.0) -> void:
	if not bool(save.get_value("sound")) or not _streams.has(name):
		return
	var p := _pool[_next]
	_next = (_next + 1) % POOL
	p.stream = _streams[name]
	p.pitch_scale = pitch
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


## The run music speeds up with the run (1.0 at the start speed).
func set_speed_ratio(r: float) -> void:
	if absf(r - _rate) < 0.01:
		return
	_rate = r
	(_music["run"] as AudioStreamPlayer).pitch_scale = r


## Re-reads the settings after the player turned music or sound on or off.
func settings_changed() -> void:
	var m := _mode
	_mode = "-"
	music(m)
