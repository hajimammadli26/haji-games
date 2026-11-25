## Paints the game's textures into assets/textures/*.png with Godot's 2D drawing: cobbles, sandstone, şəbəkə
## windows, Qarabağ carpets, the buta, vests, wicker, the bazaar awning, yağ çörəyi, Qız Qalası's masonry, the
## cities' walls, roofs, bricks and rock art, plus UI pieces (a carpet-bordered panel, bread and nar icons).
## The recipes follow the web prototype's canvas textures (prototypes/cirtdan/index.html, TEX / canvasTex).
## Needs a renderer (not --headless):
##   godot --path . -s res://tools/art/make_textures.gd            (on a desktop)
##   xvfb-run godot --path . --rendering-driver opengl3 -s res://tools/art/make_textures.gd   (on a server)
extends SceneTree

const OUT := "res://assets/textures/"

var _vp: SubViewport
var _cv: Node2D
var _job: Callable
var _seed := 1


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_vp = SubViewport.new()
	_vp.transparent_bg = true
	_vp.disable_3d = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_cv = Node2D.new()
	_vp.add_child(_cv)
	_cv.draw.connect(func() -> void:
		if _job.is_valid():
			_job.call(_cv))
	await _all()
	quit()


func _all() -> void:
	await _tex("cobble", 256, 256, _cobble)
	await _tex("cobble_grey", 256, 256, _cobble_grey)
	await _tex("wall", 256, 256, _wall)
	await _tex("shebeke", 128, 192, _shebeke)
	await _tex("carpet_red", 256, 384, _carpet.bind(Color("#b3262a"), Color("#1d3f8a"), Color("#e8b23a")))
	await _tex("carpet_blue", 256, 384, _carpet.bind(Color("#1d4f9a"), Color("#9e1f24"), Color("#f0c24b")))
	await _tex("carpet_green", 256, 384, _carpet.bind(Color("#2b7a48"), Color("#8e1d22"), Color("#f2d16b")))
	await _tex("wicker", 128, 64, _wicker)
	await _tex("awning", 128, 64, _awning)
	await _tex("bread", 128, 128, _bread)
	await _tex("tower", 128, 256, _tower)
	await _tex("sheki_wall", 256, 256, _sheki_wall)
	await _tex("sheki_roof", 128, 128, _sheki_roof)
	await _tex("palace", 256, 128, _palace)
	await _tex("brick", 256, 256, _brick)
	await _tex("rock_art", 256, 256, _rock_art)
	await _tex("trail", 256, 256, _trail)
	await _tex("water", 64, 256, _water)
	await _tex("buta_stone", 128, 128, func(g: Node2D) -> void:
		g.draw_rect(Rect2(0, 0, 128, 128), Color("#1f9e9a"))
		_buta(g, Vector2(64, 70), 4.0, 0.4, Color("#f2d16b"), Color("#0d5a58")))
	await _tex("wood", 128, 128, _wood)
	await _tex("hay", 128, 128, _hay)
	await _tex("fur", 128, 128, _fur)
	for v in Catalog.vest_combos():
		await _tex("vest_%s_%s" % [v[0].trim_prefix("#"), v[1].trim_prefix("#")], 128, 128, _vest.bind(Color(v[0]), Color(v[1])))
	# UI
	await _tex("ui_panel", 96, 96, _ui_panel)
	await _tex("ui_button", 64, 64, _ui_button)
	await _tex("icon_bread", 64, 64, func(g: Node2D) -> void:
		_icon_bread(g, Vector2(32, 32), 28.0))
	await _tex("icon_nar", 64, 64, _icon_nar)
	await _tex("icon_buta", 64, 64, func(g: Node2D) -> void:
		g.draw_circle(Vector2(32, 32), 28, Color("#1f9e9a"))
		_buta(g, Vector2(32, 36), 1.9, 0.4, Color("#f2d16b"), Color("#0d5a58")))
	await _tex("icon_stone", 64, 64, func(g: Node2D) -> void:
		g.draw_colored_polygon(PackedVector2Array([Vector2(32, 4), Vector2(52, 30), Vector2(32, 60), Vector2(12, 30)]), Color("#b48ad8"))
		g.draw_colored_polygon(PackedVector2Array([Vector2(32, 4), Vector2(52, 30), Vector2(32, 30)]), Color("#e2ccff"))
		g.draw_polyline(PackedVector2Array([Vector2(32, 4), Vector2(52, 30), Vector2(32, 60), Vector2(12, 30), Vector2(32, 4)]), Color("#5a2a8a"), 3.0))
	await _tex("logo_buta", 256, 256, func(g: Node2D) -> void:
		_buta(g, Vector2(128, 140), 9.0, 0.35, Color("#f2b632"), Color("#8e1d22")))
	# the app icon: a red carpet with a golden buta (full square; Android's adaptive icon in two layers)
	await _tex("app_icon", 512, 512, func(g: Node2D) -> void:
		_icon_back(g, 512.0)
		_buta(g, Vector2(250, 282), 11.5, 0.35, Color("#f2b632"), Color("#5a1d12")))
	await _tex("app_icon_bg", 432, 432, func(g: Node2D) -> void:
		_icon_back(g, 432.0))
	await _tex("app_icon_fg", 432, 432, func(g: Node2D) -> void: # inside the 66% safe circle
		_buta(g, Vector2(216, 236), 9.5, 0.35, Color("#f2b632"), Color("#5a1d12")))


