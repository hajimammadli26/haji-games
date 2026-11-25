## Nənənin dükanı, Geyim dükanı, characters and cities: prices, unlocks, what a purchase changes.
## Spec: design/game-brief.md (shops), src/core/progress.gd.
extends GdUnitTestSuite

const START_BREAD := 5000

var tune: Tuning
var save: SaveData
var prog: Progress


func before_test() -> void:
	tune = load("res://src/data/tuning.tres")
	save = SaveData.new("", tune.start_nar) # in memory
	prog = Progress.new(save, tune, 1)


func test_buy_level_without_bread_spends_nothing() -> void:
	assert_bool(prog.buy_level("magnet")).is_false()
	assert_int(prog.level("magnet")).is_equal(0)


func test_buy_level_spends_and_raises_level() -> void:
	save.set_value("bread", START_BREAD)
	assert_bool(prog.buy_level("magnet")).is_true()
	assert_int(prog.level("magnet")).is_equal(1)
	assert_int(prog.bread()).is_equal(START_BREAD - tune.upgrade_cost)


func test_level_cost_doubles_each_level() -> void:
	save.set_value("bread", 100000)
	var first := prog.level_cost("shoe")
	prog.buy_level("shoe")
	assert_int(prog.level_cost("shoe")).is_equal(first * 2)


func test_level_stops_at_max_level() -> void:
	save.set_value("bread", 1000000)
	for i in tune.max_level + 2:
		prog.buy_level("pole")
	assert_int(prog.level("pole")).is_equal(tune.max_level)


func test_city_bought_once_then_free_to_return() -> void:
	save.set_value("bread", START_BREAD)
	var price: int = Catalog.find(Catalog.CITIES, "sheki")["price"]
	assert_bool(prog.choose_city("sheki")).is_true()
	prog.choose_city("baku")
	assert_bool(prog.choose_city("sheki")).is_true()
	assert_int(prog.bread()).is_equal(START_BREAD - price)


func test_character_too_dear_stays_locked() -> void:
	save.set_value("bread", 100)
	assert_bool(prog.choose_char("melik")).is_false()
	assert_str(String(save.get_value("char"))).is_equal("cirtdan")


func test_kecel_free_after_enough_claims() -> void:
	save.put("claims", tune.kecel_claims)
	assert_bool(prog.has_char("kecel")).is_true()


func test_peri_free_with_enough_magic_stones() -> void:
	save.put("stones", tune.peri_stones - 1)
	assert_bool(prog.has_char("peri")).is_false()
	save.put("stones", tune.peri_stones)
	assert_bool(prog.has_char("peri")).is_true()


# Regression (UI playtest): a costume bought while another character ran changed nothing on screen.
func test_choose_costume_makes_cirtdan_the_runner() -> void:
	save.set_value("bread", START_BREAD)
	save.put("chars", ["cirtdan", "tiqtiq"])
	prog.choose_char("tiqtiq")
	assert_bool(prog.choose_costume("winter")).is_true()
	assert_str(String(save.get_value("char"))).is_equal("cirtdan")
	assert_str(String(prog.look()["hat"])).is_equal("winter")


func test_cirtdan_look_ignores_selected_character() -> void:
	save.put("chars", ["cirtdan", "kecel"])
	save.put("char", "kecel")
	assert_str(String(prog.cirtdan_look()["hat"])).is_equal("papaq")


func test_open_box_without_bread_gives_nothing() -> void:
	assert_str(prog.open_box()).is_equal("")
