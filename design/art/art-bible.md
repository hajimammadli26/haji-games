# Art Bible: Cırtdan: Köhnə Bakıda Qaçış

> **Status**: Approved (all 9 sections, by the owner, 2026-11-25)
> **Owned By**: art-director
> **Last Updated**: 2026-11-25
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-11-25 — solo mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

**One-line rule:** a warm folk-tale picture book in motion — every element is either **the game**
(bold, clear, high-contrast) or **the carpet around it** (warm, ornamented, quiet). Never both.
*(az: Hərəkətdə canlanan isti nağıl kitabı — hər element ya **oyundur** (cəsarətli, aydın, kontrastlı), ya da
**onu əhatə edən xalçadır** (isti, naxışlı, sakit). Heç vaxt ikisi birdən.)*

Apply it to every part sent in: decide the layer first, then use that layer's treatment.
- **Game layer:** Cırtdan, the Div, obstacles, bread and pickups, the road and lane edges, UI numbers and buttons.
- **Carpet layer:** walls, skyline, Qız Qalası, ornament, UI frames.

**Principles**
1. **Read first, admire second** — serves readability at speed and the joy of speed.
   - Game layer: ink outlines, simple chunky silhouettes, the strongest value contrast and saturation on screen.
   - Carpet layer: lower contrast, softer saturation, fading toward the horizon.
   - Ornament lives on borders, walls and backdrops — never on lane surfaces or across an obstacle's silhouette.
   - The grey granite road (owner's choice) is a cool, neutral, mid-value lane: warm bread and the red papaq stand out on it.
   - *Test:* ornament vs clarity → choose clarity, move the ornament to the frame or backdrop. A greyscale phone-size
     thumbnail must name the hazard and the pickup within half a second, or the part fails.
2. **Funny, never scary** — serves the comic chase.
   - The Div: big, round, soft-bodied, clumsy; readable expressions (surprised, sulky, stumbling); warm or bright tones, never near-black.
   - Not allowed: sharp teeth or claws, glowing red eyes, a shadow falling over the player, horror lighting.
   - Hazards follow the same rule: phaetons and camels are characters, not threats.
   - Cırtdan's cleverness shows in pose and expression (a grin, a glance back), not in size.
   - *Test:* ambiguous Div or hazard design → choose round, bright and slapstick over sharp, dark and realistic.
3. **Hand-made and truly Azerbaijani** — serves pride and warmth in the culture.
   - Motifs from real sources: buta, Qarabağ carpet compositions, şəbəkə lattice, golden sandstone, the Caspian blue, Qız Qalası.
   - Textures look hand-painted (slight brush variation), never glossy plastic; warm late-afternoon light.
   - Not allowed: generic "Arabian Nights" clichés (onion domes, genie lamps, desert palaces), photorealism, clean digital gradients.
   - *Test:* generic Eastern-fantasy motif vs a specific Azerbaijani one → the Azerbaijani one; smooth digital vs painted → painted.

**Taken from the Azerbaijani animation and folk-tale tradition** (the owner's reference; general, to be pinned to 3–5
frames the owner sends):
- Calm, flat, gouache-like backgrounds with characters standing out clearly against them.
- Ornament as the story's **frame**: carpet borders, arches, miniature-style page frames (fits the carpet-framed UI).
- Characters built from a few big shapes with exaggerated proportions.
- A storyteller's warmth: a limited warm palette with a few strong accents.
- Some of Azerbaijani miniature painting's flat, layered depth in distant scenery; Qız Qalası as an emblem in the sky.

**Decided with the owner (2026-11-25), carried into Section 4**
- **Player red:** one bright red belongs to Cırtdan's papaq only; carpets use madder and wine reds.
- **Gold belongs to bread:** pickups get the brightest gold; UI borders use a muted antique gold.

## 2. Mood & Atmosphere

**Constant in every state:** the game layer keeps its contrast; only the carpet layer, the light and overlays carry
the mood. Player Red and Bread Gold are never dimmed. On the Mobile/Compatibility renderers mood comes from light
colour, ambient, fog colour, per-city palette and UI overlays — not glow, bloom or grading.

| State | Feeling | Light | Mood carriers |
|---|---|---|---|
| Home menu | "a festival in the street": welcome | warm golden hour, mid contrast, soft shadows | Cırtdan dancing; carpets on balconies; Qız Qalası glowing; street slightly hazed so the menu reads first |
| Run, calm opening | a carefree dash | warm late afternoon, low–mid contrast, wide haze `#f3d6a4` | sparse obstacles, open sky, landmark far ahead |
| Run, fast later | a joyful rush, not stress | sun sinking toward amber; game layer gains saturation, carpet layer fades into haze | speed streaks at screen edges only (never over lanes); slight FOV widening |
| Div close (after a stumble) | "giggle-panic", a puppet show's "he's behind you!" | scene does **not** darken or turn red | the Div's comic face rising at the bottom; dust puffs; Div Olive `#6f8a3a` tint in the bottom 15%; small shake. Never a shadow over Cırtdan |
| Flight (Simurq, carpet) | soaring wonder | the only **cool, high-key** state: pale sky `#8fd0f0`, low contrast | rooftops and Qız Qalası small and desaturated below; turquoise trail; bread arcs in open sky |
| Game over | "oops, try again!", never punishment | freeze-frame, world ~60% desaturated, warm grey | Cırtdan and the nar offer stay fully saturated; caught: the Div holds him up by the sack; crash: stars round his head |
| Story, day (Baku) | grandmother telling a tale | flat gouache daylight, warm, mid contrast | miniature-style page frame; layered horizons |
| Story, night (theft, cave, chase) | bedtime spooky-cosy, always safe | indigo `#26305e` / `#b9c8e8` moonlight with warm pools `#ffb050`; deepest value Ink `#2a1e24`, never pure black | theft: sneaking silhouette in lit windows; cave: amber firelight from side/front (never below), the Div snoring, crumbs on his belly; chase: moonlit street, windows popping on |
| Shops and menus | a treasure bazaar | warm interior, Madder backgrounds, lamp glow | items on carpet panels; the bread counter is the brightest gold; gentle idle sparkle only |

**Distinctness:** warm mid-key (menu, run) · warm with an olive edge (Div close) · cool high-key (flight) ·
desaturated but one object (game over) · indigo and amber (night story) · Madder interior (shops).

*(az: Hər vəziyyətin öz işığı var: menyu bayram küçəsi, qaçış isti və coşqulu, Div yaxında olanda ekranın aşağısı
zeytun rəngə çalır (qaralmır), uçuş sərin və açıq-mavi, oyun sonu solğun (Cırtdan və nar parlaq), gecə nağılı
indiqo və fənər işığı, mağaza xalçalı bazar.)*

## 3. Shape Language

**Core grammar** (from the Section 1 rule)
- **Round = friendly, collectable, touchable:** bread, nar, power-up badges, buttons.
- **Squat block with soft bevels = go around it:** phaetons, carts, crates, camel bodies — heavy, wide-based,
  rounded corners: obstacles, never threatening.
- **Points only in ornament** (buta tips, arches, lattice), never aimed at the player.
- Message: the world is soft and safe; danger is being in the way, not cruelty.

**Characters**
- **Cırtdan:** big head, tiny body, oversized eyes; the tall red papaq gives a unique top contour readable at 48 px;
  slight forward lean, long legs mid-stride; cleverness in the pose (a glance back, a grin).
- **Div:** one big egg/pear mass, small head, stubby limbs, round belly, large expressive brows; threat comes from
  size and position (always behind, filling the screen bottom), not spikes; horns no sharper than a rounded nub.
- **Seven playables, one shared body:** the hat changes the **outline class**, not only the colour — tall cylinder
  (papaq), flat, domed, peaked, brimmed, wrapped, tasselled or feathered.
  *Test:* all 7 as black silhouettes in a row at 48 px are told apart without colour.

**Obstacles** — the action reads from proportions alone:
- jump = low and wide · slide = an overhead bar with a clear gap under it · change lane = tall and wide.

**Environment (carpet layer)**
- Chunky blocks with a slight hand-made wobble; arches, şəbəkə and buta are flat inset patterns, not protruding
  geometry; no outline or a thin low-contrast one; lane corridors stay clean, nothing breaks into a lane silhouette.
- One simple hero landmark per city on the horizon: Qız Qalası (Bakı), Xan sarayı (Şəki), the waterfall (Qəbələ),
  Möminə Xatın (Naxçıvan), the lighthouse (Lənkəran), Şahdağ (Quba), the petroglyph slab (Qobustan).

**Hero vs supporting**
- Hero (Cırtdan, the Div, obstacles in the path, bread, power-ups, the landmark): thick Ink outline `#2a1e24`, big
  simple masses, little internal detail.
- Supporting: no thick outline, smaller repeating shapes, ornament allowed.

**UI**
- Panels: carpet rectangles with ornamental borders and medallion (göl) corners — the carpet layer, framing content.
- Buttons and touchable controls: pills or round medallions with an Antique Gold rim (round = touchable, as round =
  collectable in the run). Counters: circular icons (bread disc, nar). Arrows and close (X): the only sharp UI shapes.

*(az: Dairəvi — dost, toplanan, toxunulan; yumşaq künclü blok — yan keçilən maneə; iti forma yalnız naxışda.
Cırtdanı papağın silueti, Divi iri yumru gülməli bədəni tanıdır; 7 personaj papaqların siluetinə görə seçilir.)*

## 4. Color System

**Primary palette**

| Name | Hex | Role |
|---|---|---|
| Player Red | `#c8221d` | Cırtdan's papaq, and a hat band on every other playable character (owner, 2026-11-25). Nothing else in the game layer uses this hue |
| Bread Gold | `#e59a2f` → `#ffd77a` | bread and pickups; its highlight is the brightest warm value in the game |
| Sandstone | `#d9a95f` | warm world base, Baku's identity |
| Caspian Blue | `#3d8fd6` | sky and sea: calm, open space |
| Granite Grey | `#7a7c80` | the road in cobbled cities: a neutral mid-value stage for the game layer |
| Madder | `#8f2b2b` (wine `#6b1f2d`) | carpets and UI panels: the traditional dye red, dark and warm, clearly apart from Player Red |
| Ink | `#2a1e24` | outlines and deepest shadows; warm, never pure black |

**Semantic accents**
- **Div Olive `#6f8a3a`:** the Div, and the danger cue — danger here is the Div himself, so his colour creeping in
  (bottom-edge tint) with a small shake and his face rising means "he's close" (owner, 2026-11-25). Comic, not red alarm.
- **Nar Crimson `#a0173f`, seed highlight `#e0405f`:** the pomegranate — abundance and life — so it means a second
  chance (the continue offer; it also stays a rare pickup in the run). Rose-crimson, apart from Player Red.
- **Power-up Turquoise `#19b3a6`, halo `#e9fffb`:** Simurq, flying carpet, boosts — tilework and sky, so "magic and
  lift"; the only cool saturated hue on the runway.
- **Night Indigo `#26305e`, Lantern `#ffb050`:** story scenes only.

**Changes to current values**
| Element | Now | New | Why |
|---|---|---|---|
| Carpet red | `#b3262a` | `#8f2b2b` | too close to the papaq |
| UI panel | `#8e1d22` | `#7e2227` | unify with Madder |
| UI gold | `#e8b23a` | Antique Gold `#c89b45` | bread owns bright gold |
| Vest trim | `#f1c34a` | Antique Gold `#c89b45` (owner, 2026-11-25) | bright gold on the player competed with bread |

**Road value:** granite `#7a7c80` and the earth trails (Qəbələ `#6b5440`, Qobustan `#7a6450`) stay in one mid-dark
value band so Bread Gold, Player Red and Turquoise read in every city.

**Per city** — the game layer and the road value never change; only carpet-layer hues and light colour do; no city
hue comes near Player Red, the Bread Gold highlight or Turquoise at full saturation.
- Köhnə Bakı: warm gold, sandstone under Caspian Blue (the reference city).
- Şəki: warm-neutral; white walls shaded cream `#e9dfcc` (below the bread highlight); roofs desaturated terracotta `#a8432c`, above eye line.
- Qəbələ: cool, dappled green; forest greens lean blue `#2f6b4f` (apart from Div Olive); trail darkest mid-value; mist in the haze.
- Naxçıvan: hot terracotta `#b5653a`; architectural turquoise muted `#4f9a94`, on walls, never a halo.
- Lənkəran: cool and wet; tea green `#5f9b4a` under a grey-blue sky; lighthouse in Madder and cream; rain low-contrast, carpet layer.
- Quba: crisp; apples green, yellow or desaturated rose (never the papaq red), decorative only; snowy Şahdağ blue-white; looms in Madder.
- Qobustan: dusty ochre rock `#8a7560`; petroglyphs in Ink; grey mud volcanoes; a strip of Caspian Blue at the edge.

**UI palette** (darker and more ornamented than the world, so the game layer stays brightest)
- Panels Madder/wine with Antique Gold borders and cream `#f0dfb4` text plates; text Ink on cream or cream on Madder, ≥ 4.5:1.
- Bright gold only on bread and currency; Player Red only on character portraits.
- Primary buttons: Turquoise or cream medallion with an Antique Gold rim.

**Colourblind backups** — no meaning is carried by hue alone.
| Pair | Fails for | Backup |
|---|---|---|
| Player Red vs Div Olive | protan, deutan | size difference, fixed positions (Div behind), outline, value gap (Div lighter) |
| Bread Gold vs Sandstone / earth trail | everyone in low light | Ink outline, spin, sparkle, floating above the road |
| Nar Crimson vs Madder UI | protan | cream plate, the crown shape, a number label |
| Turquoise vs Caspian Blue / Naxçıvan tile | tritan | round badge with icon, white halo, pulse; architecture never gets a halo |
| Div Olive tint vs grey road | deutan | shake, the Div's face rising, dust puffs (sound is the audio side's) |
| Forest / tea green vs Div Olive | deutan | the Div's outline and size; cooler forest hue |

