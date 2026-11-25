# Game Brief: Cırtdan: Köhnə Bakıda Qaçış

## In your words
"oyun yaradacam" · "pdf atandan sonram qalan ne varsa ozun duzelt ne lazimdisa yukle ele"

The full design is the person's GDD, `design/source/Cirtdan_Oyun_Senedi.pdf` (v1.0, 11 pages), the source of truth for everything past this slice. Fields below are pulled from it; the person asked for no questions, so every open choice took its default *(provisional)*.

From the GDD, word for word where it names the look: "Mobil endless runner oyunu", "3 zolaqlı", "Barmaqla sürüşdürmə (swipe): sola, sağa, yuxarı, aşağı", "Parlaq rəngli, cizgi filmi üslubunda 3D qrafika", "Milli naxışlar: buta, xalça ornamentləri, şəbəkə pəncərələr", "Div qorxulu yox, gülməli görünməlidir", "qızılı daş divarlar, mavi Xəzər, qırmızı-göy xalçalar", "Qız Qalası: uzaqda, səmada görünən əsas simvol".

After play: "davam et" (no play notes yet; the build went on to Build order step 2)
After play: "davam" (no play notes yet; the build went on to Build order step 3)
After play: "davam et" (no play notes yet; the build went on to the GDD's step 4: music, voices, the opening story)
After play: "Davam" (no play notes yet; the build went on to the daily word hunt and the festivals)
After play: "Sürüt yerinde simurt tapa bilçirem oyunda gelmirem rastima . Develerin ustundede gezmek olsun qabaqdan deyebənde ölsün.   Bunnari duzelt ve davam et bir başa"
After play: "Davam" (no play notes; the build went on to Qəbələ)
After play: "Şəhərlərin hamisini birdən aç və davam ele  birde nağara sözün yiqmisam  qalib sehifede onu ele eleki her defe yiqa bilim"
After play: "Oyunda bug var yagli corekden basqa nese ekranda var ve oyunda gelir oni yigirsan . Sonram herf yiqmaq ekranda gorunmesin daimi herfi gpturdukce görsensin ve itsin oynanamaqa mane olur oyundaki buglari aradan qaldir hamisini . ( google play ve app store saxla en axira hele isimiz çoxdu oyun tam duzelden sonraç keçeçeyik dizaym merhelesin personojıarin yerlerin ayri ayri duzeldecik her sheyi animasiyalar elave edeceyik ) telesme)"
After play: "Senedde olan her sheyi duzelt sonram men oynadiqca gelub sene belli bir yerini duzeldeceç birde men qoşdumqum agentlerden istifade edirsen?"

After play: "Demek  bu versoyada qaliriq oyun mexanizmlerini oynu tam hazir veziyyete getirenden sonram godota keçirik animasiya dizayn personajlar üçün onuda edenden sonram oynu esl mobil oyna çevirib qoyuruq app store ve goog storeye okey?"

After play: "Tedbirleri yigisdir umumen / Geyim ayri mağazaya çıxar geyim dükani / Şeherleri açmaq qizilnan olsun / Personajlarda kilidlileride qizil qoy / Tapşırıq sehifesinde tapşırıq bitibse üstünə basaq qizili versin yerinə təzə tapşırıq gelsin / Ses musiqi mende islemir telfonnan girirem atdiqin linke gelmir / Nenemin dukaninda alinada nese eger leveli qalxirsa meselem nenemin sinisin onu ele ele qabaqinda bidene işare artsinli görsün ne qeder qalib tamamlamaqa / Dukana jetpack - əvəzləyən nəsə əlavə et baslayanda nese uçan xalça var oda olsun ama oyun baslayanda bor defe basim ona uçub aparsin qabaqa qizillaro yiqa bilsin oda qizilnan olsun / Birde oyunda bidene körpü var altindan keçende orda nese yan divarda sehflik var izah edenmirem ama duzeldersen ."

After play: "İphone du ses gelmir  hee yağ çöreyo deyirdim bidene agent skili varsa test eden ona de oynu iynasin çoxlu test elesin her bir sheyini ve sene ne duzelmelidi desin"

**Pitch:** Little, clever Cırtdan sprints through the narrow stone streets of old Baku with a huge, clumsy Div on his heels, dodging phaetons and camel caravans and scooping up grandma's yağ çörəkləri.

**Genre:** endless runner, 3 lanes, seen from behind

**Controls:** swipe left/right to change lane, up to jump, down to slide; double tap for the flying carpet. Keys: ← → (or A D) lanes, ↑ / W / Space jump, ↓ / S slide, Shift (or double tap) carpet, P pause, M mute, Enter start.

**Question:** Does dodging through old-Baku streets with the Div closing in feel fun and readable at speed, on a phone and on keys?

**Hooks:** The Div is the chaser: a side bump brings him up behind you, a second within seconds and he grabs you ("Hamm!"). Old Baku in place of a city: hay carts you can run on top of, camel caravans coming at you, carpets hung on ropes to slide under, bazaar stalls to swerve round, Qız Qalası on the skyline.

**Intent:** *payoff builds* (from the GDD: the score multiplier and speed grow as you go)

## Look and references
- Look: bright, cartoon 3D, low-poly with rounded chunky shapes; golden sandstone walls with şəbəkə lattice windows and wooden balconies, red-and-blue carpets with buta patterns, blue Caspian sky, Qız Qalası standing on the horizon. Cırtdan is tiny with a red papaq, patterned vest and a patched bread sack; the Div is big, furry, horned, round-bellied, with a club, comic not scary. Warm late-afternoon light. Every figure drawn, no emoji, no plain circles.
- References: the GDD's own pages (characters, place, power-ups); the genre's 3D lane runners for timing and lane width only.
- View: 3D · Camera: fixed behind and above the runner, looking down the street.

## First minute
The title shows Cırtdan, grandma's line and the controls. Enter or a tap: the Div bursts out behind and the run starts slow on an empty street with a row of bread to collect. The first obstacles come one at a time with a beat to read each: a pile of baskets to jump, a carpet on a rope to slide under, a bazaar stall to swerve round. By 40 seconds a plank ramp leads onto hay-cart roofs with bread along them, and the first camel caravan walks toward you in one lane. A side bump makes the Div loom up and the edges glow red; he drops back after a few seconds: the hook pays off.

## Challenge
The street is safe for the first 8 seconds; the first real trouble, two lanes blocked at once, comes at about 45 seconds. Speed rises steadily to a cap around 2.5 minutes. A head-on hit with a phaeton or caravan, or two side bumps close together, ends the run; a nar can be spent to continue (the cost doubles each time in a run). Later chunks mix moving caravans with roof routes and tunnels.

## Core loop
- Run forward automatically; read the next obstacle and swipe to change lane, jump or slide.
- Collect bread (score and currency) and the rarer nar; grab power-ups.
- The run speeds up and the multiplier rises until a crash or the Div catches you.
- See distance, bread and best; one tap runs again.

## Goal & fail state
- Run as far as you can and beat your best score (distance × multiplier, plus bread).
- A head-on crash, or two side bumps while the Div is close, ends the run ("Div səni tutdu!").

## Features
- [x] 3 stone-street lanes, auto-run that speeds up, swipe and key controls
- [x] Jump and slide, with obstacles that each ask for one move: baskets and jugs (jump), carpet on ropes (slide), bazaar stalls (lane change), parked phaetons (lane change), hay carts (lane change or plank ramp onto the roof), oncoming camel caravan, city-gate tunnel
- [x] The Div chasing behind: a side bump brings him close, a second one catches you
- [x] Yağ çörəyi in lines and arcs; rare nar
- [x] Power-ups: grandma's tray (magnet), magic çarıq (super jump), qoşa təndir (x2), Simurq (flies high over the street for 8 s, bread in the sky), kəndirbaz çubuğu (big hops, bounces off obstacle tops), flying carpet (one-hit shield, double tap) (thin stand-in: upgrades later)
- [x] Score = distance × multiplier; best score kept between visits; a new street every run
- [x] Old-Baku scenery: sandstone houses, balconies, carpets, Qız Qalası on the skyline
- [x] Title, pause, mute, game over with continue-with-nar and restart
- [x] A menu on the title: Oyna, Nənənin dükanı, Personajlar, Tapşırıqlar
- [x] Nənənin dükanı: 5 levels per power-up (longer each level), flying carpets to keep, Nənənin bağlaması (a random gift)
- [x] Characters: Cırtdan, Tıq-Tıq xanım (5 000 bread), Keçəl (3 mission sets), Kəndirbaz (10 000 bread); Məlikməmməd, Pəri qız, Kosa shown locked until their events
- [x] Music: a 6/8 dance in the Şur mode, synthesised tar, balaban and nağara over a modern kick; calm in the menu, faster with speed, epic with the Simurq
- [x] Voices: the Div's "Ay Cırtdaaan!" and "Hamm!", "Yenə sənsən?!", Cırtdan's giggle, sung by a small formant synth
- [x] The opening story in five staged pictures, from the GDD's intro (first Oyna, and Nağıl in the menu)
- [x] Word hunt: a word (NOVRUZ, XALÇA, TƏNDİR, NAĞARA...) lies in the street letter by letter, in order; spelling it gives Nənənin bağlaması and the next word starts at once, as many as you like; the day's first word keeps a streak of days (up to 3 bundles)
- [x] Festivals by the calendar or chosen in Tədbirlər: Novruz (bonfires to jump, səməni, şəkərbura and paxlava that unlock Kosa), Qış (snow, the Div in a scarf and hat), Nar bayramı (pomegranate trees, twice the nar); Xəzər yayı shown as coming
- [x] The Simurq feather in every run by about the 14th row, and power-ups more often (the Simurq was too rare to meet)
- [x] Run along the camels' backs; a hay cart with a ramp often waits in the next lane to jump across from; a head-on hit with the caravan still ends the run
- [x] Şəki, the first city of the Azerbaijan tour: whitewashed stone houses with red tiled roofs and deep wooden eyvans, the Xan sarayı and green mountains on the horizon, Şəki halvası worth 5 bread; chosen in Şəhərlər
- [x] Qəbələ: a forest trail of packed earth and leaves, pines and autumn oaks, log huts, green mountains with a waterfall; stumps to jump, fallen trunks to slide under, mossy boulders to swerve round, fındıq worth 3 bread
- [x] The whole Azerbaijan tour open: Naxçıvan (brick houses with turquoise bands, Möminə xatın türbəsi, İlandağ, salt crystals), Lənkəran (tea rows, rain, lighthouse, naringi), Quba (apple orchards, carpet looms, snowy Şahdağ, apples), Qobustan (carved rocks, mud volcanoes, the Caspian); each with its own obstacle looks and treat
- [x] Costumes for Cırtdan (Novruz, Qış, Dənizçi; 1 500 bread each); a festival dresses him in its own
- [x] Məlikməmməd (crown, cape, sword; won by the weekly hunt of 40 buta stones) and Pəri qız (wings, flower crown; 25 magic stones)
- [x] Nənə's daily gift on the title; the Div's comic trips at 1 000, 2 500, 5 000 and 10 000 m with Cırtdan sticking his tongue out
- [x] Liderlər: your best 10 runs and your league (Bürünc, Gümüş, Qızıl, Div liqası); Ayarlar: language, sound, music, festivals, costumes, the story
- [x] Xəzər yayı: a seaside run (sand, umbrellas, the sea, old ships, oil derricks; sandcastles to jump, ice-cream kiosks to swerve), Cırtdan in his sailor suit
- [x] Languages: Azərbaycan, Türkçe, English, Русский, chosen in Ayarlar (translations by the localization-lead agent, in lang.js)
- [x] Geyim dükanı: costumes in their own shop on the menu
- [x] Cities and locked characters bought with bread (the game's gold)
- [x] Missions: tap a finished one to take its bread; a new one takes its place; every third raises the multiplier
- [x] Xalça ilə uçuş: a start boost bought in Nənənin dükanı; one tap at the start and the carpet flies Cırtdan ahead over a line of bread
- [x] Buying asks twice (Təsdiq?) so a child never spends bread by one stray tap; pause has Davam and Menyu
- [x] Missions: three at a time from the GDD's list; finishing all three raises the base multiplier by one for good

## Your systems
- Div chasing behind · in the slice
- Power-ups (Simurq, sehrli çarıq, nənənin sinisi, qoşa təndir, uçan xalça, kəndirbaz çubuğu) · thin stand-in *(guessed)*
- Nar to continue after a crash · thin stand-in *(guessed)*
- Score multiplier from missions · in the slice
- Nənənin dükanı (shop and upgrades) · in the slice
- Unlockable characters · in the slice
- Costumes, Məlikməmməd and Pəri qız · in the slice
- Kosa, unlocked with Novruz sweets · in the slice
- Missions · in the slice
- Word hunt, repeatable · in the slice
- Weekly hunt, daily gifts · in the slice
- Local leaderboard and leagues · in the slice
- Online leaderboard · later (needs a server)
- Festival events · removed *(you said)*
- Xəzər yayı seaside run · removed with the festivals *(you said)*
- Azerbaijan tour: Şəki, Qəbələ, Naxçıvan, Lənkəran, Quba, Qobustan · in the slice
- Intro story · in the slice
- Comic moments at milestones · in the slice
- Music and voice lines · in the slice

## Keep
- Sürət yerində (the speed is right) *(you said)* · pins: speed_start 10, speed_max 22, speed_ramp 0.08

## Avoid
- Festivals: "Tədbirləri yığışdır ümumən" *(you said)*
- The word's letters on screen all the time: show them only when a letter is taken, then let them fade *(you said)*
- Rushing: "telesme" *(you said)*
- Subway Surfers' name, art, characters and UI (it is a genre reference in the GDD, never copied)
- A scary Div: he must look funny *(from the GDD)*
- Ads and purchases in this build *(from the GDD's child-audience note)*

## Out of scope
- Costumes; weekly hunt and daily gifts: add it as a feature
- Xəzər yayı seaside level: change it after play
- Scenery that changes the further you run, other cities: change it after play
- Online leaderboards and leagues: needs a server: not built yet
- A level mode with an end: grow it
- Native Android/iOS build (Unity or Godot per the GDD): this web game is where it starts; run in a phone's browser, swipe built but not checked by the self-check

## Build order
1. The slice: an endless run on 3 lanes in old Baku with the Div behind, bread, the obstacle set, speed ramp, score and best, ending on a crash or the Div catching you, with continue-with-nar and restart.
2. Power-ups to full strength and the remaining two (Simurq flight, kəndirbaz çubuğu).
3. Grandma's shop, characters, missions.
4. Here, in this web version: every mechanic and bug until the game is fully right *(you said)*.
5. Then move to Godot (/setup-engine godot): characters, places, animations and design made properly one by one; this prototype is the spec *(you said)*.
6. Last: export from Godot to Android and iOS, then Google Play and App Store (store accounts, a Mac or cloud build for iOS, the stores' rules for children's games) *(you said)*.

---
**Kill condition:** if lane changes and the Div's threat still don't read at speed on a phone after two tuning rounds.

**Who it's for / what they feel:** children 7+ and families in Azerbaijan; "Mən balacayam, amma ağlım böyükdür!": small but clever, escaping by wit.

**Games you love / don't:** the GDD names a famous 3D lane runner as the closest game (genre only).
