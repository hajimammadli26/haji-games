## A small offline synthesiser: renders the game's sound effects, voices and music into sample buffers.
## Started from the web prototype's Web Audio recipes (prototypes/cirtdan/index.html); the instruments are
## now closer to the real ones: a Karplus-Strong tar (two plucked courses), a balaban reed (odd harmonics,
## breath, late vibrato, a grace slide from below) and a nağara (a skin with a slap). finish() and
## finish_loop() master a buffer: a gentle low-pass for young ears, click-free edges, a set level.
## Used only by tools/audio/make_audio.gd at development time; the game plays the WAV files.
##
## Usage:
##   var s := Synth.new(22050, 1.0)
##   s.tone(0.0, 1320.0, 0.07, "sine", 0.18)
##   s.finish(-3.0)
##   var wav := s.to_wav()
class_name Synth
extends RefCounted

const ATTACK := 0.004 ## s: every tone and noise starts with this ramp, so nothing clicks on
const RMS_UNDER_PEAK := 13.0 ## dB: how far an effect's RMS sits under its peak level (finish)

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
		"soft": # a rounded square: odd harmonics 1, 3, 5 only (no buzz)
			return sin(p * TAU) + sin(p * TAU * 3.0) / 3.0 + sin(p * TAU * 5.0) / 5.0
		_:
			return 2.0 * p - 1.0 # saw


func _rand() -> float:
	_seed = (_seed * 1103515245 + 12345) & 0x7fffffff
	return float(_seed) / 0x7fffffff * 2.0 - 1.0


## An oscillator note at t seconds: a short attack, exponential decay to silence, an optional pitch slide.
func tone(t: float, freq: float, dur: float, kind := "sine", vol := 0.3, slide_to := 0.0) -> void:
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var att := int(ATTACK * rate)
	var ph := 0.0
	for i in n:
		var u := float(i) / n
		var f := freq * pow(slide_to / freq, u) if slide_to > 0.0 else freq
		ph += f / rate
		var env := vol * pow(0.001, u)
		if i < att:
			env *= float(i) / att
		_add(i0 + i, _osc(kind, ph) * env)


## A small bell: a sine with a soft inharmonic partial (bread, coins, sparkles).
func bell(t: float, freq: float, dur: float, vol := 0.3) -> void:
	tone(t, freq, dur, "sine", vol)
	tone(t, freq * 2.76, dur * 0.4, "sine", vol * 0.25)


## Band-passed noise: a short attack, then a fade (whooshes, thuds, clicks). swell puts the peak mid-way.
func noise(t: float, dur: float, vol := 0.2, freq := 800.0, q := 1.0, seed_value := 12345, gate_hz := 0.0,
		swell := false) -> void:
	_seed = seed_value
	var bq := Biquad.new("bandpass", freq, q, rate)
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var att := int(ATTACK * rate)
	for i in n:
		var u := float(i) / n
		var env := sin(u * PI) if swell else (1.0 - u)
		if not swell and i < att:
			env *= float(i) / att
		var x := _rand() * env
		if gate_hz > 0.0 and sin(float(i) / rate * TAU * gate_hz) <= 0.0:
			x *= 0.2
		_add(i0 + i, bq.run(x) * vol)


## The tar: Karplus-Strong plucked string, two courses tuned a hair apart (the tar's paired strings).
## bright (0..1) is how hard the plectrum hits.
func tar(t: float, hz: float, dur: float, vol: float, bright := 0.6) -> void:
	for course in 2:
		_pluck(t + course * 0.004, hz * (1.0 + course * 0.0025), dur, vol * 0.6, bright, 4242 + course * 17)