*Test:* every city and state through deutan, protan and tritan simulation and in greyscale.

*(az: Parlaq qırmızı Cırtdanın papağınındır və hər personajın papağında bir zolaqdır; ən parlaq qızılı çörəyindir;
xalça və interfeys tünd boyaqotu qırmızısı, çərçivələr köhnə qızılı; zeytun yaşılı "Div yaxındır"; nar ikinci şans;
firuzəyi sehrli güc. Heç bir məna yalnız rəngə bağlı deyil.)*

## 5. Character Design Direction

**Player archetype:** the clever little hero — chibi proportions (head ≈ 40% of body height), big eyes with a glint,
quick and light. *Serves:* readability at speed; the comic chase (small and quick against big and clumsy).
- **Designed from the back first:** the run camera sees his back. Identity at run distance = the hat's top contour
  + the bread sack + the vest's back colour block. *Test:* a back view at 15% of screen height names the character.
- **Seven playables share one body**; the hat sets the outline class (Section 3) and carries a Player Red band.
  Costumes belong to Cırtdan and change vest, trim and hat colours, never the silhouette class.

**Telling roles apart at a glance**
| Role | Cue |
|---|---|
| Player | Player Red papaq/band, Ink outline, always bottom centre of the screen |
| The Div | Div Olive, two to three times the player's height, always behind, round and soft |
| Animals in the way (camels, horse) | wide four-legged silhouettes, warm browns, carpet saddles; characters, never threats |
| Nənə and story-only figures | appear only in story pictures and menus, never on the runway |