## Renders one texture: draw(canvas) on a w×h transparent canvas, saved as OUT/name.png.
func _tex(name: String, w: int, h: int, draw: Callable) -> void:
	_seed = name.hash() & 0xffff | 1
	_vp.size = Vector2i(w, h)
	_job = draw
	_cv.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := _vp.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("ok ", name)


func _r() -> float: # the web prototype's Park–Miller generator, so patterns match
	_seed = (_seed * 16807) % 2147483647
	return float(_seed) / 2147483647.0


# --- shapes ----------------------------------------------------------------------------------

func _ellipse(g: Node2D, c: Vector2, rx: float, ry: float, rot: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := i * TAU / 20.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	g.draw_colored_polygon(pts, col)


func _rrect(g: Node2D, r: Rect2, rad: float, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(int(rad))
	sb.anti_aliasing = true
	g.draw_style_box(sb, r)


func _diamond(g: Node2D, c: Vector2, rx: float, ry: float, col: Color) -> void:
	g.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -ry), c + Vector2(rx, 0), c + Vector2(0, ry), c + Vector2(-rx, 0)]), col)


## The buta (paisley): the national ornament. s scales the 20-unit design, rot turns it.
func _buta(g: Node2D, at: Vector2, s: float, rot: float, fill: Color, line: Color) -> void:
	var c := Curve2D.new()
	# the web's bezier path: moveTo(0,10) then three cubic curves, closed
	c.add_point(Vector2(0, 10), Vector2.ZERO, Vector2(-9, 9) - Vector2(0, 10))
	c.add_point(Vector2(-4, -7), Vector2(-10, -2) - Vector2(-4, -7), Vector2(1, -11) - Vector2(-4, -7))
	c.add_point(Vector2(7, -15), Vector2(8, -10) - Vector2(7, -15), Vector2(12, -6) - Vector2(7, -15))
	c.add_point(Vector2(0, 10), Vector2(10, 8) - Vector2(0, 10), Vector2.ZERO)
	var pts := PackedVector2Array()
	for p in c.tessellate(5, 3):
		pts.append(at + (p * s).rotated(rot))
	g.draw_colored_polygon(pts, fill)
	pts.append(pts[0])
	g.draw_polyline(pts, line, 1.6 * s, true)
	g.draw_circle(at + (Vector2(0, 1) * s).rotated(rot), 3.0 * s, line)


# --- textures ----------------------------------------------------------------------------------

func _cobble(g: Node2D) -> void:
	_seed = 7
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#8f7a5c"))
	for row in 8:
		for col in 7:
			var x := col * 44 + (row % 2) * 22 - 10 - 22
			var y := row * 32 + 2
			var v := (150 + int(_r() * 50)) / 255.0
			_rrect(g, Rect2(x + 2, y + 2, 40, 28), 9, Color(v + 30 / 255.0, v + 10 / 255.0, v - 30 / 255.0))
			_rrect(g, Rect2(x + 6, y + 4, 26, 9), 5, Color(1, 1, 1, 0.12))
			if x < 0: # wrap the half stones so the texture tiles
				_rrect(g, Rect2(x + 2 + 256, y + 2, 40, 28), 9, Color(v + 30 / 255.0, v + 10 / 255.0, v - 30 / 255.0))


