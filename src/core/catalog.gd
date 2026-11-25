## The game's lists: characters, costumes, cities, the shop's power-ups and the missions. Data only.
## Prices of characters and cities live here with them; the shop's prices are in Tuning.
## Names and descriptions are Azerbaijani (the source language; translations come later).
class_name Catalog
extends RefCounted

## Characters. look: colours and hat for Characters.runner(). Unlock: free, price (bread), or claims (missions).
const CHARS := [
	{"id": "cirtdan", "name": "Cırtdan", "desc": "Əsas qəhrəman", "price": 0,
		"look": {"hat": "papaq", "hat_color": "#c8221d", "vest": "#1f4f8f", "trim": "#f1c34a", "shirt": "#f3ecd8", "pants": "#4b3221"}},
	{"id": "tiqtiq", "name": "Tıq-Tıq xanım", "desc": "Cəld və şən qız", "price": 5000,
		"look": {"hat": "scarf", "hat_color": "#d6362f", "vest": "#2b7a48", "trim": "#f2d16b", "shirt": "#fbe7c6", "pants": "#7a2c3e", "braids": true}},
	{"id": "kecel", "name": "Keçəl", "desc": "Zarafatcıl və bic oğlan", "price": 3000, "claims": true,
		"look": {"hat": "bald", "hat_color": "#ffe7c4", "vest": "#7a2c3e", "trim": "#f1c34a", "shirt": "#e9e2cf", "pants": "#2a2a3a"}},
	{"id": "kendirbaz", "name": "Kəndirbaz", "desc": "İp üstündə oynayan cəld oğlan", "price": 10000,
		"look": {"hat": "tall", "hat_color": "#f3ecd8", "vest": "#c8322c", "trim": "#1f9e9a", "shirt": "#f2b632", "pants": "#1d4f9a"}},
	{"id": "kosa", "name": "Kosa", "desc": "Novruz bayramının obrazı", "price": 8000,
		"look": {"hat": "kosa", "hat_color": "#3b2414", "vest": "#8a6a44", "trim": "#f2d16b", "shirt": "#c9a46a", "pants": "#5a3a22"}},
	{"id": "peri", "name": "Pəri qız", "desc": "Sehrli qanadlı qız", "price": 12000, "stones": true,
		"look": {"hat": "peri", "hat_color": "#f2a6c8", "vest": "#8ec9e8", "trim": "#ffffff", "shirt": "#f7f0ff", "pants": "#b48ad8"}},
	{"id": "melik", "name": "Məlikməmməd", "desc": "Cəsur şahzadə, qılınclı", "price": 15000, "hunt": true,
		"look": {"hat": "crown", "hat_color": "#d8a53a", "vest": "#1d3f8a", "trim": "#f2d16b", "shirt": "#f3ecd8", "pants": "#2a2a3a"}},
]

## Cırtdan's costumes: they change his colours and hat.
const COSTUMES := [
	{"id": "none", "name": "Adi geyim", "desc": "qırmızı papaq, naxışlı jilet", "look": {}},
	{"id": "novruz", "name": "Novruz geyimi", "desc": "Cırtdan üçün", "look": {"vest": "#2b7a48", "trim": "#d6362f", "hat_color": "#c8221d", "sprig": true}},
	{"id": "winter", "name": "Qış geyimi", "desc": "Cırtdan üçün", "look": {"vest": "#7a5a3a", "trim": "#efe6cf", "shirt": "#c9a46a", "hat": "winter", "hat_color": "#efe6cf"}},
	{"id": "sailor", "name": "Dənizçi geyimi", "desc": "Cırtdan üçün", "look": {"vest": "#1d4f9a", "trim": "#ffffff", "shirt": "#ffffff", "pants": "#1d4f9a", "hat": "sailor", "hat_color": "#ffffff"}},
]