**Expression and pose**
- Exaggerated, snappy cartoon poses; each action's pose reads before the action lands (anticipation ≥ 1/3 s at the
  jump, the slide, a stumble).
- Face states (Cırtdan): smile · "O" mouth (jump, fright) · blink · worried brows (stumble) · tongue out (escaped
  the Div). The Div: grin, roar with club up, surprised, snoring, proud ("Hamm!").
- Squash and stretch on landing ≤ 25%; lean into lane changes ≤ 20°.
- *Test:* if a pose could read as hurt or frightened, push it toward comic surprise.

**Detail at camera distance (LOD philosophy)**
- In the run Cırtdan is ≈ 15% of the screen height: silhouette + three colour blocks (hat, vest, trousers) carry
  him; parts smaller than ~5 px on a phone (glints, buttons, patches) are for menus and story close-ups.
- Tiny parts get no ink outline (it muddies faces); faces are read from the front only in menus and the story.
- One model per character serves run, menu and story; no separate LOD meshes (they are small and few).

*(az: Cırtdan — balaca, zirək qəhrəman, iri baş və gözlər; qaçışda arxadan görünür, ona görə papağın silueti, torba
və jiletin rəngi onu tanıdır. Div — iri, yumru, həmişə arxada; dəvə və at — personaj, təhlükə yox. Pozlar mübaliğəli və
komik; qaçışda xırda detallar yox, iri formalar danışır.)*

