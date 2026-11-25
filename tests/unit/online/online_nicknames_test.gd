## The online board's rules on the device: nicknames from fixed lists only (the same as the server's),
## a stable random player id, and when a score is sent. Spec: server/leaderboard/worker.js, src/core/progress.gd.
extends GdUnitTestSuite

const WORKER := "res://server/leaderboard/worker.js"

var tune: Tuning
var save: SaveData
var prog: Progress


func before_test() -> void:
	tune = load("res://src/data/tuning.tres")
	save = SaveData.new("", tune.start_nar)
	prog = Progress.new(save, tune, 1)


func _js_list(src: String, name: String) -> Array:
	var m := RegEx.create_from_string("const " + name + " = \\[([^\\]]*)\\]").search(src)
	var out := []
	for q in RegEx.create_from_string("'([^']*)'").search_all(m.get_string(1)):
		out.append(q.get_string(1))
	return out


func test_nickname_lists_match_the_server() -> void:
	var src := FileAccess.get_file_as_string(WORKER)
	assert_array(_js_list(src, "ADJ")).is_equal(Array(Catalog.NICK_ADJ))
	assert_array(_js_list(src, "HERO")).is_equal(Array(Catalog.NICK_HERO))


func test_player_id_is_random_hex_and_stays() -> void:
	var id := prog.player_id()
	assert_int(id.length()).is_equal(32)
	assert_bool(id.is_valid_hex_number()).is_true()
	assert_str(prog.player_id()).is_equal(id)


func test_nothing_is_sent_before_a_nickname_is_chosen() -> void:
	assert_bool(prog.should_send(1000)).is_false()


func test_nickname_wraps_round_the_lists() -> void:
	prog.set_nick(-1, Catalog.NICK_HERO.size())
	assert_str(Catalog.nick_name(prog.nick())).is_equal("%s %s" % [Catalog.NICK_ADJ[-1], Catalog.NICK_HERO[0]])


func test_only_a_better_score_is_sent_again() -> void:
	prog.set_nick(0, 0)
	assert_bool(prog.should_send(500)).is_true()
	prog.sent(500)
	assert_bool(prog.should_send(400)).is_false()
	assert_bool(prog.should_send(600)).is_true()


func test_online_switched_off_sends_nothing() -> void:
	prog.set_nick(0, 0)
	prog.toggle("online")
	assert_bool(prog.should_send(500)).is_false()
