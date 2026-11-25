## What the player keeps between runs: bread, nar, best score, shop levels, carpets and boosts bought,
## characters, costumes, cities, missions, settings. One JSON file in user:// (the phone's app storage).
## Keys match the web prototype's save, so the same names mean the same things.
##
## Usage:
##   var save := SaveData.new()            # loads user://cirtdan_save.json, or starts fresh
##   save.set_value("bread", save.get_value("bread") + 12)   # written at once
##   save.put("mprog", [1, 0, 0]); save.flush()               # many small changes, one write
class_name SaveData
extends RefCounted

const PATH := "user://cirtdan_save.json"

var _d := {}
var _path := PATH


## Loads the save at path, filling any key an older save lacks. An empty path keeps everything in memory
## (tests: no files).
func _init(path: String = PATH, start_nar: int = 2) -> void:
	_path = path
	_d = _defaults(start_nar)
	if _path == "":
		return
	var parsed: Variant = _read(_path)
	if not parsed is Dictionary: # damaged or missing: the last good copy
		parsed = _read(_path + ".bak")
	if parsed is Dictionary:
		for k in parsed:
			_d[k] = parsed[k]


func _read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	return JSON.parse_string(f.get_as_text())


func _defaults(start_nar: int) -> Dictionary:
	return {
		"best": 0, "bread": 0, "nar": start_nar, "carpets": 0, "boosts": 0, "levels": {},
		"chars": ["cirtdan"], "char": "cirtdan", "costume": "none", "costumes": [],
		"cities": ["baku"], "city": "baku", "mprog": [0, 0, 0], "mmult": 1, "claims": 0,
		"music": true, "sound": true, "lang": "az", "story": false, "runs": [],
		"stones": 0, "wordN": 0, "wordGot": 0, "wordStreak": 0, "huntGot": 0,
		"player": "", "nick": -1, "online": true, "sent_best": 0,
	}


## The value of a key (null if it was never set).
func get_value(key: String) -> Variant:
	return _d.get(key)


## Sets a key and writes the file.
func set_value(key: String, value: Variant) -> void:
	_d[key] = value
	flush()


## Sets a key in memory only; flush() writes it (for values that change every step).
func put(key: String, value: Variant) -> void:
	_d[key] = value


## Writes everything safely: to a temporary file first, then swapped in, the old one kept as .bak,
## so a crash or a full disk mid-write never loses the player's progress. False if it could not be written.
func flush() -> bool:
	if _path == "":
		return true
	var tmp := _path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(_d))
	f.close()
	if not _read(tmp) is Dictionary:
		return false
	var dir := DirAccess.open(_path.get_base_dir())
	if dir == null:
		return false
	if FileAccess.file_exists(_path):
		if FileAccess.file_exists(_path + ".bak"):
			dir.remove(_path.get_file() + ".bak")
		dir.rename(_path.get_file(), _path.get_file() + ".bak")
	return dir.rename(tmp.get_file(), _path.get_file()) == OK
