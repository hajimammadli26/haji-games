## Talks to the online leaderboard (server/leaderboard/worker.js): sends a new best score, fetches the
## all-time or this week's top list. Quietly does nothing while no server address is set
## (Project Settings: cirtdan/online/leaderboard_url) or the device is offline; the game never waits on it.
##
## Usage:
##   var online := Online.new(); add_child(online)
##   online.loaded.connect(func(scope, data): ...)
##   online.fetch_top("week", prog.player_id())
##   online.submit(prog.player_id(), prog.nick(), score, metres, city)
class_name Online
extends Node

## The top list arrived: data has rows [{rank, nick, score, metres, city, you}] and me {rank, score} or null.
signal loaded(scope: String, data: Dictionary)
## The top list could not be fetched (no server set, offline, or an error).
signal failed(scope: String)
## A score was accepted: the player's rank on the all-time board.
signal submitted(score: int, rank: int)

const SETTING := "cirtdan/online/leaderboard_url"
const TIMEOUT := 8.0

var base_url := ""


func _ready() -> void:
	if base_url == "": # an address set before (tests, a dev flag) stays
		base_url = String(ProjectSettings.get_setting(SETTING, "")).trim_suffix("/")


## True when a server address is set.
func enabled() -> bool:
	return base_url != ""


## Fetches the top list: scope "all" or "week"; player marks the player's own row and rank.
func fetch_top(scope: String, player: String) -> void:
	if not enabled():
		failed.emit(scope)
		return
	var url := "%s/top?scope=%s&limit=20&player=%s" % [base_url, scope, player]
	_request(url, HTTPClient.METHOD_GET, "", func(code: int, body: Dictionary) -> void:
		if code == 200 and body.has("rows"):
			loaded.emit(scope, body)
		else:
			failed.emit(scope))


## Sends a score (the server keeps the player's best).
func submit(player: String, nick: int, score: int, metres: int, city: String) -> void:
	if not enabled() or nick < 0:
		return
	var body := JSON.stringify({"player": player, "nick": nick, "score": score, "metres": metres, "city": city})
	_request(base_url + "/score", HTTPClient.METHOD_POST, body, func(code: int, data: Dictionary) -> void:
		if code == 200 and data.get("ok", false):
			submitted.emit(score, int(data.get("rank", 0))))


func _request(url: String, method: int, body: String, done: Callable) -> void:
	var http := HTTPRequest.new()
	http.timeout = TIMEOUT
	add_child(http)
	http.request_completed.connect(func(result: int, code: int, _h: PackedStringArray, raw: PackedByteArray) -> void:
		http.queue_free()
		var data: Variant = JSON.parse_string(raw.get_string_from_utf8()) if result == HTTPRequest.RESULT_SUCCESS else null
		done.call(code if result == HTTPRequest.RESULT_SUCCESS else 0, data if data is Dictionary else {}))
	var err := http.request(url, ["Content-Type: application/json"], method, body)
	if err != OK:
		http.queue_free()
		done.call(0, {})
