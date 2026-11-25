## The player's progress between runs: spending bread in the shops, choosing a character, a costume and a city,
## the missions and their rewards, the leaderboard of local runs. All rules here, no drawing, so tests can drive it.
## Implements design/game-brief.md (Nənənin dükanı, Geyim dükanı, Personajlar, Şəhərlər, Tapşırıqlar, Liderlər).
##
## Usage:
##   var prog := Progress.new(SaveData.new(), load("res://src/data/tuning.tres"))
##   if prog.buy_level("magnet"): ...       # false when there is not enough bread or the level is full
##   prog.mission("bread", 1)                # from the run's events
##   prog.claim(0)                           # a finished mission pays and is replaced
class_name Progress
extends RefCounted

## A mission was finished in a run (the reward waits in Tapşırıqlar).
signal mission_done(text: String)

var save: SaveData
var tune: Tuning
var rng := RandomNumberGenerator.new()


func _init(save_data: SaveData, tuning: Tuning, seed_value: int = -1) -> void:
	save = save_data
	tune = tuning
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


## Bread the player has.
func bread() -> int:
	return int(save.get_value("bread"))


## Takes n bread if there is enough. Returns false (and takes nothing) if not.
func spend(n: int) -> bool:
	if bread() < n:
		return false
	save.set_value("bread", bread() - n)
	return true


func _add(key: String, n: int) -> void:
	save.set_value(key, int(save.get_value(key)) + n)


# ---- Nənənin dükanı ---------------------------------------------------------------------------

## The shop level (0..tune.max_level) of a power-up.
func level(kind: String) -> int:
	return int((save.get_value("levels") as Dictionary).get(kind, 0))


## The price of the next level: doubles every level.
func level_cost(kind: String) -> int:
	return tune.upgrade_cost * (1 << level(kind))


## Buys the next level of a power-up.
func buy_level(kind: String) -> bool:
	if level(kind) >= tune.max_level or not spend(level_cost(kind)):
		return false
	var lv: Dictionary = (save.get_value("levels") as Dictionary).duplicate()
	lv[kind] = level(kind) + 1
	save.set_value("levels", lv)
	return true


## All levels as {kind: level}, for RunSim.levels.
func levels() -> Dictionary:
	var out := {}
	for p in Catalog.POWERS:
		out[p["id"]] = level(p["id"])
	return out


## Buys a flying carpet to keep (one tap at the start of a run).
func buy_carpet() -> bool:
	if not spend(tune.carpet_cost):
		return false
	_add("carpets", 1)
	return true


## Buys a start boost (Xalça ilə uçuş).
func buy_boost() -> bool:
	if not spend(tune.boost_cost):
		return false
	_add("boosts", 1)
	return true


## Nənənin bağlaması: a random gift. Returns what came out ("" when there was not enough bread).
func open_box() -> String:
	if not spend(tune.box_cost):
		return ""
	var r := rng.randf()
	if r < 0.4:
		var n := 300 + rng.randi_range(0, 12) * 100
		_add("bread", n)
		return "Bağlamadan %d yağ çörəyi çıxdı!" % n
	if r < 0.7:
		_add("nar", 1)
		return "Bağlamadan nar çıxdı!"
	if r < 0.9:
		_add("carpets", 1)
		return "Bağlamadan uçan xalça çıxdı!"
	_add("nar", 2)
	return "Bağlamadan iki nar çıxdı!"


# ---- Characters, costumes, cities -------------------------------------------------------------

func _owns(key: String, id: String) -> bool:
	return id in (save.get_value(key) as Array)


func _own(key: String, id: String) -> void:
	var a: Array = (save.get_value(key) as Array).duplicate()
	if not id in a:
		a.append(id)
	save.put(key, a)


## True if the character can be chosen.
func has_char(id: String) -> bool:
	if _owns("chars", id):
		return true
	var c := Catalog.find(Catalog.CHARS, id)
	return c.get("claims", false) and int(save.get_value("claims")) >= tune.kecel_claims


## Chooses a character, buying it first if needed. Returns false if it cannot be had.
func choose_char(id: String) -> bool:
	if not has_char(id):
		if not spend(int(Catalog.find(Catalog.CHARS, id)["price"])):
			return false
	_own("chars", id)
	save.set_value("char", id)
	return true


## True if Cırtdan has this costume.
func has_costume(id: String) -> bool:
	return id == "none" or _owns("costumes", id)


## Puts on a costume, buying it first if needed.
func choose_costume(id: String) -> bool:
	if not has_costume(id):
		if not spend(tune.costume_cost):
			return false
		_own("costumes", id)
	save.set_value("costume", id)
	return true