## 6. Environment Design Language

**Architecture tied to place and history** — every city is built from what that place really looks like:
- Köhnə Bakı (İçərişəhər): golden sandstone houses, wooden eyvan balconies, şəbəkə windows, carpets drying on rails,
  copper pots by shop doors, qala gates, Qız Qalası on the skyline.
- Şəki: whitewashed river-stone walls with brick bands, red tiled roofs, deep wooden eyvans, the Xan sarayı's painted façade.
- Qəbələ: forest trail, pines and oaks, log huts, mossy boulders, the waterfall.
- Naxçıvan: flat-roofed terracotta brick with muted turquoise girih bands and pointed-arch windows; Möminə Xatın.
- Lənkəran: rows of tea bushes, citrus trees, tin-roofed houses, rain, the lighthouse.
- Quba: apple orchards behind wooden fences, carpet looms, snowy Şahdağ.
- Qobustan: rock slabs carved with dancers, boats and goats; mud volcanoes; the Caspian beyond.
- *Test:* a building or prop that could stand in any "eastern" city is replaced by one only this city has.

**Texture philosophy: hand-painted, flat, stylised** — *why:* the folk-tale picture book (Section 1) and phones.
- Colour lives in the texture; light is simple two-band toon shading with a soft rim; no normal maps, no PBR
  roughness detail, no photo textures.
