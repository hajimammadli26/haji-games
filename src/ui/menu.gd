## The menus over the street: the home screen (Oyna and the shop buttons) and the list screens —
## Nənənin dükanı, Geyim dükanı, Personajlar, Şəhərlər, Tapşırıqlar, Liderlər, Ayarlar.
## Each list scrolls (phones), each purchase asks twice (Təsdiq?) before it spends bread.
## All rules are in Progress; this only shows them and passes taps on.
## Spec: the web prototype's menus (prototypes/cirtdan/index.html, listScene), design/game-brief.md.
##
## Usage:
##   var menu := Menu.new(progress); layer.add_child(menu)
##   menu.play.connect(_start); menu.look_changed.connect(_apply_look)
##   menu.open("home")   # or "shop", "missions" ...
class_name Menu
extends Control

## Oyna was tapped.
signal play
## The character, costume or city changed (the game redraws Cırtdan and the street).
signal look_changed
## Nağıl was tapped in Ayarlar: show the story again.
signal story
## Music or sound was turned on or off.
signal settings_changed
## A sound to play for a tap: tap, buy or no.
signal sfx(name: String)

const SCREENS := {
	"shop": "Nənənin dükanı", "costumes": "Geyim dükanı", "chars": "Personajlar", "cities": "Şəhərlər",
	"missions": "Tapşırıqlar", "leaders": "Liderlər", "settings": "Ayarlar",
}
const GREEN := Color("#2b7a48")
const RED := Color("#7e2227") ## Madder
const BROWN := Color(0.27, 0.1, 0.06, 0.85)
const GOLD := Color("#ffd77a")
const GOLD_BTN := Color("#c89b45") ## Antique Gold: bright gold belongs to bread (art bible §4)
const CREAM := Color("#fff4dc")
const TURQUOISE := Color("#19b3a6") ## primary action (art bible §4: Power-up Turquoise)
const INK := Color("#2a1e24") ## outlines (art bible §4)

var prog: Progress
var online: Online ## the online board (set by the game; may have no server address yet)
var _board := "mine" ## Liderlər tab: mine, all, week
var _board_data := {} ## scope -> the last top list fetched
var _board_state := {} ## scope -> "loading", "failed" or "ok"
var screen := "home"
var _confirm_key := "" ## the purchase waiting for its second tap
var _confirm_t := 0.0
var _toast_t := 0.0
var _home: Control
var _list: Control
var _title: Label
var _sub: Label
var _rows: VBoxContainer
var _scroll: ScrollContainer
var _wallet: Control
var _wallet_n: Array = [] ## the bread and nar numbers
var _toast: Label
var _home_info: Label
var _hint: Label
var _shade: ColorRect ## dims the street behind the list screens; lighter on home so Cırtdan shows


func _init(progress: Progress) -> void:
	prog = progress


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.16, 0.05, 0.03, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	_shade = shade
	_build_home()
	_build_list()
	_wallet = MarginContainer.new()
	_wallet.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 24)
	_wallet.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_wallet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_wallet)
	_wallet_n = UiKit.counts(_wallet, ["bread", "nar"], 32, GOLD)
	_toast = UiKit.label(self, 34, CREAM)
	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 60)
	_toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_toast.add_theme_stylebox_override("normal", UiKit.carpet(22))
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE, 40)
	_toast.offset_left = 40
	_toast.offset_right = -40
	_toast.visible = false
	open(screen)


func _process(dt: float) -> void:
	if _confirm_t > 0.0:
		_confirm_t -= dt
		if _confirm_t <= 0.0:
			_confirm_key = ""
			_refresh()
	if _toast_t > 0.0:
		_toast_t -= dt
		_toast.visible = _toast_t > 0.0


## Shows a screen: "home" or one of SCREENS.
func open(which: String) -> void:
	if which != screen:
		sfx.emit("tap")
	screen = which
	_confirm_key = ""
	if _home == null:
		return
	_home.visible = which == "home"
	_shade.color.a = 0.15 if which == "home" else 0.55
	_list.visible = which != "home"
	_scroll.scroll_vertical = 0
	_refresh()


## A short message at the bottom (secs: how long it stays).
func toast(t: String, secs: float = 2.2) -> void:
	_toast.text = t
	_toast.visible = true
	_toast_t = secs


# --- building --------------------------------------------------------------------------------------

