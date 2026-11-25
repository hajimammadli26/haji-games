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
const RED := Color("#8e1d22")
const BROWN := Color(0.27, 0.1, 0.06, 0.85)
const GOLD := Color("#ffd77a")
const CREAM := Color("#fff4dc")

var prog: Progress
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


func _init(progress: Progress) -> void:
	prog = progress


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.16, 0.05, 0.03, 0.55)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
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
	_list.visible = which != "home"
	_scroll.scroll_vertical = 0
	_refresh()


## A short message at the bottom (secs: how long it stays).
func toast(t: String, secs: float = 2.2) -> void:
	_toast.text = t
	_toast.visible = true
	_toast_t = secs


# --- building --------------------------------------------------------------------------------------

func _build_home() -> void:
	_home = VBoxContainer.new()
	_home.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_home.offset_top = 110
	_home.offset_bottom = -40
	_home.alignment = BoxContainer.ALIGNMENT_CENTER
	_home.add_theme_constant_override("separation", 14)
	add_child(_home)
	var logo := TextureRect.new()
	logo.texture = Kit.texture("logo_buta")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(0, 110)
	_home.add_child(logo)
	var t := UiKit.label(_home, 84, GOLD)
	t.text = "Cırtdan"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var t2 := UiKit.label(_home, 40, CREAM)
	t2.text = "Köhnə Bakıda Qaçış"
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_home_info = UiKit.label(_home, 28, CREAM)
	_home_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_home_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var go := UiKit.button(_home, "Oyna!", GREEN, 56)
	go.custom_minimum_size = Vector2(420, 0)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go.pressed.connect(func() -> void: play.emit())
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	_home.add_child(grid)
	for k in ["shop", "costumes", "chars", "cities", "missions", "leaders"]:
		var b := UiKit.button(grid, SCREENS[k], BROWN, 28)
		b.custom_minimum_size = Vector2(300, 84)
		b.pressed.connect(open.bind(k))
	var st := UiKit.button(_home, SCREENS["settings"], BROWN, 28)
	st.custom_minimum_size = Vector2(300, 72)
	st.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	st.pressed.connect(open.bind("settings"))
	var hint := UiKit.label(_home, 24, CREAM)
	hint.set_meta("lines", ["Sürüşdür: ← → zolaq, ↑ tullan, ↓ sürüş", "İki dəfə toxun: uçan xalça"])
	_hint = hint
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _build_list() -> void:
	_list = VBoxContainer.new()
	_list.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_list.offset_left = 24
	_list.offset_right = -24
	_list.offset_top = 100
	_list.offset_bottom = -24
	_list.add_theme_constant_override("separation", 12)
	add_child(_list)
	var back := UiKit.button(self, "←", BROWN, 40)
	back.position = Vector2(24, 20)
	back.custom_minimum_size = Vector2(90, 70)
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
func _row(title: String, sub: String, btn: String, can: bool, act: Callable, color := GREEN) -> void:
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
	var k := UiKit.button(h, btn, color, 26)
	k.custom_minimum_size = Vector2(170, 76)
	k.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	k.disabled = not can
	k.pressed.connect(act)


## A purchase: the first tap asks "Təsdiq?", the second spends the bread.
func _buy(key: String, price: int, act: Callable) -> Callable:
	return func() -> void:
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
	return "Təsdiq?" if _confirm_key == key else "%d çörək" % price