func _pluck(t: float, hz: float, dur: float, vol: float, bright: float, seed_value: int) -> void:
	var d := float(rate) / hz - 0.5 # the averaging filter adds half a sample of delay
	var size := int(d) + 3
	var line := PackedFloat32Array()
	line.resize(size)
	_seed = seed_value
	var lp := 0.0
	for i in size: # the pluck: noise, softened for a gentler hit
		lp += (_rand() - lp) * (0.25 + 0.6 * bright)
		line[i] = lp
	var mean := 0.0
	for v in line:
		mean += v
	mean /= size
	for i in size:
		line[i] -= mean
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var w := 0
	var frac := d - floorf(d)
	var di := int(d)
	var prev := 0.0
	var decay := pow(0.001, 1.0 / maxf(1.0, dur * hz)) # per round trip: -60 dB by the note's end
	var rel := int(0.02 * rate)
	for i in n:
		var r0 := (w - di + size * 4) % size
		var r1 := (r0 - 1 + size) % size
		var y := lerpf(line[r0], line[r1], frac)
		var nxt := 0.5 * (y + prev) * decay
		prev = y
		line[w] = nxt
		w = (w + 1) % size
		var env := vol
		if i < 30:
			env *= float(i) / 30.0
		if i > n - rel:
			env *= float(n - i) / rel
		_add(i0 + i, y * env)


## The balaban: a soft reed (odd harmonics, a breath of noise), a grace slide up from a semitone below,
## a slow attack and a vibrato that comes in late, as a player would.
func balaban(t: float, hz: float, dur: float, vol: float) -> void:
	var i0 := int(t * rate)
	var n := int(dur * rate)
	var ph := 0.0
	var att := minf(0.07, dur * 0.3)
	var rel := minf(0.12, dur * 0.3)
	_seed = 555
	var br := Biquad.new("bandpass", hz * 3.0, 1.2, rate)
	for i in n:
		var tt := float(i) / rate
		var bend := lerpf(0.944, 1.0, minf(1.0, tt / 0.05)) # the grace note
		var vib := 1.0 + 0.010 * sin(tt * TAU * 5.2) * clampf((tt - 0.18) / 0.2, 0.0, 1.0)
		ph += hz * bend * vib / rate
		var x := sin(ph * TAU) + 0.33 * sin(ph * TAU * 3.0) + 0.12 * sin(ph * TAU * 5.0) + 0.08 * sin(ph * TAU * 2.0)
		x += br.run(_rand()) * 0.5
		var env := vol
		if tt < att:
			env = vol * tt / att
		elif tt > dur - rel:
			env = vol * maxf(0.0, dur - tt) / rel
		_add(i0 + i, x * env)


## Nağara and the beat: dum (the low skin), tek (the rim), ka (a light slap), kick (a soft low thump).
func drum(t: float, kind: String, vol: float) -> void:
	var f0: float = {"kick": 110.0, "dum": 150.0, "tek": 420.0, "ka": 300.0}.get(kind, 150.0)
	var f1: float = {"kick": 45.0, "dum": 80.0, "tek": 360.0, "ka": 260.0}.get(kind, 80.0)
	var len_s: float = {"kick": 0.22, "dum": 0.3, "tek": 0.07, "ka": 0.1}.get(kind, 0.25)
	var i0 := int(t * rate)
	var n := int(len_s * rate)
	var ph := 0.0
	for i in n:
		var u := float(i) / n
		var f := f0 * pow(f1 / f0, minf(1.0, u * 2.5))
		ph += f / rate
		var env := vol * pow(0.001, u)
		if i < 20:
			env *= float(i) / 20.0
		_add(i0 + i, sin(ph * TAU) * env)
	match kind: # the hand on the skin
		"dum":
			noise(t, 0.04, vol * 0.5, 900.0, 1.0, 321)
		"tek":
			noise(t, 0.05, vol * 0.9, 2200.0, 1.4, 777)
		"ka":
			noise(t, 0.06, vol * 0.6, 1500.0, 1.0, 888)


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