func _cobble_grey(g: Node2D) -> void: # grey granite setts with dark joints: the street the owner asked for
	_seed = 7
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#4a4c50"))
	for row in 8:
		for col in 7:
			var x := col * 44 + (row % 2) * 22 - 10 - 22
			var y := row * 32 + 2
			var v := (118 + int(_r() * 46)) / 255.0
			var c := Color(v, v + 2 / 255.0, v + 6 / 255.0)
			for dx in ([0, 256] if x < 0 else [0]): # wrap the half stones so the texture tiles
				_rrect(g, Rect2(x + 2 + dx, y + 2, 40, 28), 9, c)
				_rrect(g, Rect2(x + 6 + dx, y + 4, 26, 9), 5, Color(1, 1, 1, 0.10))
				_rrect(g, Rect2(x + 4 + dx, y + 22, 36, 6), 3, Color(0, 0, 0, 0.10))


func _wall(g: Node2D) -> void:
	_seed = 3
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#d9a95f"))
	for row in 8:
		for col in 5:
			var x := col * 64 + (row % 2) * 32 - 32
			var y := row * 32
			var v := (_r() * 30 - 15) / 255.0
			g.draw_rect(Rect2(x + 2, y + 2, 60, 28), Color(230 / 255.0 + v, 186 / 255.0 + v, 112 / 255.0 + v))
			g.draw_rect(Rect2(x + 2, y + 22, 60, 8), Color(120 / 255.0, 70 / 255.0, 20 / 255.0, 0.10))


func _shebeke(g: Node2D) -> void:
	var w := 128.0
	var h := 192.0
	g.draw_rect(Rect2(0, 0, w, h), Color("#5a3216"))
	var cols := [Color("#d6362f"), Color("#2c6fd1"), Color("#f0c02f"), Color("#3ea35a")]
	var y := 8
	while y < h - 8:
		var x := 8
		while x < w - 8:
			_diamond(g, Vector2(x + 10, y + 10), 10, 10, cols[int((x + y) / 20) % 4])
			x += 20
		y += 20
	y = 8
	while y < h:
		g.draw_line(Vector2(0, y), Vector2(w, y), Color("#3b1f0c"), 3)
		y += 20
	g.draw_rect(Rect2(4, 4, w - 8, h - 8), Color("#3b1f0c"), false, 8)
	var arch := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, 30)])
	for i in 17: # the web's quadratic curve from (w, 30) over (w/2, -12) to (0, 30)
		var u := i / 16.0
		arch.append(Vector2(w, 30) * (1 - u) * (1 - u) + Vector2(w / 2, -12) * 2 * u * (1 - u) + Vector2(0, 30) * u * u)
	arch.append(Vector2(0, 30))
	g.draw_colored_polygon(arch, Color("#5a3216"))


func _carpet(g: Node2D, field: Color, border: Color, accent: Color) -> void:
	var w := 256.0
	var h := 384.0
	var cream := Color("#f4e2b8")
	g.draw_rect(Rect2(0, 0, w, h), border)
	g.draw_rect(Rect2(w * 0.06, h * 0.06, w * 0.88, h * 0.88), cream)
	g.draw_rect(Rect2(w * 0.1, h * 0.1, w * 0.8, h * 0.8), field)
	var x := w * 0.1
	while x < w * 0.9 - 1:
		g.draw_colored_polygon(PackedVector2Array([Vector2(x, h * 0.1), Vector2(x + w * 0.04, h * 0.15), Vector2(x + w * 0.08, h * 0.1)]), border)
		g.draw_colored_polygon(PackedVector2Array([Vector2(x, h * 0.9), Vector2(x + w * 0.04, h * 0.85), Vector2(x + w * 0.08, h * 0.9)]), border)
		x += w * 0.08
	# small diamonds along the cream band
	var yy := h * 0.08
	while yy < h * 0.92:
		_diamond(g, Vector2(w * 0.08, yy), 3, 5, accent)
		_diamond(g, Vector2(w * 0.92, yy), 3, 5, accent)
		yy += 16
	var c := Vector2(w / 2, h / 2)
	for k in [[0.34, accent], [0.26, cream], [0.19, border], [0.1, accent]]:
		_diamond(g, c, w * k[0] * 0.75, h * k[0], k[1])
	var s := minf(w, h) / 70.0
	for b in [[0.22, 0.24, 0.4], [0.78, 0.24, 2.4], [0.22, 0.76, -0.7], [0.78, 0.76, 3.6]]:
		_buta(g, Vector2(w * b[0], h * b[1]), s, b[2], accent, cream)