## Home (art bible §7): a carpet-framed title plate at the top, the shop buttons in two side columns so
## Cırtdan (the 3D character at the screen centre) stays visible between them, the big turquoise Oyna
## button at the bottom with the controls hint on a dark plate under it. Ayarlar sits in the top-left
## corner, where the list screens put their back button.
func _build_home() -> void:
	_home = VBoxContainer.new()
	_home.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_home.offset_left = 24
	_home.offset_right = -24
	_home.offset_top = 124
	_home.offset_bottom = -24
	_home.add_theme_constant_override("separation", 16)
	_home.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_home)
	# the title plate
	var plate := PanelContainer.new()
	plate.add_theme_stylebox_override("panel", UiKit.carpet(22))
	plate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	plate.custom_minimum_size = Vector2(600, 0)
	_home.add_child(plate)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 0)
	plate.add_child(tv)
	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_theme_constant_override("separation", 10)
	tv.add_child(head)
	var logo := TextureRect.new()
	logo.texture = Kit.texture("logo_buta")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(76, 76)
	head.add_child(logo)
	var t := UiKit.label(head, 80, GOLD)
	t.text = "Cırtdan"
	var t2 := UiKit.label(tv, 34, CREAM)
	t2.text = "Köhnə Bakıda Qaçış"
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rule := ColorRect.new() # a thin Antique Gold line between the name and the player's numbers
	rule.color = Color(GOLD_BTN, 0.7)
	rule.custom_minimum_size = Vector2(0, 3)
	tv.add_child(rule)
	_home_info = UiKit.label(tv, 26, CREAM)
	_home_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_home_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# the shop buttons, left and right of Cırtdan
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_home.add_child(mid)
	var keys := ["shop", "costumes", "chars", "cities", "missions", "leaders"]
	for side in 2:
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 18)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mid.add_child(col)
		for i in 3:
			var k: String = keys[side * 3 + i]
			var b := _home_btn(col, SCREENS[k], 26)
			b.custom_minimum_size = Vector2(196, 104)
			b.pressed.connect(open.bind(k))
		if side == 0:
			var gap := Control.new() # Cırtdan stands here
			gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			mid.add_child(gap)
	# Oyna: the one primary action (Turquoise with an Antique Gold rim, art bible §4)
	var go := UiKit.button(_home, "Oyna!", TURQUOISE, 64)
	var sb := _flat(TURQUOISE, GOLD_BTN, 6, 66)
	sb.content_margin_top = 18
	sb.content_margin_bottom = 22
	for st in ["normal", "hover", "focus"]:
		go.add_theme_stylebox_override(st, sb)
	var pr := sb.duplicate() as StyleBoxFlat
	pr.bg_color = TURQUOISE.darkened(0.2)
	pr.shadow_offset = Vector2(0, 2)
	go.add_theme_stylebox_override("pressed", pr)
	go.add_theme_color_override("font_color", Color.WHITE)
	go.add_theme_color_override("font_pressed_color", Color.WHITE)
	go.add_theme_color_override("font_hover_color", Color.WHITE)
	go.add_theme_color_override("font_outline_color", INK)
	go.add_theme_constant_override("outline_size", 14)
	go.custom_minimum_size = Vector2(460, 136)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go.pressed.connect(func() -> void: play.emit())
	# the controls hint, on a dark plate so it reads over the street
	var hp := PanelContainer.new()
	var hsb := UiKit.box(Color(INK, 0.78), 18, 12)
	hsb.border_color = Color(GOLD_BTN, 0.6)
	hsb.set_border_width_all(2)
	hp.add_theme_stylebox_override("panel", hsb)
	hp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_home.add_child(hp)
	var hint := UiKit.label(hp, 26, CREAM)
	hint.set_meta("lines", ["Sürüşdür: ← → zolaq, ↑ tullan, ↓ sürüş", "İki dəfə toxun: uçan xalça"])
	_hint = hint
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(600, 0)
	# Ayarlar, top left
	var st := _home_btn(self, SCREENS["settings"], 26)
	st.custom_minimum_size = Vector2(180, 96)
	st.position = Vector2(24, 16)
	_home.visibility_changed.connect(func() -> void: st.visible = _home.visible)
	st.pressed.connect(open.bind("settings"))


