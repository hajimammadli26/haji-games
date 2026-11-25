## Renders every sound of the game into assets/audio/ as WAV files: run it after changing a recipe.
##   godot --headless --path . -s res://tools/audio/make_audio.gd
## Recipes match the web prototype (prototypes/cirtdan/index.html, sfx / say / scheduleMusic): no recordings.
extends SceneTree

const OUT := "res://assets/audio/"
const RATE := 22050
const SHUR := [0, 1, 3, 5, 7, 8, 10, 12, 13, 15] ## Şur mode: semitones above D
const TUNE := [ ## scale degrees, one per eighth note, 6 a bar; -1 rests
	[4, 3, 4, 5, 4, 3], [2, 1, 2, 3, 2, -1], [4, 5, 7, 5, 4, 3], [2, 3, 1, 0, 0, -1],
	[7, 6, 7, 5, 6, 4], [5, 4, 3, 4, 2, -1], [3, 4, 5, 4, 3, 1], [2, 1, 0, -1, 0, -1],
]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var t0 := Time.get_ticks_msec()
	_sfx("bread", 0.25, func(s: Synth) -> void:
		s.tone(0.0, 1320, 0.07, "sine", 0.18)
		s.tone(0.05, 1980, 0.12, "sine", 0.14))
	_sfx("nar", 0.45, func(s: Synth) -> void:
		for i in 3:
			s.tone(i * 0.08, [660, 990, 1320][i], 0.2 if i == 2 else 0.1, "triangle", 0.25))
	_sfx("jump", 0.2, func(s: Synth) -> void: s.tone(0.0, 300, 0.18, "triangle", 0.22, 620))
	_sfx("slide", 0.27, func(s: Synth) -> void: s.noise(0.0, 0.25, 0.25 * 3.0, 500))
	_sfx("land", 0.08, func(s: Synth) -> void: s.noise(0.0, 0.06, 0.2 * 3.0, 200))
	_sfx("lane", 0.09, func(s: Synth) -> void: s.noise(0.0, 0.07, 0.12 * 3.0, 2400))
	_sfx("stumble", 0.3, func(s: Synth) -> void:
		s.tone(0.0, 140, 0.25, "square", 0.25, 70)
		s.noise(0.0, 0.15, 0.3 * 3.0, 300))
	_sfx("crash", 0.55, func(s: Synth) -> void:
		s.noise(0.0, 0.5, 0.5 * 3.0, 180)
		s.tone(0.0, 110, 0.5, "saw", 0.3, 40))
	_sfx("power", 0.4, func(s: Synth) -> void:
		for i in 4:
			s.tone(i * 0.06, [523, 659, 784, 1047][i], 0.12, "triangle", 0.2))
	_sfx("shield", 0.35, func(s: Synth) -> void:
		s.tone(0.0, 800, 0.3, "sine", 0.3, 200)
		s.noise(0.0, 0.2, 0.2 * 3.0, 1200))
	_sfx("buy", 0.3, func(s: Synth) -> void:
		s.tone(0.0, 880, 0.08, "triangle", 0.2)
		s.tone(0.07, 1320, 0.18, "sine", 0.18))
	_sfx("tap", 0.06, func(s: Synth) -> void: s.tone(0.0, 660, 0.05, "sine", 0.12))
	_sfx("no", 0.25, func(s: Synth) -> void: s.tone(0.0, 220, 0.2, "square", 0.15, 160))
	# voices
	_sfx("ay_cirtdan", 1.6, func(s: Synth) -> void:
		s.tone(0.0, 90, 0.3, "saw", 0.22, 60)
		s.voice(0.02, [["a", 0.16, 1.2, 1.3], ["i", 0.08, 1.3], ["c", 0.05], ["ı", 0.1, 1.25], ["r", 0.05], ["t", 0.03],
			["d", 0.03], ["a", 0.5, 1.35, 0.9], ["n", 0.14, 0.9, 0.85]], 105, 0.45))
	_sfx("hamm", 0.8, func(s: Synth) -> void:
		s.tone(0.0, 160, 0.12, "saw", 0.2, 90)
		s.voice(0.02, [["h", 0.07], ["a", 0.18, 1.1, 1.0], ["m", 0.32, 1.0, 0.8]], 95, 0.5))
	_sfx("yene_sensen", 1.2, func(s: Synth) -> void:
		s.voice(0.02, [["e", 0.1, 1.1], ["n", 0.05], ["ə", 0.12, 1.2], ["h", 0.05], ["ə", 0.1, 1.3], ["n", 0.06],
			["h", 0.05], ["ə", 0.24, 1.4, 1.1], ["n", 0.12]], 100, 0.45))
	_sfx("hi_hi", 0.5, func(s: Synth) -> void:
		s.voice(0.02, [["h", 0.04], ["i", 0.09, 1.3, 1.5], ["h", 0.04], ["i", 0.12, 1.4, 1.7]], 320, 0.25))
	# music: one loop of the 8-bar tune per mode
	for mode in ["menu", "run", "fly"]:
		_music(mode)
	print("audio made in %d ms" % (Time.get_ticks_msec() - t0))
	quit()


func _sfx(name: String, secs: float, recipe: Callable) -> void:
	var s := Synth.new(RATE, secs)
	recipe.call(s)
	_save(s.to_wav(1.6), name)


func _hz(deg: int, octave := 0) -> float:
	return 293.66 * pow(2.0, (SHUR[deg] + octave * 12) / 12.0)


func _music(mode: String) -> void:
	var bpm := 96.0 if mode == "menu" else 132.0
	var dt := 60.0 / bpm
	var steps := TUNE.size() * 6
	var length := steps * dt
	var s := Synth.new(RATE, length + 3.0)
	for i in steps:
		var t := i * dt
		var beat := i % 6
		var deg: int = TUNE[i / 6][beat]
		if mode == "menu":
			if deg >= 0 and beat % 2 == 0:
				s.balaban(t, _hz(deg), dt * 1.9, 0.16)
			if beat == 0:
				s.tar(t, _hz(0, -2), dt * 3.0, 0.12)
			if beat == 0 or beat == 3:
				s.drum(t, "dum", 0.18)
			elif beat == 5:
				s.drum(t, "tek", 0.05 * 3.0)
		else:
			var fly := mode == "fly"
			if deg >= 0:
				s.tar(t, _hz(deg, 1 if fly else 0), dt * 0.95, 0.13)
			if fly and deg >= 0 and beat % 3 == 0:
				s.balaban(t, _hz(deg), dt * 2.8, 0.14)
			if beat == 0:
				s.tar(t, _hz(0, -2), dt * 2.5, 0.12)
			if beat == 3:
				s.tar(t, _hz(4, -2), dt * 2.5, 0.1)
			if beat == 0 or beat == 3:
				s.drum(t, "kick", 0.35)
				s.drum(t, "dum", 0.14)
			else:
				s.drum(t, "tek", (0.1 if beat == 5 else 0.06) * 3.0)
			if fly and beat == 4:
				s.drum(t, "dum", 0.12)
	var n := int(length * RATE)
	var tail := s.buf.slice(n) # notes ringing past the end fold back into the start: a seamless loop
	s.buf.resize(n)
	s.mix(tail, 0.0)
	_save(s.to_wav({"menu": 1.0, "run": 2.8, "fly": 1.3}[mode], n), "music_" + mode)


func _save(w: AudioStreamWAV, name: String) -> void:
	var path := ProjectSettings.globalize_path(OUT + name + ".wav")
	var err := w.save_to_wav(path)
	print("%s %s (%.1f s)" % ["ok" if err == OK else "FAILED", name, w.data.size() / 2.0 / RATE])