## Masters an effect: a gentle low-pass (lp_hz), the silent tail trimmed, 5 ms fades at both ends, and the
## loudest sample set to peak_db dBFS.
func finish(peak_db: float, lp_hz := 6500.0) -> void:
	var a := Biquad.new("lowpass", lp_hz, 0.6, rate)
	var hp := 0.0
	var prev := 0.0
	var k := exp(-TAU * 60.0 / rate) # a one-pole high-pass at 60 Hz: no DC, no rumble a phone cannot play
	for i in buf.size():
		var x := a.run(buf[i])
		hp = k * (hp + x - prev)
		prev = x
		buf[i] = hp
	var pk := _peak()
	if pk <= 0.0:
		return
	var end := buf.size()
	while end > 1 and absf(buf[end - 1]) < pk * 0.001: # -60 dB under the peak is silence
		end -= 1
	buf.resize(mini(buf.size(), end + int(0.01 * rate)))
	var fade := int(0.005 * rate)
	for i in mini(fade, buf.size()):
		buf[i] *= float(i) / fade
		buf[buf.size() - 1 - i] *= float(i) / fade
	# loudness: RMS (over the sounding part) RMS_UNDER_PEAK dB under the peak level, the plectrum and drum
	# transients rounded off by up to 6 dB to get there, never past the peak level
	var c := db_to_linear(peak_db)
	var g := minf(db_to_linear(peak_db - RMS_UNDER_PEAK) / _rms(true), c / _peak() * 2.0)
	for i in buf.size():
		buf[i] = _knee(buf[i] * g, c)
	if _peak() < c and _rms(true) < db_to_linear(peak_db - RMS_UNDER_PEAK): # room left: up to the peak
		_gain(minf(c / _peak(), db_to_linear(peak_db - RMS_UNDER_PEAK) / _rms(true)))


## Masters a music loop: the low-pass run round the loop (so the wrap is seamless), the level set to rms_db
## dBFS, the peaks rounded off softly under ceiling_db.
func finish_loop(rms_db: float, ceiling_db: float, lp_hz := 5000.0) -> void:
	var a := Biquad.new("lowpass", lp_hz, 0.6, rate)
	var hp := 0.0
	var prev := 0.0
	var k := exp(-TAU * 60.0 / rate)
	for pass_i in 2: # the first pass only warms the filters with the loop's end
		for i in buf.size():
			var x := a.run(buf[i])
			hp = k * (hp + x - prev)
			prev = x
			if pass_i == 1:
				buf[i] = hp
	var c := db_to_linear(ceiling_db)
	var g := db_to_linear(rms_db) / _rms(false)
	for it in 4: # the knee takes some level off the peaks: measure again and make it up
		var sum := 0.0
		for v in buf:
			var y := _knee(v * g, c)
			sum += y * y
		g *= db_to_linear(rms_db) / sqrt(sum / buf.size())
	for i in buf.size():
		buf[i] = _knee(buf[i] * g, c)


## A soft knee: untouched below 60 % of the ceiling c, never above it.
func _knee(v: float, c: float) -> float:
	if absf(v) <= c * 0.6:
		return v
	var over := (absf(v) - c * 0.6) / (c * 0.4)
	return signf(v) * c * (0.6 + 0.4 * over / (1.0 + over))


## RMS of the buffer; active_only leaves out the silence (below -60 dB under the peak).
func _rms(active_only: bool) -> float:
	var floor_v := _peak() * 0.001 if active_only else -1.0
	var sum := 0.0
	var n := 0
	for v in buf:
		if absf(v) > floor_v:
			sum += v * v
			n += 1
	return sqrt(sum / maxi(1, n))


func _peak() -> float:
	var pk := 0.0
	for v in buf:
		pk = maxf(pk, absf(v))
	return pk


func _gain(g: float) -> void:
	for i in buf.size():
		buf[i] *= g


## The buffer as 16-bit mono WAV (master it with finish() or finish_loop() first); loop_end > 0 loops it.
func to_wav(loop_end := 0) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		bytes.encode_s16(i * 2, clampi(int(round(buf[i] * 32767.0)), -32768, 32767))
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