func _vest(g: Node2D, base: Color, trim: Color) -> void:
	g.draw_rect(Rect2(0, 0, 128, 128), base)
	g.draw_rect(Rect2(6, 6, 116, 116), trim, false, 6)
	_buta(g, Vector2(40, 64), 2.2, 0.5, trim, Color("#b52b28"))
	_buta(g, Vector2(90, 64), 2.2, -0.5, trim, Color("#b52b28"))


func _wicker(g: Node2D) -> void:
	for y in range(0, 64, 8):
		for x in range(0, 128, 16):
			g.draw_rect(Rect2(x, y, 16, 8), Color("#d29a4c") if (x / 16 + y / 8) % 2 else Color("#8c5c25"))
	for y in range(0, 64, 8):
		g.draw_line(Vector2(0, y), Vector2(128, y), Color(0.3, 0.17, 0.05, 0.5), 1)


func _awning(g: Node2D) -> void:
	for x in range(0, 128, 16):
		g.draw_rect(Rect2(x, 0, 16, 64), Color("#f3ead2") if (x / 16) % 2 else Color("#c8322c"))
	for x in range(0, 128, 16):
		g.draw_colored_polygon(PackedVector2Array([Vector2(x, 54), Vector2(x + 8, 64), Vector2(x + 16, 54)]), Color("#1d4f9a"))


func _bread(g: Node2D) -> void:
	var c := Vector2(64, 64)
	for i in 32: # a radial gradient by rings
		var u := 1.0 - i / 32.0
		var col := Color("#ffd77a").lerp(Color("#e59a2f"), clampf(u / 0.7, 0, 1)) if u < 0.7 else Color("#e59a2f").lerp(Color("#a8601b"), (u - 0.7) / 0.3)
		g.draw_circle(c, 64.0 * u * 1.42, col)
	g.draw_arc(c, 34, 0, TAU, 40, Color("#8d4d12"), 5)
	for i in 8:
		var a := i * PI / 4
		g.draw_line(c + Vector2(cos(a), sin(a)) * 12, c + Vector2(cos(a), sin(a)) * 30, Color("#8d4d12"), 5)
	for i in 14:
		var a := i * 2.4
		var r := 44 + (i % 3) * 5
		g.draw_circle(c + Vector2(cos(a), sin(a)) * r, 2, Color("#4a2a0c"))


func _tower(g: Node2D) -> void:
	for y in range(0, 256, 12):
		g.draw_rect(Rect2(0, y, 128, 12), Color("#bb9058") if (y / 12) % 2 else Color("#d4ad75"))
	for i in 6:
		g.draw_rect(Rect2(20 + (i % 3) * 36, 40 + i * 34, 6, 14), Color("#3a2a1e"))


func _sheki_wall(g: Node2D) -> void:
	_seed = 5
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#efe6d2"))
	for i in 70:
		var col := Color((150 + _r() * 40) / 255.0, (140 + _r() * 30) / 255.0, (120 + _r() * 30) / 255.0, 0.55)
		_ellipse(g, Vector2(_r() * 256, _r() * 256), 6 + _r() * 8, 4 + _r() * 5, _r() * 3, col)
	for y in range(0, 256, 64):
		g.draw_rect(Rect2(0, y, 256, 8), Color("#b8643a"))


func _sheki_roof(g: Node2D) -> void:
	g.draw_rect(Rect2(0, 0, 128, 128), Color("#9e3d22"))
	for y in range(0, 128, 16):
		var x := (y / 16) % 2 * 8 - 8
		while x < 128:
			g.draw_arc(Vector2(x + 8, y + 12), 4, PI, TAU, 10, Color("#c0562f"), 7)
			x += 16


func _palace(g: Node2D) -> void:
	g.draw_rect(Rect2(0, 0, 256, 128), Color("#2c4f9a"))
	var gold := Color("#f2d16b")
	g.draw_rect(Rect2(0, 0, 256, 10), gold)
	g.draw_rect(Rect2(0, 60, 256, 8), gold)
	g.draw_rect(Rect2(0, 118, 256, 10), gold)
	var cols := [Color("#d6362f"), Color("#2c6fd1"), Color("#f0c02f"), Color("#3ea35a")]
	for k in 4:
		for row in 2:
			var x0 := 14 + k * 60
			var y0 := 16 + row * 56
			for y in range(0, 42, 8):
				for x in range(0, 44, 8):
					g.draw_rect(Rect2(x0 + x, y0 + y, 7, 7), cols[(int((x + y) / 8.0) + k) % 4])
			g.draw_rect(Rect2(x0, y0, 44, 42), Color("#5a3216"), false, 3)


