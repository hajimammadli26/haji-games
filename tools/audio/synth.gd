## A small offline synthesiser: renders the game's sound effects, voices and music into sample buffers,
## the same recipes as the web prototype's Web Audio code (prototypes/cirtdan/index.html: sfx, tar, balaban,
## drum, voice). Used only by tools/audio/make_audio.gd at development time; the game plays the WAV files.
##
## Usage:
##   var s := Synth.new(22050, 1.0)
##   s.tone(0.0, 1320.0, 0.07, "sine", 0.18)
##   var wav := s.to_wav()
class_name Synth
extends RefCounted

var rate := 22050
var buf := PackedFloat32Array()
var _seed := 12345


func _init(sample_rate: int, seconds: float) -> void:
	rate = sample_rate
	buf.resize(int(seconds * rate) + 1)


func _osc(kind: String, ph: float) -> float:
	var p := ph - floorf(ph)
	match kind:
		"sine":
			return sin(p * TAU)
		"square":
			return 1.0 if p < 0.5 else -1.0
		"triangle":
			return 4.0 * absf(p - 0.5) - 1.0
		_:
			return 2.0 * p - 1.0 # saw


func _rand() -> float:
	_seed = (_seed * 1103515245 + 12345) & 0x7fffffff
	return float(_seed) / 0x7fffffff * 2.0 - 1.0


## An oscillator note at t seconds: exponential decay to silence, an optional exponential pitch slide.
func tone(t: float, freq: float, dur: float, kind := "square", vol := 0.3, slide_to := 0.0) -> void:
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var ph := 0.0
	for i in n:
		var u := float(i) / n
		var f := freq * pow(slide_to / freq, u) if slide_to > 0.0 else freq
		ph += f / rate
		_add(i0 + i, _osc(kind, ph) * vol * pow(0.001 / vol, u) if vol > 0.001 else 0.0)


## Band-passed noise with a linear fade (whooshes, thuds, clicks).
func noise(t: float, dur: float, vol := 0.2, freq := 800.0, q := 1.0, seed_value := 12345, gate_hz := 0.0) -> void:
	_seed = seed_value
	var bq := Biquad.new("bandpass", freq, q, rate)
	var i0 := int(t * rate)
	var n := int(dur * rate)
	for i in n:
		var x := _rand() * (1.0 - float(i) / n)
		if gate_hz > 0.0 and sin(float(i) / rate * TAU * gate_hz) <= 0.0:
			x *= 0.2
		_add(i0 + i, bq.run(x) * vol)


## The tar: plucked, bright, a quick decay (saw plus a square an octave up, a closing low-pass).
func tar(t: float, hz: float, dur: float, vol: float) -> void:
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var bq := Biquad.new("lowpass", hz * 8.0, 0.7, rate)
	var ph := 0.0
	var ph2 := 0.0
	var attack := int(0.006 * rate)
	for i in n:
		var u := float(i) / n
		if i % 32 == 0:
			bq.set_freq(hz * 8.0 * pow(1.5 / 8.0, u))
		ph += hz / rate
		ph2 += hz * 2.005 / rate
		var x := _osc("saw", ph) + 0.25 * _osc("square", ph2)
		var env := (float(i) / attack) * vol if i < attack else vol * pow(0.0001 / vol, u)
		_add(i0 + i, bq.run(x) * env)


## The balaban: a soft reed, slow attack and vibrato.
func balaban(t: float, hz: float, dur: float, vol: float) -> void:
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var bq := Biquad.new("bandpass", hz * 2.0, 0.7, rate)
	var ph := 0.0
	var att := minf(0.08, dur * 0.3)
	for i in n:
		var tt := float(i) / rate
		ph += hz * (1.0 + 0.012 * sin(tt * TAU * 5.5)) / rate
		var x := _osc("triangle", ph)
		var env := vol
		if tt < att:
			env = vol * tt / att
		elif tt > dur * 0.75:
			env = vol * (dur - tt) / (dur * 0.25)
		_add(i0 + i, (bq.run(x) + x) * env)