# --- the screens ---------------------------------------------------------------------------------

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
			_row(p["name"], sub, "", false, Callable())
			continue
		var cost := prog.level_cost(k)
		_row(p["name"], sub, _price_btn("lv_" + k, cost), prog.bread() >= cost, _buy("lv_" + k, cost, func() -> void:
			if prog.buy_level(k):
				toast("%s: səviyyə %d" % [p["name"], prog.level(k)])))
	var t := prog.tune
	_row("Uçan xalça", "Qaçışda bir dəfə: səni bir zərbədən qoruyur · var: %d" % int(prog.save.get_value("carpets")),
		_price_btn("carpet", t.carpet_cost), prog.bread() >= t.carpet_cost, _buy("carpet", t.carpet_cost, func() -> void:
			if prog.buy_carpet():
				toast("Uçan xalça alındı")))
	_row("Xalça ilə uçuş", "Qaçışın əvvəlində bas: uçub irəli get, çörəkləri yığ · var: %d" % int(prog.save.get_value("boosts")),
		_price_btn("boost", t.boost_cost), prog.bread() >= t.boost_cost, _buy("boost", t.boost_cost, func() -> void:
			if prog.buy_boost():
				toast("Xalça ilə uçuş alındı")))
	_row("Nənənin bağlaması", "İçində nə var? Çörək, nar və ya uçan xalça",
		_price_btn("box", t.box_cost), prog.bread() >= t.box_cost, _buy("box", t.box_cost, func() -> void:
			var got := prog.open_box()
			if got != "":
				toast(got)))


func _screen_costumes() -> void:
	_sub.text = "Cırtdanın geyimləri"
	var cost := prog.tune.costume_cost
	var cur := String(prog.save.get_value("costume"))
	for c in Catalog.COSTUMES:
		var id: String = c["id"]
		var own := prog.has_costume(id)
		var btn := "Geyinib" if cur == id else ("Geyin" if own else _price_btn("cos_" + id, cost))
		var can := cur != id and (own or prog.bread() >= cost)
		_row(c["name"], c["desc"], btn, can, _buy("cos_" + id, 0 if own else cost, func() -> void:
			if prog.choose_costume(id):
				toast("Cırtdan: %s" % c["name"])
				look_changed.emit()))


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
		var can := cur != id and (own or prog.bread() >= price)
		_row(c["name"], sub, btn, can, _buy("ch_" + id, 0 if own else price, func() -> void:
			if prog.choose_char(id):
				toast("Personaj: %s" % c["name"])
				look_changed.emit()))


func _screen_cities() -> void:
	_sub.text = "Azərbaycan turu: hər şəhər öz küçəsi ilə"
	var cur := String(prog.save.get_value("city"))
	for c in Catalog.CITIES:
		var id: String = c["id"]
		var own := prog.has_city(id)
		var price: int = c["price"]
		var btn := "Buradasan" if cur == id else ("Get" if own else _price_btn("ci_" + id, price))
		var can := cur != id and (own or prog.bread() >= price)
		_row(c["name"], c["desc"], btn, can, _buy("ci_" + id, 0 if own else price, func() -> void:
			if prog.choose_city(id):
				toast("Şəhər: %s" % c["name"])
				look_changed.emit()))


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
				_refresh(), RED)
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
	_sub.text = "%s · Rekord: %d · onlayn reytinq server tələb edir (sonra)" % [prog.league(best), best]
	var runs: Array = prog.save.get_value("runs")
	if runs.is_empty():
		_row("Hələ qaçış yoxdur", "Oyna və ilk rekordunu qoy!", "", false, Callable())
	for i in runs.size():
		var r: Dictionary = runs[i]
		_row("%d. %d xal" % [i + 1, int(r["score"])], "%d m · %d çörək · %s" % [int(r["m"]), int(r["bread"]), r.get("date", "")],
			"", false, Callable())


func _screen_settings() -> void:
	_sub.text = ""
	for k in [["music", "Musiqi", "Fon musiqisi"], ["sound", "Səs effektləri", "Tullanma, çörək və güclənmə səsləri"]]:
		var key: String = k[0]
		var on := bool(prog.save.get_value(key))
		_row(k[1], k[2], "Açıq" if on else "Bağlı", true, func() -> void:
			prog.toggle(key)
			settings_changed.emit()
			_refresh(), GREEN if on else BROWN)
	var cur := String(prog.save.get_value("lang"))
	for c in Lang.choices():
		var code: String = c[0]
		_row(c[1], "Dil" if code == "az" else "", "Seçilib" if cur == code else "Seç", cur != code, func() -> void:
			prog.set_lang(code)
			_refresh())
	_row("Nağıl", "Cırtdanın hekayəsinə yenidən bax", "Bax", true, func() -> void: story.emit())