- Patterns are painted (buta, carpet medallions, şəbəkə diamonds, brick, setts) at 128–256 px, tiling, with slight
  hand variation; ornament stays inside its surface, never protruding geometry.

**Prop density**
- The lane corridor holds only gameplay objects; the road surface carries no ornament.
- House fronts are dense (lanterns, pots, carpets, doors) because they frame the run at the edges.
- Density falls with distance: near houses detailed, far ones simple blocks in haze, the horizon one landmark.
- Per city: Baku and Şəki dense (bazaar town), Naxçıvan and Quba medium, Qəbələ, Lənkəran and Qobustan open (nature).

**Storytelling without text**
- The city's landmark on the horizon says where you are; the light says the time (warm afternoon in the run).
- The Div's theft shows in the world: bread scattered along the street, a torn sack in the story pictures.
- Life by the doors (a sleeping cat, a lantern, washing on a line) says people live here, so the chase is through a home.

**Legible against the characters**
- Environment stays mid-value and lower saturation behind the runner; no thick outlines on buildings; ornament
  never at lane height behind the player; walls begin at the kerb, clear of the lanes.
- *Test:* a greyscale phone screenshot shows Cırtdan, the Div, the obstacles and the bread before any wall detail.

*(az: Hər şəhər öz həqiqi memarlığı ilə qurulur; teksturalar əllə boyanmış kimi, düz, sadə işıqla; yolun zolaqları
yalnız oyun əşyaları üçündür, evlərin önü isə detallıdır; uzaq mənzərə sadələşir; personajlar fondan həmişə öndə
oxunur.)*

## 7. UI/HUD Visual Direction

**Art view**
- **Screen-space HUD, minimal in the run:** score top right; bread and nar as icon + number; pause top left;
  power-up timers on the left; carpet and boost buttons at the bottom. Menus, shops, story captions and the game-over
  card are carpet-framed panels (the carpet layer, Section 1).