## Nağara and the beat: dum (low), tek (rim), kick.
func drum(t: float, kind: String, vol: float) -> void:
	if kind == "tek":
		noise(t, 0.06, vol, 2400.0, 1.2, 777)
		return
	var f0 := 120.0 if kind == "kick" else 160.0
	var f1 := 42.0 if kind == "kick" else 70.0
	var i0 := int(t * rate)
	var n := int(0.25 * rate)
	var ph := 0.0
	for i in n:
		var u := float(i) / n
		var f := f0 * pow(f1 / f0, minf(1.0, u * 0.25 / 0.18))
		ph += f / rate
		_add(i0 + i, sin(ph * TAU) * vol * pow(0.0001 / vol, u))


const VOWEL := {"a": [800, 1250], "ı": [380, 1400], "i": [300, 2300], "ə": [650, 1750], "e": [480, 1900],
	"o": [480, 850], "m": [250, 0], "n": [280, 0]}


## A short word from a formant synth: parts are [sound, seconds, pitch start, pitch end].
func voice(t: float, parts: Array, base: float, vol := 0.4) -> void:
	for p in parts:
		var snd: String = p[0]
		var dur: float = p[1]
		var p0: float = p[2] if p.size() > 2 else 1.0
		var p1: float = p[3] if p.size() > 3 else p0
		var i0 := int(t * rate)
		var n := int(dur * rate)
		if VOWEL.has(snd):
			var f1: float = VOWEL[snd][0]
			var f2: float = VOWEL[snd][1]
			var b1 := Biquad.new("bandpass" if f2 > 0.0 else "lowpass", f1, 6.0 if f2 > 0.0 else 1.0, rate)
			var b2 := Biquad.new("bandpass", maxf(f2, 100.0), 8.0, rate)
			var ph := 0.0
			for i in n:
				var tt := float(i) / rate
				ph += base * lerpf(p0, p1, float(i) / n) / rate
				var x := _osc("saw", ph)
				var y := b1.run(x) + (0.6 * b2.run(x) if f2 > 0.0 else 0.0)
				var env := vol
				if tt < 0.02:
					env = vol * tt / 0.02
				elif tt > dur - 0.03:
					env = vol * maxf(0.0, dur - tt) / 0.03
				_add(i0 + i, y * env * 0.8)
		else:
			var fq: float = {"c": 3000.0, "t": 4500.0, "d": 900.0, "h": 1500.0, "r": 1200.0}.get(snd, 2000.0)
			noise(t, dur, vol * (0.5 if snd == "h" else 0.8), fq, 1.0, 99, 28.0 if snd == "r" else 0.0)
		t += dur


func _add(i: int, v: float) -> void:
	if i >= 0 and i < buf.size():
		buf[i] += v


## Mixes another buffer in at t seconds (to loop a track's tail into its start).
func mix(other: PackedFloat32Array, t: float) -> void:
	var i0 := int(t * rate)
	for i in other.size():
		_add(i0 + i, other[i])


## The buffer as 16-bit mono WAV, gently limited; loop_end > 0 makes it loop.
func to_wav(gain := 1.0, loop_end := 0) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		var v := buf[i] * gain
		v = v / (1.0 + absf(v) * 0.35) # soft clip
		bytes.encode_s16(i * 2, clampi(int(v * 32767.0), -32768, 32767))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = bytes
	if loop_end > 0:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = loop_end
	return w


## An RBJ biquad filter (low-pass or band-pass), run one sample at a time.
class Biquad:
	var kind := "lowpass"
	var q := 0.7
	var rate := 22050
	var b0 := 0.0
	var b1 := 0.0
	var b2 := 0.0
	var a1 := 0.0
	var a2 := 0.0
	var x1 := 0.0
	var x2 := 0.0
	var y1 := 0.0
	var y2 := 0.0

	func _init(k: String, f: float, qv: float, r: int) -> void:
		kind = k
		q = qv
		rate = r
		set_freq(f)

	func set_freq(f: float) -> void:
		var w := TAU * minf(f, rate * 0.45) / rate
		var al := sin(w) / (2.0 * q)
		var cw := cos(w)
		var a0 := 1.0 + al
		if kind == "lowpass":
			b0 = (1.0 - cw) / 2.0 / a0
			b1 = (1.0 - cw) / a0
			b2 = b0
		else:
			b0 = al / a0
			b1 = 0.0
			b2 = -al / a0
		a1 = -2.0 * cw / a0
		a2 = (1.0 - al) / a0

	func run(x: float) -> float:
		var y := b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
		x2 = x1
		x1 = x
		y2 = y1
		y1 = y
		return y