## A secondary home button: a plain Madder plate with a thin Antique Gold line (art bible §7), cream text.
func _home_btn(parent: Control, t: String, size: int) -> Button:
	var b := UiKit.button(parent, t, RED, size)
	var sb := _flat(Color(RED, 0.94), GOLD_BTN, 3, 22)
	for st in ["normal", "hover", "focus"]:
		b.add_theme_stylebox_override(st, sb)
	var pr := sb.duplicate() as StyleBoxFlat
	pr.bg_color = RED.darkened(0.25)
	pr.shadow_offset = Vector2(0, 1)
	b.add_theme_stylebox_override("pressed", pr)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_pressed_color", CREAM)
	b.add_theme_color_override("font_hover_color", CREAM)
	b.add_theme_color_override("font_outline_color", INK)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return b


## A flat rounded box with a rim and a soft Ink drop shadow.
func _flat(bg: Color, rim: Color, rim_w: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = rim
	sb.set_border_width_all(rim_w)
	sb.set_corner_radius_all(radius)
	sb.shadow_color = Color(INK, 0.55)
	sb.shadow_size = 2
	sb.shadow_offset = Vector2(0, 5)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	sb.anti_aliasing = true
	return sb


func _build_list() -> void:
	_list = VBoxContainer.new()
	_list.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_list.offset_left = 24
	_list.offset_right = -24
	_list.offset_top = 110
	_list.offset_bottom = -24
	_list.add_theme_constant_override("separation", 12)
	add_child(_list)
	var back := UiKit.button(self, "←", BROWN, 40)
	back.position = Vector2(24, 20)
	back.custom_minimum_size = Vector2(120, 96)
	back.position = Vector2(16, 8)
	back.pressed.connect(open.bind("home"))
	_list.visibility_changed.connect(func() -> void: back.visible = _list.visible)
	_title = UiKit.label(_list, 50, GOLD)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub = UiKit.label(_list, 24, CREAM)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_list.add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 12)
	_scroll.add_child(_rows)


## One row: a title, a line under it, and a button on the right (or none when btn is "").
func _row(title: String, sub: String, btn: String, can: bool, act: Callable, color := GREEN, icon := "") -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.box(Color(0.22, 0.08, 0.04, 0.82), 18, 16))
	_rows.add_child(panel)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	panel.add_child(h)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	var a := UiKit.label(v, 32, GOLD)
	a.text = title
	a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var b := UiKit.label(v, 22, CREAM)
	b.text = sub
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if btn == "":
		return
	var confirming := btn == "Təsdiq?"
	var k := UiKit.button(h, ("✓ " + tr(btn)) if confirming else btn, GOLD_BTN if confirming else color, 26)
	k.custom_minimum_size = Vector2(190, 96)
	if icon != "" and not confirming:
		k.icon = Kit.texture("icon_" + icon)
		k.add_theme_constant_override("icon_max_width", 34)
	if confirming: # a pulse so a child sees it is waiting for the second tap
		k.pivot_offset = k.custom_minimum_size / 2.0
		var tw := k.create_tween().set_loops()
		tw.tween_property(k, "scale", Vector2(1.06, 1.06), 0.25)
		tw.tween_property(k, "scale", Vector2.ONE, 0.25)
	k.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	k.disabled = not can
	k.pressed.connect(act)


## A purchase: the first tap asks "Təsdiq?", the second spends the bread.
func _buy(key: String, price: int, act: Callable) -> Callable:
	return func() -> void:
		if price > prog.bread():
			_confirm_key = ""
			sfx.emit("no")
			toast(tr("Yağ çörəyi çatmır: %d lazımdır, səndə %d" % [price, prog.bread()]))
			return
		if price >= prog.tune.confirm_from and _confirm_key != key:
			_confirm_key = key
			_confirm_t = 2.5
			sfx.emit("tap")
			_refresh()
			return
		_confirm_key = ""
		var before := prog.bread()
		act.call()
		sfx.emit("buy" if prog.bread() < before or price == 0 else "no")
		_refresh()


func _price_btn(key: String, price: int) -> String:
	return "Təsdiq?" if _confirm_key == key else str(price)


# --- the screens ---------------------------------------------------------------------------------

## Redraws the shown screen (the wallet, the lists) after something changed outside the menu.
func refresh() -> void:
	_refresh()


