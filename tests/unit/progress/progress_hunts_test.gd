## The day's word, the weekly buta hunt, magic stones and Nənə's gifts. Days are fixed, so tests do not
## depend on the clock. Spec: design/game-brief.md, src/core/progress.gd.
extends GdUnitTestSuite

const DAY := 100

var tune: Tuning
var save: SaveData
var prog: Progress


func before_test() -> void:
	tune = load("res://src/data/tuning.tres")
	save = SaveData.new("", tune.start_nar)
	prog = Progress.new(save, tune, 3)
	prog.day_override = DAY


func _spell() -> Dictionary:
	var w: String = prog.day_word()["word"]
	var r := {}
	for i in w.length():
		r = prog.take_letter()
	return r


func test_day_word_comes_from_the_day() -> void:
	assert_str(String(prog.day_word()["word"])).is_equal(Catalog.WORDS[DAY % Catalog.WORDS.size()])


func test_spelling_gives_gift_and_moves_to_next_word() -> void:
	var w: String = prog.day_word()["word"]
	var r := _spell()
	assert_int((r["gifts"] as Array).size()).is_equal(1)
	assert_str(String(prog.day_word()["word"])).is_not_equal(w)
	assert_int(int(prog.day_word()["got"])).is_equal(0)


func test_streak_of_days_gives_more_gifts() -> void:
	_spell()
	prog.day_override = DAY + 1
	assert_int((_spell()["gifts"] as Array).size()).is_equal(2)


func test_daily_gift_once_a_day() -> void:
	assert_str(prog.daily_gift()).is_not_empty()
	assert_str(prog.daily_gift()).is_empty()


func test_weekly_hunt_opens_melikmammad_then_closes() -> void:
	var msg := ""
	for i in tune.hunt_target:
		msg = prog.take_buta()
	assert_str(msg).contains("Məlikməmməd")
	assert_bool(prog.has_char("melik")).is_true()
	assert_bool(prog.hunt()["open"]).is_false()
	assert_str(prog.take_buta()).is_empty()


func test_magic_stones_open_peri_on_the_last_one() -> void:
	for i in tune.peri_stones - 1:
		assert_str(prog.take_stone()).is_empty()
	assert_str(prog.take_stone()).is_not_empty()