func _brick(g: Node2D) -> void:
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#b8643a"))
	for y in range(0, 256, 16):
		var x := (y / 16) % 2 * 16 - 32
		while x < 256:
			g.draw_rect(Rect2(x + 1, y + 1, 30, 14), Color("#c8744a") if (x + y) % 64 else Color("#a8582e"))
			x += 32
	for by in [40, 200]:
		g.draw_rect(Rect2(0, by, 256, 18), Color("#1f9e9a"))
		for x in range(8, 256, 24):
			_diamond(g, Vector2(x + 6, by + 9), 6, 6, Color("#f2d16b"))


func _rock_art(g: Node2D) -> void:
	_seed = 21
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#8a6e52"))
	for i in 50:
		var col := Color((90 + _r() * 40) / 255.0, (70 + _r() * 30) / 255.0, (50 + _r() * 20) / 255.0, 0.5)
		_ellipse(g, Vector2(_r() * 256, _r() * 256), 8 + _r() * 14, 5 + _r() * 9, _r() * 3, col)
	var ink := Color("#3b2a1c")
	for i in 5: # dancers holding hands
		var cx := 30 + i * 45.0
		var cy := 90.0
		g.draw_arc(Vector2(cx, cy - 26), 6, 0, TAU, 16, ink, 4)
		g.draw_line(Vector2(cx, cy - 20), Vector2(cx, cy + 6), ink, 4)
		g.draw_line(Vector2(cx, cy + 6), Vector2(cx - 10, cy + 26), ink, 4)
		g.draw_line(Vector2(cx, cy + 6), Vector2(cx + 10, cy + 26), ink, 4)
		g.draw_line(Vector2(cx - 22, cy - 8), Vector2(cx + 22, cy - 8), ink, 4)
	var boat := PackedVector2Array()
	for i in 17:
		var u := i / 16.0
		boat.append(Vector2(40, 170).lerp(Vector2(128, 210), u).lerp(Vector2(128, 210).lerp(Vector2(216, 170), u), u))
	g.draw_polyline(boat, ink, 4)
	for i in 6:
		g.draw_line(Vector2(70 + i * 22, 182), Vector2(70 + i * 22, 156), ink, 4)
	for seg in [[150, 236, 200, 236], [160, 236, 158, 250], [190, 236, 192, 250], [200, 236, 210, 222], [210, 222, 205, 212], [208, 222, 218, 214]]:
		g.draw_line(Vector2(seg[0], seg[1]), Vector2(seg[2], seg[3]), ink, 4)


func _trail(g: Node2D) -> void:
	_seed = 11
	g.draw_rect(Rect2(0, 0, 256, 256), Color("#8a6a44"))
	for i in 90:
		var col := Color((120 + _r() * 50) / 255.0, (100 + _r() * 40) / 255.0, (70 + _r() * 30) / 255.0, 0.7)
		_ellipse(g, Vector2(_r() * 256, _r() * 256), 3 + _r() * 10, 2 + _r() * 7, _r() * 3, col)
	for i in 40:
		_ellipse(g, Vector2(_r() * 256, _r() * 256), 4, 2, _r() * 3, [Color("#c8722c"), Color("#d9a23a"), Color("#8a3a1c")][i % 3])


func _water(g: Node2D) -> void:
	g.draw_rect(Rect2(0, 0, 64, 256), Color("#9fd0f0"))
	for i in 40:
		g.draw_rect(Rect2((i * 37) % 64, (i * 53) % 256, 3, 30 + (i % 4) * 10), Color(1, 1, 1, 0.8))


func _wood(g: Node2D) -> void: # planks: grain lines and knots
	_seed = 13
	g.draw_rect(Rect2(0, 0, 128, 128), Color("#8a5a2b"))
	for p in 4:
		var x0 := p * 32
		g.draw_rect(Rect2(x0, 0, 32, 128), Color("#8a5a2b").lightened((_r() - 0.5) * 0.15))
		for i in 6:
			var x := x0 + 4 + _r() * 24
			g.draw_line(Vector2(x, 0), Vector2(x + (_r() - 0.5) * 6, 128), Color(0.35, 0.2, 0.08, 0.35), 1.5)
		if _r() < 0.6:
			_ellipse(g, Vector2(x0 + 16, _r() * 128), 4, 6, 0, Color(0.3, 0.17, 0.06, 0.7))
		g.draw_line(Vector2(x0, 0), Vector2(x0, 128), Color(0.25, 0.14, 0.05), 2)


