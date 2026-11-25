## The game's languages: Azerbaijani is the source; Turkish, English and Russian come from src/data/lang.json
## (the same table as the web prototype) and src/data/lang_godot.json (texts only the Godot version has). Registered with Godot's TranslationServer, so every Label, Button
## and Label3D is translated as it is drawn, with no tr() calls in the game code.
## A key may hold {name} placeholders: "Xalça x{n}" also translates "Xalça x3", the filled-in part
## translated too when it is itself a key (a name, a gift list).
##
## Usage:
##   Lang.install("en")        # at start, and again when the player picks another language
##   Lang.text("Davam", "ru")  # one string, for checks
class_name Lang
extends Translation

const PATH := "res://src/data/lang.json"
const EXTRA_PATH := "res://src/data/lang_godot.json"

static var _active: Lang
var table := {} ## Azerbaijani text -> {tr, en, ru}
var names := {} ## language code -> its own name
var langs: Array = []
var _patterns: Array = [] ## [{re, names, key}], most specific first
var _cache := {}


## Loads the table; lang is the language this Translation answers for.
func _init(lang: String = "en") -> void:
	locale = lang
	var f := FileAccess.open(PATH, FileAccess.READ)
	var d: Dictionary = JSON.parse_string(f.get_as_text())
	table = d["t"]
	var extra: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXTRA_PATH)) # keys of the Godot version
	if extra is Dictionary:
		table.merge(extra)
	names = d["names"]
	langs = d["langs"]
	for k in table:
		if not "{" in k:
			continue
		var parts := []
		var re := "^"
		var lit := 0
		var rx := RegEx.create_from_string("\\{(\\w+)\\}")
		var at := 0
		for m in rx.search_all(k):
			var piece: String = k.substr(at, m.get_start() - at)
			re += _escape(piece)
			lit += piece.length()
			re += "(.+?)"
			parts.append(m.get_string(1))
			at = m.get_end()
		re += _escape(k.substr(at)) + "$"
		lit += k.length() - at
		_patterns.append({"re": RegEx.create_from_string(re), "names": parts, "key": k, "lit": lit})
	_patterns.sort_custom(func(a, b): return a["lit"] > b["lit"])


static func _escape(s: String) -> String:
	var out := ""
	for c in s:
		out += ("\\" + c) if c in ".*+?^${}()|[]\\/" else c
	return out


## Makes lang the game's language ("az" turns translation off).
static func install(lang: String) -> void:
	if _active != null:
		TranslationServer.remove_translation(_active)
		_active = null
	if lang != "az":
		_active = Lang.new(lang)
		TranslationServer.add_translation(_active)
	TranslationServer.set_locale(lang)


## The language names, in menu order: [[code, name], ...].
static func choices() -> Array:
	var l := Lang.new()
	var out := []
	for c in l.langs:
		out.append([c, l.names[c]])
	return out


## One string in lang.
func text(s: String, lang: String = "") -> String:
	if lang == "":
		lang = locale
	if lang == "az" or s == "":
		return s
	var key := lang + "\u0001" + s
	if _cache.has(key):
		return _cache[key]
	var out := s
	if table.has(s) and (table[s] as Dictionary).has(lang):
		out = table[s][lang]
	else:
		for p in _patterns:
			var m: RegExMatch = p["re"].search(s)
			if m == null or not (table[p["key"]] as Dictionary).has(lang):
				continue
			out = table[p["key"]][lang]
			for i in (p["names"] as Array).size():
				out = out.replace("{" + p["names"][i] + "}", _part(m.get_string(i + 1), lang))
			break
	_cache[key] = out
	return out


func _part(v: String, lang: String) -> String:
	if table.has(v) and (table[v] as Dictionary).has(lang):
		return table[v][lang]
	if ", " in v:
		var bits := []
		for x in v.split(", "):
			bits.append(text(x, lang))
		return ", ".join(bits)
	return text(v, lang)


func _get_message(src_message: StringName, _context: StringName) -> StringName:
	var out := text(String(src_message))
	return StringName(out) if out != String(src_message) else StringName()


func _get_plural_message(src_message: StringName, _src_plural: StringName, _n: int, context: StringName) -> StringName:
	return _get_message(src_message, context)
