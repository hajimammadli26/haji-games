## Shared looks for the game's labels and buttons (warm outlined text, rounded buttons), so the HUD and the
## menus match. The design stage swaps these for a real theme.
##
## Usage:
##   var l := UiKit.label(parent, 40, Color("#ffd77a")); l.text = "Salam"
##   var b := UiKit.button(parent, "Oyna", Color("#2b7a48"), 44)
class_name UiKit
extends RefCounted

const OUTLINE := Color("#3c140a")


## An outlined label added to parent.
static func label(parent: Control, size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", maxi(6, size / 4))
	parent.add_child(l)
	return l


## A rounded button added to parent; disabled buttons fade.
static func button(parent: Control, t: String, color: Color, size: int = 34) -> Button:
	var b := Button.new()
	b.text = t
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_outline_color", OUTLINE)
	b.add_theme_constant_override("outline_size", maxi(4, size / 6))
	var sb := _tex_box("ui_button", 18, color)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 12
	sb.content_margin_bottom = 16
	for st in ["normal", "hover", "focus"]:
		b.add_theme_stylebox_override(st, sb)
	var pr := sb.duplicate()
	pr.modulate_color = color.darkened(0.2)
	pr.content_margin_top = 15
	pr.content_margin_bottom = 13
	b.add_theme_stylebox_override("pressed", pr)
	var dis := sb.duplicate()
	dis.modulate_color = Color(color, 0.4)
	b.add_theme_stylebox_override("disabled", dis)
	b.focus_mode = Control.FOCUS_NONE
	parent.add_child(b)
	return b


static func _tex_box(name: String, margin: int, tint := Color.WHITE) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = Kit.texture(name)
	sb.texture_margin_left = margin
	sb.texture_margin_right = margin
	sb.texture_margin_top = margin
	sb.texture_margin_bottom = margin
	sb.modulate_color = tint
	return sb


## A carpet-bordered panel (gold and red frame, buta corners) for dialogs and captions.
static func carpet(margin: int = 26) -> StyleBoxTexture:
	var sb := _tex_box("ui_panel", 28)
	sb.content_margin_left = margin
	sb.content_margin_right = margin
	sb.content_margin_top = margin
	sb.content_margin_bottom = margin
	return sb


## A small icon (bread, nar, buta, stone) of size px.
static func icon(parent: Control, name: String, px: int) -> TextureRect:
	var r := TextureRect.new()
	r.texture = Kit.texture("icon_" + name)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(px, px)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


## A row of [icon, number] pairs (a wallet): returns the number labels in order.
static func counts(parent: Control, names: Array, size: int, color: Color) -> Array:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(h)
	var out := []
	for n in names:
		icon(h, n, size + 6)
		var l := label(h, size, color)
		l.custom_minimum_size.x = size * 1.2
		out.append(l)
	return out


## A rounded panel background.
static func box(color: Color, radius: int = 18, margin: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.border_color = Color(0.91, 0.7, 0.23, 0.55)
	sb.set_border_width_all(2 if color.a > 0.7 and radius >= 16 else 0)
	sb.content_margin_left = margin
	sb.content_margin_right = margin
	sb.content_margin_top = margin
	sb.content_margin_bottom = margin
	return sb
