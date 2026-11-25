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


## Loads the save at path (tests pass their own), filling any key an older save lacks.
func _init(path: String = PATH, start_nar: int = 2) -> void:
	_path = path
	_d = _defaults(start_nar)
	if FileAccess.file_exists(_path):
		var f := FileAccess.open(_path, FileAccess.READ)
		if f != null:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				for k in parsed:
					_d[k] = parsed[k]


func _defaults(start_nar: int) -> Dictionary:
	return {
		"best": 0, "bread": 0, "nar": start_nar, "carpets": 0, "boosts": 0, "levels": {},
		"chars": ["cirtdan"], "char": "cirtdan", "costume": "none", "costumes": [],
		"cities": ["baku"], "city": "baku", "mprog": [0, 0, 0], "mmult": 1, "claims": 0,
		"music": true, "sound": true, "lang": "az", "story": false, "runs": [],
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


## Writes everything to the file. Returns false if the file could not be written.
func flush() -> bool:
	var f := FileAccess.open(_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(_d))
	return true
