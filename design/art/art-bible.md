# Art Bible: Cırtdan: Köhnə Bakıda Qaçış

> **Status**: Draft
> **Owned By**: art-director
> **Last Updated**: 2026-11-25
> **Art Director Sign-Off (AD-ART-BIBLE)**: [Not yet reviewed]

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

[To be designed] — the player character's visual archetype, how players tell
enemies, NPCs and allies apart at a glance, expression and pose style, and how
much detail survives at game camera distance (LOD philosophy).

## 6. Environment Design Language

[To be designed] — architectural style and its tie to the world's culture,
texture philosophy (painted, PBR or stylised, and why), prop density rules per
area type, and environmental storytelling guidelines.

## 7. UI/HUD Visual Direction

[To be designed] — diegetic versus screen-space HUD, typography (personality,
weight, size hierarchy, minimum readable size), iconography style, UI animation
feel, and any art-direction versus readability conflict and how it was decided.

## 8. Asset Standards

[To be designed] — file formats, naming convention, texture resolution tiers,
LOD levels, export settings, and the engine's hard limits (poly budgets per
asset category, texture memory, material slots). Where an art preference and a
technical limit disagree, record both and the trade-off chosen.

## 9. Reference Direction

[To be designed] — 3–5 references (games, films, art styles or artists). For
each: the specific element to take from it, and what to avoid so the result
does not read as a copy.
