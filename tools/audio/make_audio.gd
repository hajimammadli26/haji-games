## Renders every sound of the game into assets/audio/ as WAV files: run it after changing a recipe, then
## re-import (godot --headless --path . --import).
##   godot --headless --path . -s res://tools/audio/make_audio.gd
## Recipes started from the web prototype (prototypes/cirtdan/index.html, sfx / say / scheduleMusic): no
## recordings. Levels and the list of sounds: design/audio/sound-list.md.
## Effects: mono 22050 Hz, low-passed at 6.5 kHz, 5 ms fades, the peak set per sound (PEAK_DB).
## Music: mono 16000 Hz loops in the Şur mode (tar, balaban, nağara), low-passed at 5 kHz, RMS MUSIC_RMS_DB.
extends SceneTree

const OUT := "res://assets/audio/"
const RATE := 22050
const MUSIC_RATE := 16000
const MUSIC_RMS_DB := -16.0 ## every loop the same loudness; the game plays them a further 8 dB down
const MUSIC_CEIL_DB := -3.0
## Peak level of each effect in dBFS: the big moments at -3, everyday pickups and moves lower, the tiny
## constant ones (lane, land, tap) lowest so they never tire the ear.
const PEAK_DB := {
	"crash": -3.0, "stumble": -3.0, "hamm": -3.0, "ay_cirtdan": -3.0, "yene_sensen": -3.0, "hi_hi": -4.0,
	"power": -3.0, "shield": -3.0, "word": -3.0, "mission": -3.0, "record": -3.0, "escape": -4.0,
	"nar": -4.0, "buy": -4.0, "power_end": -6.0, "no": -7.0, "bread": -7.0, "jump": -7.0, "slide": -9.0,
	"land": -11.0, "lane": -13.0, "tap": -12.0,
}
const SHUR := [0, 1, 3, 5, 7, 8, 10, 12, 13, 15] ## Şur mode: semitones above D
const TUNE := [ ## scale degrees, one per eighth note, 6 a bar (6/8); -1 rests
	[4, 3, 4, 5, 4, 3], [2, 1, 2, 3, 2, -1], [4, 5, 7, 5, 4, 3], [2, 3, 1, 0, 0, -1],
	[7, 6, 7, 5, 6, 4], [5, 4, 3, 4, 2, -1], [3, 4, 5, 4, 3, 1], [2, 1, 0, -1, 0, -1],
]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var t0 := Time.get_ticks_msec()
	# pickups
	_sfx("bread", 0.3, func(s: Synth) -> void: # a little bell
		s.bell(0.0, 1175, 0.12, 0.3)
		s.bell(0.05, 1568, 0.2, 0.25))
	_sfx("nar", 0.5, func(s: Synth) -> void: # three tar plucks up the Şur scale
		for i in 3:
			s.tar(i * 0.07, _hz([4, 7, 9][i], 1), 0.35 if i == 2 else 0.2, 0.3, 0.8))
	_sfx("power", 0.55, func(s: Synth) -> void: # a rising sparkle
		for i in 4:
			s.tone(i * 0.06, _hz([0, 2, 4, 7][i], 1), 0.16, "triangle", 0.22)
			s.bell(i * 0.06 + 0.02, _hz([0, 2, 4, 7][i], 2), 0.12, 0.08)
		s.tone(0.24, _hz(7, 1), 0.3, "sine", 0.18, _hz(7, 1) * 1.02))
	_sfx("power_end", 0.4, func(s: Synth) -> void: # the power wears off: a soft falling "wooo"
		s.tone(0.0, 784, 0.16, "triangle", 0.2, 659)
		s.tone(0.14, 587, 0.24, "triangle", 0.2, 440))
	_sfx("shield", 0.45, func(s: Synth) -> void: # the carpet catches him: a soft whoomp
		s.tone(0.0, 700, 0.35, "sine", 0.35, 180)
		s.noise(0.0, 0.3, 0.5, 900, 0.8, 4, 0.0, true))
	# moves
	_sfx("jump", 0.22, func(s: Synth) -> void:
		s.tone(0.0, 300, 0.2, "triangle", 0.25, 640)
		s.tone(0.0, 600, 0.12, "sine", 0.08, 1280))
	_sfx("slide", 0.3, func(s: Synth) -> void: s.noise(0.0, 0.28, 0.8, 600, 0.9, 12345, 0.0, true))
	_sfx("land", 0.12, func(s: Synth) -> void: # a soft step
		s.tone(0.0, 130, 0.09, "sine", 0.4, 70)
		s.noise(0.0, 0.05, 0.5, 300, 1.0, 7))
	_sfx("lane", 0.12, func(s: Synth) -> void: s.noise(0.0, 0.11, 0.7, 1300, 1.2, 99, 0.0, true))
	# trouble
	_sfx("stumble", 0.35, func(s: Synth) -> void:
		s.tone(0.0, 150, 0.28, "soft", 0.25, 75)
		s.noise(0.0, 0.15, 0.6, 350, 1.0, 5))
	_sfx("crash", 0.6, func(s: Synth) -> void:
		s.drum(0.0, "dum", 0.6)
		s.noise(0.0, 0.5, 1.2, 220, 0.8, 6)
		s.tone(0.0, 110, 0.5, "soft", 0.25, 45))
	_sfx("escape", 0.7, func(s: Synth) -> void: # the Div gave up: a whoosh away and a happy "da-dum"
		s.noise(0.0, 0.35, 0.6, 700, 0.8, 21, 0.0, true)
		s.tar(0.28, _hz(4, 1), 0.2, 0.3, 0.7)
		s.tar(0.4, _hz(7, 1), 0.3, 0.32, 0.7))
	# rewards
	_sfx("word", 1.0, func(s: Synth) -> void: # a word is whole: an arpeggio up the scale and a bell on top
		var degs := [0, 2, 4, 5, 7]
		for i in degs.size():
			s.tar(i * 0.08, _hz(degs[i], 1), 0.5, 0.25, 0.7)
		s.bell(0.4, _hz(7, 2), 0.5, 0.22))
	_sfx("mission", 1.3, func(s: Synth) -> void: # a mission done: a balaban call over nağara, dum-dum-tek
		s.drum(0.0, "dum", 0.4)
		s.drum(0.15, "dum", 0.35)
		s.drum(0.3, "tek", 0.3)
		s.balaban(0.0, _hz(4), 0.16, 0.22)
		s.balaban(0.15, _hz(5), 0.16, 0.22)
		s.balaban(0.3, _hz(7), 0.75, 0.25)
		s.bell(0.3, _hz(7, 2), 0.6, 0.12))
	_sfx("record", 1.5, func(s: Synth) -> void: # a new best: a tar run up an octave and a ringing chord
		var degs := [0, 3, 4, 5, 6, 7]
		for i in degs.size():
			s.tar(i * 0.07, _hz(degs[i]), 0.3, 0.25, 0.7)
		for d in [0, 4, 7]:
			s.tar(0.45, _hz(d, 1), 1.0, 0.2, 0.6)
		s.drum(0.45, "dum", 0.3)
		s.bell(0.45, _hz(7, 2), 0.9, 0.12))
	# the shop and the menu
	_sfx("buy", 0.35, func(s: Synth) -> void:
		s.bell(0.0, 880, 0.1, 0.25)
		s.bell(0.07, 1320, 0.22, 0.25))
	_sfx("tap", 0.06, func(s: Synth) -> void: s.tone(0.0, 900, 0.05, "sine", 0.3, 600))
	_sfx("no", 0.32, func(s: Synth) -> void: # "uh-uh"
		s.tone(0.0, 233, 0.12, "soft", 0.2, 220)
		s.tone(0.15, 208, 0.16, "soft", 0.2, 185))
	# voices
	_sfx("ay_cirtdan", 1.6, func(s: Synth) -> void:
		s.tone(0.0, 90, 0.3, "soft", 0.22, 60)
		s.voice(0.02, [["a", 0.16, 1.2, 1.3], ["i", 0.08, 1.3], ["c", 0.05], ["ı", 0.1, 1.25], ["r", 0.05], ["t", 0.03],
			["d", 0.03], ["a", 0.5, 1.35, 0.9], ["n", 0.14, 0.9, 0.85]], 105, 0.45))
	_sfx("hamm", 0.8, func(s: Synth) -> void:
		s.tone(0.0, 160, 0.12, "soft", 0.2, 90)
		s.voice(0.02, [["h", 0.07], ["a", 0.18, 1.1, 1.0], ["m", 0.32, 1.0, 0.8]], 95, 0.5))
	_sfx("yene_sensen", 1.2, func(s: Synth) -> void:
		s.voice(0.02, [["e", 0.1, 1.1], ["n", 0.05], ["ə", 0.12, 1.2], ["h", 0.05], ["ə", 0.1, 1.3], ["n", 0.06],
			["h", 0.05], ["ə", 0.24, 1.4, 1.1], ["n", 0.12]], 100, 0.45))
	_sfx("hi_hi", 0.5, func(s: Synth) -> void:
		s.voice(0.02, [["h", 0.04], ["i", 0.09, 1.3, 1.5], ["h", 0.04], ["i", 0.12, 1.4, 1.7]], 320, 0.25))
	# music: menu and fly are 4-bar loops, the run (heard longest) all 8 bars
	_music("menu", 96.0, 0, 4)
	_music("run", 132.0, 0, 8)
	_music("fly", 132.0, 4, 4)
	print("audio made in %d ms" % (Time.get_ticks_msec() - t0))
	quit()