## Cities of the Azerbaijan tour. Colours for the street, the houses and the haze (the design stage builds each
## city properly; these keep them apart until then).
const CITIES := [
	{"id": "baku", "name": "Köhnə Bakı", "desc": "İçərişəhər: Qız Qalası, bazar, faytonlar", "price": 0,
		"street": "#bfa27a", "wall": "#d9a95f", "fog": "#f3d6a4"},
	{"id": "sheki", "name": "Şəki", "desc": "Xan sarayı, şəbəkə pəncərələr, Şəki halvası", "price": 2000,
		"street": "#b9a88a", "wall": "#efe6d2", "fog": "#dfe9d6"},
	{"id": "qebele", "name": "Qəbələ", "desc": "meşə cığırı, şəlalə, kötüklər, qayalar, fındıq", "price": 3000,
		"street": "#8a6a44", "wall": "#4f7a3a", "fog": "#cfe2d8"},
	{"id": "naxcivan", "name": "Naxçıvan", "desc": "Möminə Xatın türbəsi, İlandağ, Badamlı suyu", "price": 4000,
		"street": "#c9a585", "wall": "#b8643a", "fog": "#ead2b8"},
	{"id": "lenkeran", "name": "Lənkəran", "desc": "çay plantasiyaları, yağış, mayak, naringi", "price": 5000,
		"street": "#9fa8a8", "wall": "#4aa844", "fog": "#c9d6d8"},
	{"id": "quba", "name": "Quba", "desc": "alma bağları, xalça dəzgahları, Şahdağ", "price": 6000,
		"street": "#bfa27a", "wall": "#6aa84a", "fog": "#dfe8e0"},
	{"id": "qobustan", "name": "Qobustan", "desc": "qayaüstü təsvirlər, palçıq vulkanları, Xəzər", "price": 8000,
		"street": "#c8b48a", "wall": "#8a6e52", "fog": "#e8dcc4"},
]

## Nənənin dükanı: power-ups with levels.
const POWERS := [
	{"id": "magnet", "name": "Nənənin sinisi", "what": "çörəkləri özünə çəkir"},
	{"id": "shoe", "name": "Sehrli çarıq", "what": "çox hündür tullanır"},
	{"id": "double", "name": "Qoşa təndir", "what": "xalı ikiqat edir"},
	{"id": "pole", "name": "Kəndirbaz çubuğu", "what": "böyük sıçrayışlar"},
	{"id": "simurq", "name": "Simurq quşu", "what": "göydə uçur"},
]

## Missions, in order; each new one is harder (Tuning.mission_scale) and pays more. run: counted in one run.
const MISSIONS := [
	{"k": "run_bread", "t": 120, "run": true, "txt": "Bir qaçışda %d yağ çörəyi topla"},
	{"k": "simurq", "t": 1, "txt": "Simurq quşundan %d dəfə istifadə et"},
	{"k": "roof", "t": 8, "txt": "Yük arabalarının damında %d saniyə qaç"},
	{"k": "carpet", "t": 8, "txt": "Xalça ipinin altından %d dəfə sürüş"},
	{"k": "escape", "t": 2, "txt": "Divi %d dəfə yaxınlaşdırıb yenə qaç"},
	{"k": "run_dist", "t": 800, "run": true, "txt": "Bir qaçışda %d m qaç"},
	{"k": "basket", "t": 12, "txt": "Səbətlərin üstündən %d dəfə tullan"},
	{"k": "powers", "t": 3, "txt": "%d güclənmə topla"},
	{"k": "bread", "t": 400, "txt": "Cəmi %d yağ çörəyi topla"},
]


## Online nicknames: an adjective and a hero, chosen from these lists only (no free text, nothing
## personal). The same lists, in the same order, are in server/leaderboard/worker.js.
const NICK_ADJ := ["Cəld", "Qoçaq", "Bic", "Şən", "Ağıllı", "Sürətli", "Cəsur", "Zirək"]
const NICK_HERO := ["Cırtdan", "Simurq", "Kəndirbaz", "Pəri", "Keçəl", "Tıq-Tıq", "Məlik", "Kosa", "Dəvə", "Buta"]


## The nickname for a number (adjective × hero), as the server shows it.
static func nick_name(n: int) -> String:
	return "%s %s" % [NICK_ADJ[n / NICK_HERO.size()], NICK_HERO[n % NICK_HERO.size()]]


## The day's words: their letters lie in the street in order; spelling one gives Nənə's bundle.
const WORDS := ["NOVRUZ", "XALÇA", "TƏNDİR", "QALA", "TAR", "PAXLAVA", "ŞƏKƏRBURA", "NAR", "BUTA", "KAMANÇA",
	"BALABAN", "SƏMƏNİ", "PAPAQ", "ÇARIQ", "NAĞARA", "SİMURQ"]


## Every vest colour with its trim that a character or costume wears (the texture tool paints one each).
static func vest_combos() -> Array:
	var out := []
	for c in CHARS:
		var l: Dictionary = c["look"]
		out.append([l["vest"], l["trim"]])
		if c["id"] == "cirtdan":
			for k in COSTUMES:
				var m: Dictionary = l.merged(k["look"], true)
				if not [m["vest"], m["trim"]] in out:
					out.append([m["vest"], m["trim"]])
	return out


## The entry with this id in a list (or the first one).
static func find(list: Array, id: String) -> Dictionary:
	for e in list:
		if e["id"] == id:
			return e
	return list[0]
