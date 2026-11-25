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
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, sb)
	var dis := sb.duplicate()
	dis.bg_color = Color(color, 0.4)
	b.add_theme_stylebox_override("disabled", dis)
	b.focus_mode = Control.FOCUS_NONE
	parent.add_child(b)
	return b


## A rounded panel background.
static func box(color: Color, radius: int = 18, margin: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = margin
	sb.content_margin_right = margin
	sb.content_margin_top = margin
	sb.content_margin_bottom = margin
	return sb