func _refresh() -> void:
	if _rows == null:
		return
	_wallet_n[0].text = str(prog.bread())
	_wallet_n[1].text = str(int(prog.save.get_value("nar")))
	var md := 0
	for m in prog.missions():
		if m["done"]:
			md += 1
	_home_info.text = tr("Rekord: %d · %s" % [int(prog.save.get_value("best")), prog.league(int(prog.save.get_value("best")))]) \
		+ "\n" + tr("Tapşırıqlar: %d/3 bitib · vurğu x%d" % [md, int(prog.save.get_value("mmult"))])
	_hint.text = "\n".join((_hint.get_meta("lines") as Array).map(func(x): return tr(x)))
	if screen == "home":
		return
	for c in _rows.get_children():
		c.queue_free()
	_title.text = SCREENS[screen]
	call("_screen_" + screen)


func _screen_shop() -> void:
	_sub.text = "Səviyyə artdıqca güclənmə daha uzun sürür"
	var mx := prog.tune.max_level
	for p in Catalog.POWERS:
		var k: String = p["id"]
		var lv := prog.level(k)
		var marks := "●".repeat(lv) + "○".repeat(mx - lv)
		var sub := "%s\n%s  %s" % [tr(p["what"]), marks, tr("səviyyə %d/%d" % [lv, mx])]
		if lv >= mx:
			_row(p["name"], sub, "Tam ✓", false, Callable(), GOLD_BTN)
			continue
		var cost := prog.level_cost(k)
		_row(p["name"], sub, _price_btn("lv_" + k, cost), true, _buy("lv_" + k, cost, func() -> void:
			if prog.buy_level(k):
				toast("%s: səviyyə %d" % [p["name"], prog.level(k)])), GREEN, "bread")
	var t := prog.tune
	_row("Uçan xalça", "Qaçışda bir dəfə: səni bir zərbədən qoruyur · var: %d" % int(prog.save.get_value("carpets")),
		_price_btn("carpet", t.carpet_cost), true, _buy("carpet", t.carpet_cost, func() -> void:
			if prog.buy_carpet():
				toast("Uçan xalça alındı")), GREEN, "bread")
	_row("Xalça ilə uçuş", "Qaçışın əvvəlində bas: uçub irəli get, çörəkləri yığ · var: %d" % int(prog.save.get_value("boosts")),
		_price_btn("boost", t.boost_cost), true, _buy("boost", t.boost_cost, func() -> void:
			if prog.buy_boost():
				toast("Xalça ilə uçuş alındı")), GREEN, "bread")
	_row("Nənənin bağlaması", "İçində nə var? Çörək, nar və ya uçan xalça",
		_price_btn("box", t.box_cost), true, _buy("box", t.box_cost, func() -> void:
			var got := prog.open_box()
			if got != "":
				toast(got)), GREEN, "bread")


func _screen_costumes() -> void:
	_sub.text = "Cırtdanın geyimləri · geyinəndə Cırtdan seçilir"
	var cost := prog.tune.costume_cost
	var cur := String(prog.save.get_value("costume")) if String(prog.save.get_value("char")) == "cirtdan" else ""
	for c in Catalog.COSTUMES:
		var id: String = c["id"]
		var own := prog.has_costume(id)
		var btn := "Geyinib" if cur == id else ("Geyin" if own else _price_btn("cos_" + id, cost))
		_row(c["name"], c["desc"], btn, cur != id, _buy("cos_" + id, 0 if own else cost, func() -> void:
			if prog.choose_costume(id):
				toast("Cırtdan: %s" % c["name"])
				look_changed.emit()), GREEN, "" if own else "bread")


func _screen_chars() -> void:
	_sub.text = "Personaj seç"
	var cur := String(prog.save.get_value("char"))
	for c in Catalog.CHARS:
		var id: String = c["id"]
		var own := prog.has_char(id)
		var price: int = c["price"]
		var sub: String = tr(c["desc"])
		if c.get("stones", false) and not own:
			sub += " · " + tr("pulsuz: sehrli daşlar %d/%d" % [mini(prog.get_int("stones"), prog.tune.peri_stones), prog.tune.peri_stones])
		if c.get("hunt", false) and not own:
			var h := prog.hunt()
			sub += " · " + tr("pulsuz: həftəlik ov, buta daşları %d/%d" % [mini(h["got"], h["need"]), h["need"]])
		if c.get("claims", false) and not own:
			sub += " · " + tr("pulsuz: %d/%d tapşırıq" % [mini(int(prog.save.get_value("claims")), prog.tune.kecel_claims), prog.tune.kecel_claims])
		var btn := "Seçilib" if cur == id else ("Seç" if own else _price_btn("ch_" + id, price))
		_row(c["name"], sub, btn, cur != id, _buy("ch_" + id, 0 if own else price, func() -> void:
			if prog.choose_char(id):
				toast("Personaj: %s" % c["name"])
				look_changed.emit()), GREEN, "" if own else "bread")