## True if the city is open.
func has_city(id: String) -> bool:
	return _owns("cities", id)


## Goes to a city, buying it first if needed.
func choose_city(id: String) -> bool:
	if not has_city(id):
		if not spend(int(Catalog.find(Catalog.CITIES, id)["price"])):
			return false
		_own("cities", id)
	save.set_value("city", id)
	return true


## The look for Figures.cirtdan(): the character's colours with the costume on top (costumes are Cırtdan's).
func look() -> Dictionary:
	var id := String(save.get_value("char"))
	var l: Dictionary = (Catalog.find(Catalog.CHARS, id)["look"] as Dictionary).duplicate()
	if id == "cirtdan":
		l.merge(Catalog.find(Catalog.COSTUMES, String(save.get_value("costume")))["look"], true)
	return l


# ---- Missions: three at a time, each claimed by a tap -----------------------------------------

func _slots() -> Array:
	var sl: Variant = save.get_value("mslots")
	if not sl is Array or (sl as Array).size() != 3:
		sl = [0, 1, 2]
		save.put("mslots", sl)
		save.put("mnext", 3)
	return sl


## The three current missions: {k, txt, target, reward, prog, done}.
func missions() -> Array:
	var out := []
	var prog: Array = save.get_value("mprog")
	var sl := _slots()
	for i in 3:
		var idx := int(sl[i])
		var m: Dictionary = Catalog.MISSIONS[idx % Catalog.MISSIONS.size()]
		var lvl := idx / 3
		var target := roundi(m["t"] * (1.0 + lvl * tune.mission_scale))
		var reward := roundi(tune.mission_reward * (1.0 + lvl * 0.5) / 10.0) * 10
		var p := mini(target, int(prog[i]))
		out.append({"k": m["k"], "txt": String(m["txt"]) % target, "target": target, "reward": reward,
			"prog": p, "done": p >= target, "run": m.get("run", false)})
	return out


## Counts progress for every current mission of this kind (run missions keep the best value of one run).
func mission(kind: String, v: float) -> void:
	var ms := missions()
	var prog: Array = (save.get_value("mprog") as Array).duplicate()
	var changed := false
	for i in 3:
		var m: Dictionary = ms[i]
		if m["k"] != kind or m["done"]:
			continue
		var cur := float(prog[i])
		var nv := minf(m["target"], maxf(cur, v) if m["run"] else cur + v)
		if nv == cur:
			continue
		prog[i] = nv
		changed = true
		if nv >= m["target"]:
			mission_done.emit(m["txt"])
	if changed:
		save.put("mprog", prog)


## Claims a finished mission: its bread, a new mission in its place, and every third claim
## raises the base multiplier (up to tune.mission_mult_cap). Returns the reward (0 if not finished).
func claim(i: int) -> int:
	var m: Dictionary = missions()[i]
	if not m["done"]:
		return 0
	var sl := _slots().duplicate()
	var nxt := int(save.get_value("mnext")) if save.get_value("mnext") != null else 3
	sl[i] = nxt
	save.put("mslots", sl)
	save.put("mnext", nxt + 1)
	var prog: Array = (save.get_value("mprog") as Array).duplicate()
	prog[i] = 0
	save.put("mprog", prog)
	var claims := int(save.get_value("claims")) + 1
	save.put("claims", claims)
	if claims % 3 == 0 and int(save.get_value("mmult")) < tune.mission_mult_cap:
		save.put("mmult", int(save.get_value("mmult")) + 1)
	save.put("bread", bread() + int(m["reward"]))
	save.flush()
	return m["reward"]


## Turns a setting on or off (music, sound).
func toggle(key: String) -> void:
	save.set_value(key, not bool(save.get_value(key)))


# ---- Runs and the leaderboard -----------------------------------------------------------------

## Records a finished run (score, metres, bread); keeps the best 10. Returns true for a new best.
func record_run(score: int, metres: int, bread_got: int) -> bool:
	var runs: Array = (save.get_value("runs") as Array).duplicate()
	runs.append({"score": score, "m": metres, "bread": bread_got, "date": Time.get_date_string_from_system()})
	runs.sort_custom(func(a, b): return a["score"] > b["score"])
	save.put("runs", runs.slice(0, 10))
	var best := score > int(save.get_value("best"))
	if best:
		save.put("best", score)
	save.flush()
	return best


## The league for a best score.
func league(best: int) -> String:
	if best >= tune.league_div:
		return "Div liqası"
	if best >= tune.league_gold:
		return "Qızıl liqa"
	if best >= tune.league_silver:
		return "Gümüş liqa"
	return "Bürünc liqa"