func _hay(g: Node2D) -> void:
	_seed = 17
	g.draw_rect(Rect2(0, 0, 128, 128), Color("#e2bd55"))
	for i in 160:
		var p := Vector2(_r() * 128, _r() * 128)
		var a := (_r() - 0.5) * 0.8
		g.draw_line(p, p + Vector2(cos(a), sin(a)) * (10 + _r() * 14), Color("#c89a3a") if i % 2 else Color("#f4d98a"), 1.5)


func _fur(g: Node2D) -> void: # tufts for the Div
	_seed = 19
	g.draw_rect(Rect2(0, 0, 128, 128), Color("#6f8a3a"))
	for i in 220:
		var p := Vector2(_r() * 128, _r() * 128)
		var a := PI / 2 + (_r() - 0.5) * 0.9
		g.draw_line(p, p + Vector2(cos(a), sin(a)) * (5 + _r() * 7), Color("#556b2b") if i % 3 else Color("#8aa64a"), 2)


func _ui_panel(g: Node2D) -> void: # a carpet-bordered panel for 9-slice (margins 28)
	_rrect(g, Rect2(0, 0, 96, 96), 22, Color("#5a1d12"))
	_rrect(g, Rect2(6, 6, 84, 84), 17, Color("#e8b23a"))
	_rrect(g, Rect2(10, 10, 76, 76), 14, Color("#8e1d22"))
	for i in 4:
		var c: Vector2 = [Vector2(17, 17), Vector2(79, 17), Vector2(17, 79), Vector2(79, 79)][i]
		_diamond(g, c, 5, 5, Color("#f4e2b8"))
	_rrect(g, Rect2(24, 24, 48, 48), 8, Color(0.22, 0.08, 0.04, 0.96))


func _ui_button(g: Node2D) -> void: # a glossy rounded button, white so it can be tinted
	_rrect(g, Rect2(0, 2, 64, 62), 18, Color(0, 0, 0, 0.35))
	_rrect(g, Rect2(0, 0, 64, 60), 18, Color(0.82, 0.82, 0.82))
	_rrect(g, Rect2(2, 2, 60, 54), 16, Color(1, 1, 1))
	_rrect(g, Rect2(6, 4, 52, 20), 10, Color(1, 1, 1, 0.55))


func _icon_back(g: Node2D, s: float) -> void: # a red carpet field with a gold and blue border
	g.draw_rect(Rect2(0, 0, s, s), Color("#1d3f8a"))
	g.draw_rect(Rect2(s * 0.05, s * 0.05, s * 0.9, s * 0.9), Color("#e8b23a"))
	g.draw_rect(Rect2(s * 0.08, s * 0.08, s * 0.84, s * 0.84), Color("#b3262a"))
	_diamond(g, Vector2(s / 2, s / 2), s * 0.34, s * 0.34, Color("#8e1d22"))
	for c in [Vector2(0.18, 0.18), Vector2(0.82, 0.18), Vector2(0.18, 0.82), Vector2(0.82, 0.82)]:
		_diamond(g, c * s, s * 0.04, s * 0.04, Color("#f4e2b8"))


func _icon_bread(g: Node2D, c: Vector2, r: float) -> void:
	g.draw_circle(c + Vector2(0, 3), r, Color("#8d4d12"))
	g.draw_circle(c, r, Color("#e59a2f"))
	g.draw_circle(c + Vector2(-3, -4), r * 0.7, Color("#ffd77a"))
	g.draw_arc(c, r * 0.55, 0, TAU, 24, Color("#a8601b"), 3)
	for i in 6:
		var a := i * TAU / 6
		g.draw_line(c + Vector2(cos(a), sin(a)) * r * 0.2, c + Vector2(cos(a), sin(a)) * r * 0.5, Color("#a8601b"), 3)


func _icon_nar(g: Node2D) -> void:
	var c := Vector2(32, 36)
	g.draw_circle(c, 24, Color("#7a0f1c"))
	g.draw_circle(c + Vector2(-1, -1), 22, Color("#b5162b"))
	_ellipse(g, c + Vector2(-9, -8), 7, 5, -0.5, Color("#e4485a"))
	for i in 5:
		var x := 22 + i * 5.0
		g.draw_colored_polygon(PackedVector2Array([Vector2(x - 3, 16), Vector2(x, 4), Vector2(x + 3, 16)]), Color("#7a0f1c"))