func _screen_cities() -> void:
	_sub.text = "Azərbaycan turu: hər şəhər öz küçəsi ilə"
	var cur := String(prog.save.get_value("city"))
	for c in Catalog.CITIES:
		var id: String = c["id"]
		var own := prog.has_city(id)
		var price: int = c["price"]
		var btn := "Buradasan" if cur == id else ("Get" if own else _price_btn("ci_" + id, price))
		_row(c["name"], c["desc"], btn, cur != id, _buy("ci_" + id, 0 if own else price, func() -> void:
			if prog.choose_city(id):
				toast("Şəhər: %s" % c["name"])
				look_changed.emit()), GREEN, "" if own else "bread")


func _screen_missions() -> void:
	_sub.text = "Bitən tapşırığa bas, çörəyi al · hər 3 tapşırıq: vurğu +1 (indi x%d)" % int(prog.save.get_value("mmult"))
	var ms := prog.missions()
	for i in ms.size():
		var m: Dictionary = ms[i]
		var p := "%d/%d" % [int(m["prog"]), int(m["target"])]
		if m["done"]:
			_row(m["txt"], "Bitdi! %s" % p, "+%d" % m["reward"], true, func() -> void:
				var got := prog.claim(i)
				sfx.emit("buy")
				toast("+%d çörək! Yeni tapşırıq" % got)
				_refresh(), RED, "bread")
		else:
			_row(m["txt"], "%s · mükafat %d çörək" % [p, m["reward"]], "", false, Callable())
	var dw := prog.day_word()
	var w: String = dw["word"]
	var shown := ""
	for i in w.length():
		shown += (w[i] if i < dw["got"] else "_") + " "
	_row("Günün sözü: %s" % shown.strip_edges(), "Hərfləri küçədə sırayla tap · hər gün ilk söz: ardıcıl günlər üçün daha çox hədiyyə (seriya %d)" % int(prog.get_int("wordStreak")), "", false, Callable())
	var h := prog.hunt()
	_row("Həftəlik ov: buta daşlarını tap", ("%d / %d · %s" % [mini(h["got"], h["need"]), h["need"],
		tr("mükafat: %s" % tr("3 bağlama və %d çörək" % prog.tune.hunt_bread if prog.has_char("melik") else "Məlikməmməd"))]) if h["open"] else "Bu həftənin ovu bitdi! Gələn həftə yenisi",
		"", false, Callable())
	_row("Sehrli daşlar: %d" % prog.get_int("stones"), "%d daş Pəri qızı açır" % prog.tune.peri_stones, "", false, Callable())


func _screen_leaders() -> void:
	var best := int(prog.save.get_value("best"))
	_sub.text = "%s · Rekord: %d" % [prog.league(best), best]
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 8)
	_rows.add_child(tabs)
	for b in [["mine", "Mənim"], ["all", "Hamı"], ["week", "Bu həftə"]]:
		var k := UiKit.button(tabs, b[1], GOLD_BTN if _board == b[0] else BROWN, 26)
		k.custom_minimum_size = Vector2(150, 80)
		var scope: String = b[0]
		k.pressed.connect(func() -> void:
			_board = scope
			if scope != "mine":
				_load_board(scope)
			sfx.emit("tap")
			_refresh())
	if _board == "mine":
		var runs: Array = prog.save.get_value("runs")
		if runs.is_empty():
			_row("Hələ qaçış yoxdur", "Oyna və ilk rekordunu qoy!", "", false, Callable())
		for i in runs.size():
			var r: Dictionary = runs[i]
			_row("%d. %d xal" % [i + 1, int(r["score"])], "%d m · %d çörək · %s" % [int(r["m"]), int(r["bread"]), r.get("date", "")],
				"", false, Callable())
		return
	_nick_rows()
	if not bool(prog.save.get_value("online")):
		_row("Onlayn liderlər bağlıdır", "Ayarlardan aça bilərsən", "", false, Callable())
		return
	if online == null or not online.enabled():
		_row("Onlayn liderlər tezliklə", "Server qoşulanda burada hamının rekordları görünəcək", "", false, Callable())
		return
	var state := String(_board_state.get(_board, ""))
	if state == "loading" or state == "":
		_row("Yüklənir…", "", "", false, Callable())
		if state == "":
			_load_board(_board)
		return
	if state == "failed":
		_row("İnternet yoxdur", "Bir az sonra yenə yoxla", "Yenə", true, func() -> void:
			_load_board(_board)
			_refresh())
		return
	var data: Dictionary = _board_data.get(_board, {})
	var rows: Array = data.get("rows", [])
	if rows.is_empty():
		_row("Hələ heç kim yoxdur", "İlk sən ol!", "", false, Callable())
	for r in rows:
		_row(("%d. %s (sən)" if r.get("you", false) else "%d. %s") % [int(r["rank"]), r["nick"]], "%d xal · %d m" % [int(r["score"]), int(r["metres"])], "", false, Callable())
	var mine: Variant = data.get("me")
	if mine is Dictionary and int(mine.get("rank", 0)) > rows.size():
		_row("Sənin yerin: %d" % int(mine["rank"]), "%d xal" % int(mine["score"]), "", false, Callable())