func _sfx(name: String, secs: float, recipe: Callable) -> void:
	var s := Synth.new(RATE, secs)
	recipe.call(s)
	s.finish(PEAK_DB[name])
	_save(s.to_wav(), name)


func _hz(deg: int, octave := 0) -> float:
	return 293.66 * pow(2.0, (SHUR[deg] + octave * 12) / 12.0)


## One loop: bars [from, from + bars) of the tune, 6 eighth notes a bar at bpm eighths a minute.
func _music(mode: String, bpm: float, from: int, bars: int) -> void:
	var dt := 60.0 / bpm
	var steps := bars * 6
	var length := steps * dt
	var s := Synth.new(MUSIC_RATE, length + 3.0)
	for i in steps:
		var t := i * dt
		var beat := i % 6
		var deg: int = TUNE[from + i / 6][beat]
		match mode:
			"menu": # calm: the balaban sings, the tar marks the bar, a soft nağara
				if deg >= 0 and beat % 2 == 0:
					s.balaban(t, _hz(deg), dt * 1.9, 0.14)
				if deg >= 0 and beat % 2 == 1:
					s.tar(t, _hz(deg, 1), dt * 1.5, 0.05, 0.4)
				if beat == 0:
					s.tar(t, _hz(0, -1), dt * 4.0, 0.12, 0.4)
					s.drum(t, "dum", 0.22)
				elif beat == 3:
					s.tar(t, _hz(4, -1), dt * 2.5, 0.08, 0.4)
					s.drum(t, "ka", 0.1)
				elif beat == 5:
					s.drum(t, "tek", 0.07)
			"run": # the tar leads, a bass tar on the strong beats, the nağara drives
				if deg >= 0:
					s.tar(t, _hz(deg), dt * 1.2, 0.16, 0.7)
				if beat == 0:
					s.tar(t, _hz(0, -1), dt * 2.8, 0.13, 0.5)
				if beat == 3:
					s.tar(t, _hz(4, -1), dt * 2.8, 0.11, 0.5)
				_nagara(s, t, beat, 1.0)
			"fly": # up in the sky: the balaban leads, the tar sparkles an octave up, a lighter beat
				if deg >= 0:
					s.balaban(t, _hz(deg), dt * 1.05, 0.13)
				if deg >= 0 and beat % 3 == 0:
					s.tar(t, _hz(deg, 1), dt * 1.5, 0.06, 0.6)
				if beat == 0:
					s.tar(t, _hz(0, -1), dt * 5.5, 0.1, 0.4)
				_nagara(s, t, beat, 0.6)
	var n := int(length * MUSIC_RATE)
	var tail := s.buf.slice(n) # notes ringing past the end fold back into the start: a seamless loop
	s.buf.resize(n)
	s.mix(tail, 0.0)
	s.finish_loop(MUSIC_RMS_DB, MUSIC_CEIL_DB)
	_save(s.to_wav(n), "music_" + mode)


## A 6/8 nağara bar: DUM . tek DUM ka tek, a soft kick under the two strong beats.
func _nagara(s: Synth, t: float, beat: int, amt: float) -> void:
	match beat:
		0, 3:
			s.drum(t, "dum", 0.3 * amt)
			s.drum(t, "kick", 0.3 * amt)
		2, 5:
			s.drum(t, "tek", 0.1 * amt)
		4:
			s.drum(t, "ka", 0.12 * amt)
		1:
			s.drum(t, "tek", 0.05 * amt)


func _save(w: AudioStreamWAV, name: String) -> void:
	var path := ProjectSettings.globalize_path(OUT + name + ".wav")
	var err := w.save_to_wav(path)
	print("%s %s (%.2f s)" % ["ok" if err == OK else "FAILED", name, w.data.size() / 2.0 / w.mix_rate])
