## The save file on disk: written safely, and a damaged file falls back to the last good copy.
## Integration (real files in user://); cleans up after itself. Spec: src/core/save_data.gd.
extends GdUnitTestSuite

const PATH := "user://test_save_file.json"


func _clean() -> void:
	for ext in ["", ".bak", ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH + ext))


func before_test() -> void:
	_clean()


func after_test() -> void:
	_clean()


func test_value_survives_reload() -> void:
	SaveData.new(PATH).set_value("bread", 250)
	assert_int(int(SaveData.new(PATH).get_value("bread"))).is_equal(250)


func test_missing_keys_get_defaults() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string('{"bread": 7}')
	f.close()
	var s := SaveData.new(PATH)
	assert_int(int(s.get_value("bread"))).is_equal(7)
	assert_str(String(s.get_value("city"))).is_equal("baku")


# Regression (UI playtest): a damaged save silently reset all progress.
func test_damaged_save_loads_last_good_copy() -> void:
	var s := SaveData.new(PATH)
	s.set_value("bread", 100)
	s.set_value("bread", 250)
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string("{broken")
	f.close()
	assert_int(int(SaveData.new(PATH).get_value("bread"))).is_equal(100)