## The nickname shown on the online board, chosen from fixed words (never typed).
func _nick_rows() -> void:
	var n := prog.nick()
	var na := Catalog.NICK_ADJ.size()
	var nh := Catalog.NICK_HERO.size()
	var a := n / nh if n >= 0 else 0
	var h := n % nh if n >= 0 else 0
	var line := HBoxContainer.new()
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_theme_constant_override("separation", 8)
	_rows.add_child(line)
	var cap := UiKit.label(line, 28, GOLD)
	cap.text = "Ləqəbin: %s" % Catalog.nick_name(a * nh + h) if n >= 0 else "Ləqəb seç"
	for part in [["adj", na], ["hero", nh]]:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 10)
		_rows.add_child(row)
		var is_adj: bool = part[0] == "adj"
		for step in [-1, 1]:
			var b := UiKit.button(row, "◀" if step < 0 else "▶", BROWN, 30)
			b.custom_minimum_size = Vector2(96, 80)
			b.pressed.connect(func() -> void:
				if is_adj:
					prog.set_nick(a + step, h)
				else:
					prog.set_nick(a, h + step)
				sfx.emit("tap")
				_refresh())
			if step < 0:
				var w := UiKit.label(row, 30, CREAM)
				w.text = Catalog.NICK_ADJ[a] if is_adj else Catalog.NICK_HERO[h]
				w.custom_minimum_size = Vector2(220, 0)
				w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _load_board(scope: String) -> void:
	if online == null or not online.enabled():
		return
	_board_state[scope] = "loading"
	online.fetch_top(scope, prog.player_id())


## The game's Online answered: show the list (or that it failed).
func board_loaded(scope: String, data: Dictionary) -> void:
	_board_data[scope] = data
	_board_state[scope] = "ok"
	if screen == "leaders":
		_refresh()


## The top list could not be fetched.
func board_failed(scope: String) -> void:
	_board_state[scope] = "failed"
	if screen == "leaders":
		_refresh()


func _screen_settings() -> void:
	_sub.text = ""
	for k in [["music", "Musiqi", "Fon musiqisi"], ["sound", "Səs effektləri", "Tullanma, çörək və güclənmə səsləri"]]:
		var key: String = k[0]
		var on := bool(prog.save.get_value(key))
		_row(k[1], k[2], "Açıq" if on else "Bağlı", true, func() -> void:
			prog.toggle(key)
			settings_changed.emit()
			_refresh(), GREEN if on else BROWN)
	var ol := bool(prog.save.get_value("online"))
	_row("Onlayn liderlər", "Ancaq ləqəb və xal göndərilir, ad yox", "Açıq" if ol else "Bağlı", true, func() -> void:
		prog.toggle("online")
		_refresh(), GREEN if ol else BROWN)
	var cur := String(prog.save.get_value("lang"))
	var head := UiKit.label(_rows, 34, GOLD)
	head.text = "Dil"
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for c in Lang.choices():
		var code: String = c[0]
		_row(c[1], "", "Seçilib" if cur == code else "Seç", cur != code, func() -> void:
			prog.set_lang(code)
			_refresh())
	_row("Nağıl", "Cırtdanın hekayəsinə yenidən bax", "Bax", true, func() -> void: story.emit())