- **Typography:** warm, chunky, rounded-humanist sans with full Azerbaijani (ə ğ ı ş ç ö ü) and Cyrillic coverage
  (now: Godot's default font with DejaVu Sans as fallback for symbols). Sizes at the 720 px-wide base: title 76–84,
  screen headings 50, body 28–32, minimum 22. Text over 3D carries an Ink outline.
- **Icons:** illustrated flat icons with an Ink outline, painted like the textures (bread disc, nar, buta, stone,
  carpet); round, as round means collectable/touchable (Section 3).
- **Motion:** soft springy pops (scale ≤ 1.06), slides and fades of 0.15–0.3 s; the UI shakes only for the Div cue.

**UX view**
- The run's most important information is the obstacles: HUD stays at the screen edges, never over the lanes;
  banners in the upper third, one at a time, ≤ 1.6 s; the day's-word tiles show only when a letter is taken, then fade.
- Players are 7+ and beginning readers: prefer icon + number over words wherever a word is not needed.
- Touch targets ≥ 96 px tall at the 720 px base (≈ 48 pt); nothing important within the screen's outer 24 px.
- Accessibility floor: no meaning by colour alone (Section 4 backups); no flashing; layout holds from small phones to
  tablets and desktop windows; keyboard works on desktop (no gamepad target).
- Feedback: every tap answers with a sound and a visible change; a purchase confirms; too little bread says how much is needed.

**Decided (owner, 2026-11-25): ornament on the big frames only.** Screen frames, story captions and the game-over
card are carpet-bordered; list rows inside them are plain (dark Madder plate, a thin Antique Gold line), so text
keeps its room on small phones.

*(az: Qaçışda ekran minimaldır və kənarlardadır; menyu, nağıl və oyun sonu xalça çərçivəlidir, siyahı sətirləri
sadədir; şrift iri və isti, ən kiçik yazı 22 px; uşaq üçün sözdən çox ikon və rəqəm; düymələr ən azı 96 px.)*

## 8. Asset Standards

**Art view — what is delivered and how**
- **3D:** `.glb` (glTF 2.0), e.g. from Blender; 1 unit = 1 m; origin at the feet / base centre; transforms applied;
  the runner faces −Z, figures and obstacles that meet him face +Z. Rigged characters: one skeleton, clips named
  `run`, `jump`, `slide`, `stumble`, `idle`, `fly`.
- **Images:** `.png` (sRGB). **Sound:** effects `.wav`, music `.ogg`.
- **Naming:** `[category]_[name]_[variant].[ext]` — `char_cirtdan_base.glb`, `prop_cart_long.glb`,
  `env_baku_house_a.glb`, `tex_carpet_red.png`, `ui_icon_bread.png`, `sfx_jump.wav`, `mus_run.ogg`.
  Owner deliveries go to `assets/incoming/`; placed files move to `assets/<category>/`.
- **Texture tiers:** hero characters 256–512 px · props 128–256 · tiling environment 256 · far backdrops ≤ 512 ·
  UI icons 128–256 (drawn at 2× for dense screens). Painted, flat, tiling where it repeats (Section 6).
- **Materials:** ≤ 4 per character, ≤ 3 per prop; prefer one shared palette texture per city.
- **LOD:** no LOD meshes for characters (small and few); far scenery is simplified by distance (blocks in haze).

**Technical view — the limits that bind** (Godot 4.7, Mobile renderer; the browser uses Compatibility)
- Budgets from the project: 60 fps (16.6 ms), **< 300 draw calls a frame on mid-range phones**, ≤ 512 MB memory.
  No texture-memory budget is set separately.
- Measured 2026-11-25 at 45 s into a run: 565–815 draw calls per city (down from 2000–2600 after mesh merging) —
  still **over** the 300 budget. Primitives 170–310k a frame.
- Per asset: Cırtdan ≤ 5k triangles · the Div ≤ 8k · an obstacle ≤ 3k · a house ≤ 2k; ≤ 50 live particles.
- Every unique material is a separate draw and breaks merging: new assets reuse the shared materials and textures.
- Merged chunks cut draw calls but cull coarsely (a chunk draws if any part is visible).
- Import: glTF is Godot's native 3D path; skeletal animation on imported models plays through AnimationPlayer —
  how it joins the code animator is unverified until the first rigged model arrives.

**Decided (owner, 2026-11-25): meet the 300 budget.** Far houses become simple blocks and the scenery view distance
shortens; bread draws as one batch; near houses keep their detail with fewer material kinds. Every asset change is
measured (draws per frame, per city) before it ships.

*(az: 3D — .glb, şəkil — .png, səs — .wav/.ogg; adlar `char_…`, `prop_…`, `env_…`, `tex_…`, `ui_…`; teksturalar
128–512 px; telefon büdcəsi — kadrda 300 çəkilişdən az; indi 565–815-dir, ona endiriləcək; göndərdiyin fayllar
`assets/incoming/` qovluğuna gedir.)*

## 9. Reference Direction

**How to use:** a part is checked against the one reference that owns its job; a part that looks like a copy of
any reference fails, however good it looks. Each reference does a different job.

- **R1. Azerbaijani animated films** (the Azerbaijanfilm animation tradition; the owner's reference) — *characters and surfaces*.
  - Take: flat, softly brushed backgrounds in a limited warm palette (the gouache feel behind Section 6); characters
    from a few big shapes with snappy, theatrical poses; villains played for laughs — pompous, greedy, outwitted
    (the Div's grin, "Hamm!", snoring); a storyteller's hand-made framing for the five story pictures.
  - Avoid: a flat 2D look (we are toon-shaded 3D); faded-film colour, grain or filters; reproducing any film's
    characters, costumes or scenes, including any existing Cırtdan cartoon (title, year, studio **to verify**; study only).
  - Owner to send 3–5 frames; until then this reference stays general.
- **R2. The Tabriz miniature school** (Sultan Muhammad, e.g. "The Court of Gayumars", Shahnama of Shah Tahmasp;
  spelling **to verify**) — *composition*.
  - Take: a high horizon and distance as stacked bands of flat colour (far backdrops, the flight view, the story
    pictures); small jewel accents (lapis, turquoise, madder) in the carpet layer only, never Player Red or Bread Gold;
    ornamental page borders for the story (big frames only, Section 7).
  - Avoid: miniature flatness in the run (lanes need real 3D perspective); all-over detail and tiny figures (phones,
    the draw-call budget); courtly or religious imagery; copying any painting.
- **R3. Qarabağ carpet weaving** — *ornament and the UI frame*.
  - Take: the grammar — a central medallion (göl) on a field, a main border with thin guard stripes, corner pieces —
    for UI frames, the game-over card and story captions; the natural-dye palette (madder, indigo, walnut, cream),
    the source of Madder; the buta as the signature motif.
  - Avoid: pattern behind text, list rows or lane surfaces; photo-scanned carpets; synthetic bright reds (Player Red
    is reserved); motifs of other weaving traditions. Carpet-type names **to verify** with a museum source before citing.
- **R4. İçərişəhər (Baku Old City) architecture** — *massing and street shape*.
  - Take: flat-roofed cubic sandstone houses, cantilevered wooden eyvans, şəbəkə windows; narrow streets two to three
    storeys high with a slot of Caspian sky; qala walls and gates; Qız Qalası's cylinder and buttress as the one
    skyline silhouette. Use the same method in every city: its own real massing (Section 6 test).
  - Avoid: modern Baku, souvenir kitsch, "Arabian Nights" domes; realistic decay, grime or photo texture; fine
    architectural detail at run distance (far houses are simple blocks, Section 8).
- **R5. The 3D lane-runner genre** — *timing and lane width only*.
  - Take, measured from play: camera height and tilt, lane spacing against character width, how far ahead an
    obstacle must read at each speed, the speed ramp, lane-change and jump read time.
  - Avoid everything visual: no art, characters, UI layout, logos, colour schemes or teen-graffiti style from any
    runner; per the brief, no title from the genre is named here. The look comes only from R1–R4.

*(az: R1 — Azərbaycan cizgi filmləri: boyanmış fonlar, iri formalı komik personajlar; R2 — Təbriz miniatürü: qat-qat
üfüq və səhifə çərçivəsi (yalnız fon və nağıl); R3 — Qarabağ xalçası: göl, haşiyə, buta, təbii boyalar (ekran
çərçivələri); R4 — İçərişəhər: daş evlər, eyvanlar, Qız Qalası silueti; R5 — qaçış janrı: yalnız ölçülər, rəsm yox.)*
