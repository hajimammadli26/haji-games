## Tapşırıqlar: progress from the run, claiming, the multiplier, no two of a kind.
## Spec: design/game-brief.md (missions), src/core/progress.gd.
extends GdUnitTestSuite

var tune: Tuning
var save: SaveData
var prog: Progress


func before_test() -> void:
	tune = load("res://src/data/tuning.tres")
	save = SaveData.new("", tune.start_nar)
	prog = Progress.new(save, tune, 1)


func _finish(i: int) -> void:
	prog.mission(prog.missions()[i]["k"], 1000000)


func test_three_missions_from_the_start() -> void:
	var ms := prog.missions()
	assert_int(ms.size()).is_equal(3)
	assert_str(String(ms[0]["k"])).is_equal("run_bread")


func test_run_mission_keeps_best_of_one_run() -> void:
	prog.mission("run_bread", 50)
	prog.mission("run_bread", 30)
	assert_int(int(prog.missions()[0]["prog"])).is_equal(50)


func test_claim_unfinished_pays_nothing() -> void:
	assert_int(prog.claim(0)).is_equal(0)


func test_claim_pays_and_replaces_mission() -> void:
	var before: String = prog.missions()[0]["k"]
	_finish(0)
	var reward: int = prog.missions()[0]["reward"]
	assert_int(prog.claim(0)).is_equal(reward)
	assert_int(prog.bread()).is_equal(reward)
	assert_str(String(prog.missions()[0]["k"])).is_not_equal(before)


func test_every_third_claim_raises_multiplier() -> void:
	for i in 3:
		_finish(1)
		prog.claim(1)
	assert_int(int(save.get_value("mmult"))).is_equal(2)


# Regression (UI playtest): after nine claims two "cart roof" missions were active together.
func test_claims_never_give_two_missions_of_one_kind() -> void:
	for n in 30: # always the first slot: the others stay, so a repeat of their kind would show
		_finish(0)
		prog.claim(0)
		var kinds := []
		for m in prog.missions():
			assert_bool(m["k"] in kinds).is_false()
			kinds.append(m["k"])


func test_mission_done_signal_fires_once() -> void:
	var fired := [0]
	prog.mission_done.connect(func(_t: String) -> void: fired[0] += 1)
	prog.mission("run_bread", 1000)
	prog.mission("run_bread", 2000)
	assert_int(fired[0]).is_equal(1)
