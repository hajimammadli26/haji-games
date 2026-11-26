"""Builds the owner's 3D asset catalogue (Azerbaijani) from the game's renders."""
import sys
from PIL import Image
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image as RLImage,
                                PageBreak, KeepTogether)

O = sys.argv[1]
OUT = sys.argv[2]
pdfmetrics.registerFont(TTFont("DV", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"))
pdfmetrics.registerFont(TTFont("DVB", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"))
MADDER = colors.HexColor("#7e2227")
GOLD = colors.HexColor("#c89b45")
TURQ = colors.HexColor("#19b3a6")
INK = colors.HexColor("#2a1e24")
CREAM = colors.HexColor("#fbf5e8")

H1 = ParagraphStyle("h1", fontName="DVB", fontSize=22, textColor=MADDER, spaceAfter=6, leading=26)
H2 = ParagraphStyle("h2", fontName="DVB", fontSize=15, textColor=MADDER, spaceBefore=4, spaceAfter=4, leading=19)
BODY = ParagraphStyle("b", fontName="DV", fontSize=9.5, leading=13, textColor=INK)
SMALL = ParagraphStyle("s", fontName="DV", fontSize=8.2, leading=11, textColor=INK)
NAME = ParagraphStyle("n", fontName="DVB", fontSize=11, leading=14, textColor=INK)
FILE = ParagraphStyle("f", fontName="DV", fontSize=8, leading=10, textColor=colors.HexColor("#1b6f68"))

items = Image.open(f"{O}/items.png").convert("RGB")
OB = ["basket", "carpet", "stall", "phaeton", "cart", "ramp", "caravan", "stump", "branch", "boulder", "salt",
      "crates", "loom", "mud", "art_boulder", "rock_arch"]
PK = ["bread", "nar", "magnet", "shoe", "double", "pole", "simurq", "letter", "buta", "stone", "halva", "finduq",
      "bottle", "tangerine", "apple", "bread_line"]
crops = {}
for i, n in enumerate(OB):
    x, y = (i % 4) * 320, (i // 4) * 260
    crops["ob_" + n] = items.crop((x + 2, y + 24, x + 318, y + 258))
for i, n in enumerate(PK):
    x, y = (i % 8) * 160, 1040 + (i // 8) * 180
    crops["pk_" + n] = items.crop((x + 4, y + 26, x + 156, y + 178))
for c in ["cirtdan", "tiqtiq", "kecel", "kendirbaz", "kosa", "peri", "melik"]:
    crops["c_" + c] = Image.open(f"{O}/c_{c}.png").convert("RGB").crop((75, 330, 330, 620))
for k in ["novruz", "winter", "sailor"]:
    crops["k_" + k] = Image.open(f"{O}/k_{k}.png").convert("RGB").crop((75, 330, 330, 620))
for city in ["baku", "sheki", "qebele", "naxcivan", "lenkeran", "quba", "qobustan"]:
    crops["city_" + city] = Image.open(f"{O}/city_{city}.png").convert("RGB").crop((0, 60, 405, 560))
crops["simurq"] = Image.open(f"{O}/simurq.png").convert("RGB").crop((60, 160, 345, 470))
crops["carpet_fly"] = Image.open(f"{O}/carpet.png").convert("RGB").crop((90, 480, 320, 690))
crops["div"] = Image.open(f"{O}/div.png").convert("RGB").crop((120, 300, 405, 700))


def img(key, w):
    im = crops[key]
    path = f"{O}/crop_{key}.png"
    im.save(path)
    return RLImage(path, width=w, height=w * im.size[1] / im.size[0])


def card(key, name, fname, spec, note, done=False):
    """One asset: its picture beside its name, file name, size, budget and notes."""
    status = '<font color="#1b6f68"><b>✓ Hazırdır (sizin modeliniz)</b></font><br/>' if done else \
        '<font color="#7e2227">☐ Modellənəcək</font><br/>'
    txt = [Paragraph(name, NAME), Paragraph(f"Fayl adı: <b>{fname}</b>", FILE), Spacer(1, 2),
           Paragraph(status + spec, SMALL), Spacer(1, 2), Paragraph(note, SMALL)]
    t = Table([[img(key, 38 * mm), txt]], colWidths=[41 * mm, 133 * mm])
    t.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"), ("BOX", (0, 0), (-1, -1), 0.6, GOLD),
                           ("BACKGROUND", (1, 0), (1, 0), CREAM), ("LEFTPADDING", (0, 0), (-1, -1), 5),
                           ("TOPPADDING", (0, 0), (-1, -1), 4), ("BOTTOMPADDING", (0, 0), (-1, -1), 4)]))
    return KeepTogether([t, Spacer(1, 5)])


def section(title, intro):
    return [Paragraph(title, H1), Paragraph(intro, BODY), Spacer(1, 6)]


S = []
S += [Paragraph("Cırtdan: Köhnə Bakıda Qaçış", H1),
      Paragraph("3D modellər kataloqu: oyundakı hər şey, kateqoriyalara bölünmüş", H2),
      Paragraph("Bu sənəd oyunda olan bütün 3D əşyaları göstərir: indiki görünüşü (kodla qurulmuş), fayl adı, ölçüsü, "
                "telefon üçün limit və nəyə diqqət etmək lazım olduğu. Hər birini ayrı-ayrı modelləyib göndərin, mən "
                "oyuna qoşum.", BODY), Spacer(1, 8),
      Paragraph("Hamısı üçün qaydalar", H2)]
rules = [["Format", ".glb (GLB). FBX də olar, mən çevirərəm."],
         ["Ölçü", "1 vahid = 1 metr. Cırtdanın boyu ≈ 1,45–1,8 m. Hər kartda hündürlük yazılıb."],
         ["İstiqamət", "Ayağı/oturacağı yerdə (mərkəz altda). Personajlar düz önə baxsın."],
         ["Telefon limiti", "Personaj ≤ 5 000 üçbucaq · Div ≤ 8 000 · maneə ≤ 3 000 · ev ≤ 2 000 · toplanan əşya ≤ 800."],
         ["Tekstur", "512 px-dən böyük olmasın (kiçik əşyalar 256 px). Material: ≤ 3–4."],
         ["Animasiya", "Personajlar: skelet + run (qaçış). Varsa: jump, slide, idle, fall. Qalanlarını mən əlavə edərəm."],
         ["Üslub", "Cizgi filmi üslubu, isti rənglər. Qırmızı papaq rəngi yalnız Cırtdanındır; parlaq qızılı yalnız çörəyindir."],
         ["Göndərmək", "github.com/hajimammadli26/haji-games/upload/main/assets/incoming → faylı atın → Commit changes → mənə yazın."]]
t = Table([[Paragraph(f"<b>{a}</b>", SMALL), Paragraph(b, SMALL)] for a, b in rules], colWidths=[32 * mm, 142 * mm])
t.setStyle(TableStyle([("GRID", (0, 0), (-1, -1), 0.4, GOLD), ("BACKGROUND", (0, 0), (0, -1), CREAM),
                       ("VALIGN", (0, 0), (-1, -1), "TOP")]))
S += [t, Spacer(1, 8), Paragraph("Tövsiyə olunan sıra", H2),
      Paragraph("1) Yağ çörəyi (ən çox görünən) → 2) Nar və 5 güclənmə → 3) Bakının maneələri (səbət, xalça ipi, "
                "piştaxta, fayton, araba, rampa, karvan) → 4) Bakı evləri və Qız Qalası → 5) qalan personajlar → "
                "6) digər şəhərlərin maneə və binaları.", BODY),
      Paragraph("Kateqoriyalar: 1. Personajlar və heyvanlar · 2. Toplanan əşyalar · 3. Maneələr · "
                "4. Binalar və mənzərə (şəhər-şəhər)", BODY), PageBreak()]

S += section("1. Personajlar və heyvanlar", "Hər personaj üçün skelet (rig) lazımdır. Ən azı qaçış animasiyası olsun.")
CH = [("c_cirtdan", "Cırtdan (əsas qəhrəman)", "char_cirtdan.glb", "Boy ≈ 1,8 m (papaqla) · ≤ 5 000 üçbucaq · animasiyalar: run, jump, slide, idle, fall",
       "Oyundadır. Yeni geyim (Novruz, Qış, Dənizçi) üçün ayrıca model lazımdır.", True),
      ("c_tiqtiq", "Tıq-Tıq xanım", "char_tiqtiq.glb", "Boy ≈ 1,6 m · ≤ 5 000 · run, jump, slide, idle",
       "Qız: uzun hörüklər, çəhrayı bantlar, ətək, yaşıl jilet. Papağında nazik qırmızı zolaq.", False),
      ("c_kecel", "Keçəl", "char_kecel.glb", "Boy ≈ 1,6 m · ≤ 5 000 · run, jump, slide, idle",
       "Keçəl baş, iri qulaqlar, bic gülüş, şərab rəngli jilet.", False),
      ("c_kendirbaz", "Kəndirbaz", "char_kendirbaz.glb", "Boy ≈ 2,0 m (hündür, arıq) · ≤ 5 000 · run, jump, slide, idle",
       "Ağ hündür papaq, narıncı jilet, çiynində uzun tarazlıq çubuğu.", False),
      ("c_kosa", "Kosa", "char_kosa.glb", "Boy ≈ 1,7 m · ≤ 5 000 · run, jump, slide, idle",
       "Novruz obrazı: uca şiş papaq və zınqırov, ağ saqqal (ağız görünsün), yumru bədən.", False),
      ("c_peri", "Pəri qız", "char_peri.glb", "Boy ≈ 1,6 m · ≤ 5 000 · run, jump, slide, idle (+qanad çırpma)",
       "Bənövşəyi-çəhrayı qanadlar, uzun saç, açıq göy paltar.", False),
      ("c_melik", "Məlikməmməd", "char_melik.glb", "Boy ≈ 1,9 m · ≤ 5 000 · run, jump, slide, idle",
       "Tac, plaş, kürəyində qılınc, göy jilet. Cəsur şahzadə.", False),
      ("k_novruz", "Cırtdan: Novruz geyimi", "char_cirtdan_novruz.glb", "Cırtdanla eyni skelet · ≤ 5 000",
       "Yaşıl jilet, papaqda səməni budağı.", False),
      ("k_winter", "Cırtdan: Qış geyimi", "char_cirtdan_winter.glb", "Cırtdanla eyni skelet · ≤ 5 000",
       "Krem rəngli qış papağı, qəhvəyi jilet.", False),
      ("k_sailor", "Cırtdan: Dənizçi geyimi", "char_cirtdan_sailor.glb", "Cırtdanla eyni skelet · ≤ 5 000",
       "Ağ dənizçi papağı və köynəyi, göy şalvar.", False),
      ("div", "Div (təqib edən nəhəng)", "char_div.glb", "Boy ≈ 3,2 m · ≤ 8 000 · run, idle, catch (tutma)",
       "Oyundadır. Arxadan baxanda da Div olduğu bilinsin (buynuzlar, rəng).", True),
      ("simurq", "Simurq quşu", "char_simurq.glb", "Qanad açıqlığı ≈ 2 m · ≤ 3 000 · fly (qanad çırpma)",
       "Qızılı-firuzəyi lələklər, uzun quyruq, Cırtdanı belindən tutan uzun ayaqlar.", False),
      ("ob_caravan", "Dəvə (karvanda)", "char_camel.glb", "Hündürlük ≈ 2,2 m (üstündə qaçılır) · ≤ 3 000 · walk",
       "Üstündə xalça yəhər. Karvanda 5 dəvə ard-arda gəlir.", False),
      ("ob_phaeton", "At (fayton atı)", "char_horse.glb", "Hündürlük ≈ 1,8 m · ≤ 3 000 · idle (başını yelləyir)",
       "Faytonla birlikdə və ya ayrıca model.", False)]
for c in CH:
    S.append(card(*c))
S.append(PageBreak())

S += section("2. Toplanan əşyalar", "Yerdən və havadan yığılan şeylər. Kiçikdirlər, ≤ 800 üçbucaq və 256 px tekstur kifayətdir. "
                                     "Oyunda fırlanır, ona görə hər tərəfdən gözəl görünsün.")
PKS = [("pk_bread", "Yağ çörəyi (əsas pul)", "pickup_bread.glb", "Diametr ≈ 0,5 m · ≤ 500 üçbucaq",
        "Oyunda ən çox görünən şey: ekranda eyni anda 30–60 ədəd. Parlaq qızılı, üstü naxışlı, şişkin."),
       ("pk_nar", "Nar", "pickup_nar.glb", "≈ 0,45 m · ≤ 500", "Nadir: oyunu davam etdirmək üçün. Al qırmızı, tacı ilə."),
       ("pk_magnet", "Nənənin sinisi (maqnit)", "pickup_magnet.glb", "≈ 0,7 m · ≤ 800",
        "Bulkalarla dolu mis sini. Firuzəyi nişan/halqa oyunda əlavə olunur."),
       ("pk_shoe", "Sehrli çarıq (hündür tullanma)", "pickup_shoe.glb", "≈ 0,6 m · ≤ 800", "Ucu qalxıq çarıq, qanadlı."),
       ("pk_double", "Qoşa təndir (ikiqat xal)", "pickup_double.glb", "≈ 0,7 m · ≤ 800", "İki kiçik təndir, içində od və çörək."),
       ("pk_pole", "Kəndirbaz çubuğu", "pickup_pole.glb", "Uzunluq ≈ 1,2 m · ≤ 600", "Zolaqlı tarazlıq çubuğu, ucları qotazlı."),
       ("pk_simurq", "Simurq lələyi (uçuş)", "pickup_feather.glb", "≈ 0,7 m · ≤ 600", "Alov rəngli iri lələk."),
       ("pk_letter", "Hərf medalyonu", "pickup_letter.glb", "≈ 0,6 m · ≤ 400", "Krem dairə, qızılı haşiyə. Hərfin özünü oyun yazır, boş saxlayın."),
       ("pk_buta", "Buta daşı", "pickup_buta.glb", "≈ 0,5 m · ≤ 500", "Buta naxışı formasında daş (həftəlik ov)."),
       ("pk_stone", "Sehrli daş", "pickup_stone.glb", "≈ 0,45 m · ≤ 400", "Bənövşəyi kristal (Pəri qızı açır)."),
       ("pk_halva", "Şəki halvası (Şəki)", "pickup_halva.glb", "≈ 0,4 m · ≤ 400", "Romb formalı, üstü düyü toru naxışlı."),
       ("pk_finduq", "Fındıq (Qəbələ)", "pickup_hazelnut.glb", "≈ 0,4 m · ≤ 400", "Üç fındıq, yaşıl qabıqlı."),
       ("pk_bottle", "Badamlı suyu (Naxçıvan)", "pickup_water.glb", "≈ 0,45 m · ≤ 400", "Mineral su şüşəsi."),
       ("pk_tangerine", "Naringi (Lənkəran)", "pickup_tangerine.glb", "≈ 0,4 m · ≤ 400", "Yarpaqlı naringi."),
       ("pk_apple", "Quba alması (Quba)", "pickup_apple.glb", "≈ 0,4 m · ≤ 400", "Qırmızı-narıncı alma (Cırtdanın qırmızısı deyil)."),
       ("carpet_fly", "Uçan xalça", "prop_flying_carpet.glb", "1,4 × 1,9 m · ≤ 1 000",
        "Cırtdan üstündə üzüüstə uzanır. Kənarları qıvrılmış, ucları saçaqlı xalça.")]
for c in PKS:
    S.append(card(c[0], c[1], c[2], c[3], c[4]))
S.append(PageBreak())

S += section("3. Maneələr", "Küçədə qarşıya çıxan şeylər. Ölçülər vacibdir: oyunun qaydası bu hündürlüklərə bağlıdır "
                             "(üstündən tullan, altından sürüş, yan keç). ≤ 3 000 üçbucaq.")
OBS = [("ob_basket", "Səbətlər (Bakı, Şəki, Lənkəran)", "prop_baskets.glb", "En 1,9 m · hündürlük 0,85 m · uzunluq 1,1 m",
        "Üstündən TULLANILIR. Hörmə səbət, küpə, qarpız."),
       ("ob_carpet", "Asılmış xalça (xalça ipi)", "prop_carpet_rope.glb", "En 2 m · alt kənar 1,15 m · üst 2,6 m",
        "Altından SÜRÜŞÜLÜR. İki dirək, ip, xalça; aşağıda qotazlar boşluğu göstərir."),
       ("ob_stall", "Bazar piştaxtası", "prop_stall.glb", "En 1,9 m · hündürlük 3 m · uzunluq 1,5 m",
        "YAN KEÇİLİR (toqquşanda oyun bitir). Zolaqlı çətir, meyvələr."),
       ("ob_phaeton", "Fayton (atla)", "prop_phaeton.glb", "En 1,7 m · hündürlük 2,4 m · uzunluq 5,6 m",
        "YAN KEÇİLİR. Təkərlər fırlanır (ayrı hissə olsun)."),
       ("ob_cart", "Yük arabası (samanlı)", "prop_cart.glb", "En 1,8 m · üstü 1,6 m · uzunluq 6 m",
        "Damında QAÇMAQ olur: üstü düz olsun."),
       ("ob_ramp", "Rampa", "prop_ramp.glb", "En 1,6 m · 0 → 1,6 m · uzunluq 4 m", "Arabanın damına çıxmaq üçün taxta rampa."),
       ("ob_stump", "Kötük (Qəbələ)", "prop_stump.glb", "Hündürlük ≈ 0,85 m", "Səbətin yerinə: tullanılır. Göbələk, köklər."),
       ("ob_branch", "Budaq (Qəbələ)", "prop_branch.glb", "Alt kənar 1,15 m", "Xalçanın yerinə: altından sürüşülür."),
       ("ob_boulder", "Qaya (Qəbələ)", "prop_boulder.glb", "Hündürlük ≈ 3 m", "Piştaxtanın yerinə: yan keçilir. Mamırlı."),
       ("ob_salt", "Duz qayası (Naxçıvan)", "prop_salt.glb", "Hündürlük ≈ 0,85 m", "Səbətin yerinə: tullanılır. Duz kristalları."),
       ("ob_crates", "Alma yeşikləri (Quba)", "prop_apple_crates.glb", "Hündürlük ≈ 0,85 m", "Səbətin yerinə: tullanılır."),
       ("ob_loom", "Xalça dəzgahı (Quba)", "prop_loom.glb", "Hündürlük ≈ 3 m", "Piştaxtanın yerinə: yan keçilir."),
       ("ob_mud", "Palçıq vulkanı (Qobustan)", "prop_mud_volcano.glb", "Hündürlük ≈ 0,85 m", "Səbətin yerinə: tullanılır. Üstündə qabarcıq."),
       ("ob_art_boulder", "Qayaüstü təsvirli daş (Qobustan)", "prop_petroglyph.glb", "Hündürlük ≈ 3 m",
        "Piştaxtanın yerinə: yan keçilir. Üzərində qədim insan və heyvan təsvirləri."),
       ("ob_rock_arch", "Qaya tağı (Qobustan)", "prop_rock_arch.glb", "Alt kənar 1,15 m", "Xalçanın yerinə: altından sürüşülür.")]
for c in OBS:
    S.append(card(c[0], c[1], c[2], c[3], c[4]))
S.append(PageBreak())

S += section("4. Binalar və mənzərə (şəhər-şəhər)",
             "Küçənin iki tərəfində evlər, arxada məşhur yerlər. Ev ≤ 2 000 üçbucaq, hər şəhər üçün 2–4 ev variantı kifayətdir. "
             "Evin küçəyə baxan tərəfi vacibdir; arxası sadə ola bilər. Ev eni ≈ 6–9 m, hündürlüyü 6–12 m.")
CITIES = [("baku", "Köhnə Bakı (İçərişəhər)",
           "Evlər: env_baku_house_a/b/c.glb — qum daşı, düz dam, dişli kənar, taxta şüşəbənd eyvanlar, ağac qapılar.<br/>"
           "Məşhur yerlər: env_baku_tower.glb (Qız Qalası, ≈ 30 m, ≤ 4 000), env_baku_wall.glb (qala divarı), "
           "env_shirvanshah.glb (Şirvanşahlar sarayının günbəzləri).<br/>"
           "Detallar: fənər, gül dibçəyi, samovar, mis küpə, skamya, paltar ipi (hər biri ≤ 300)."),
          ("sheki", "Şəki", "Evlər: env_sheki_house_a/b.glb — ağ divar, qırmızı kirəmit dam, kərpic zolaqlar, şəbəkə pəncərələr.<br/>"
           "Məşhur yer: env_sheki_palace.glb (Xan sarayı, şəbəkə fasad). Arxada Qafqaz dağları, çinar ağacları."),
          ("qebele", "Qəbələ", "Evlər əvəzinə meşə: env_pine.glb, env_oak.glb (≤ 800), fındıq kolu.<br/>"
           "Məşhur yer: env_waterfall.glb (Yeddi gözəl şəlaləsi, qaya ilə). Arxada qarlı dağlar."),
          ("naxcivan", "Naxçıvan", "Evlər: env_nax_house_a/b.glb — kərpic, firuzəyi kaşı zolaqlar, sivri tağlı pəncərələr.<br/>"
           "Məşhur yerlər: env_momine_khatun.glb (Möminə Xatın türbəsi, onbucaqlı), İlandağ (iki buynuzlu dağ)."),
          ("lenkeran", "Lənkəran", "Evlər: env_lenk_house.glb — dirəklər üstündə taxta ev, qalay dam.<br/>"
           "Mənzərə: çay terrasları, env_tangerine_tree.glb. Məşhur yer: env_lighthouse.glb (mayak, ağ-qırmızı)."),
          ("quba", "Quba", "Evlər: env_quba_house.glb — taxta ev, eyvan, yaşıl dam.<br/>"
           "Mənzərə: env_apple_tree.glb (alma bağı). Məşhur yer: Şahdağ (qarlı dağ, arxa planda)."),
          ("qobustan", "Qobustan", "Evlər yoxdur: qayalar (env_qob_rock_a/b.glb, Böyükdaş kimi yastı).<br/>"
           "Mənzərə: palçıq vulkanları, Xəzər dənizi sahili.")]
for key, name, note in CITIES:
    t = Table([[img("city_" + key, 52 * mm), [Paragraph(name, NAME), Spacer(1, 3), Paragraph(note, SMALL)]]],
              colWidths=[55 * mm, 119 * mm])
    t.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"), ("BOX", (0, 0), (-1, -1), 0.6, GOLD),
                           ("BACKGROUND", (1, 0), (1, 0), CREAM), ("TOPPADDING", (0, 0), (-1, -1), 4)]))
    S += [KeepTogether([t, Spacer(1, 6)])]


def footer(c, d):
    c.saveState()
    c.setFont("DV", 8)
    c.setFillColor(GOLD)
    c.drawString(18 * mm, 10 * mm, "Cırtdan · 3D modellər kataloqu")
    c.drawRightString(192 * mm, 10 * mm, str(d.page))
    c.restoreState()


doc = SimpleDocTemplate(OUT, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=15 * mm,
                        bottomMargin=16 * mm, title="Cırtdan — 3D modellər kataloqu")
doc.build(S, onFirstPage=footer, onLaterPages=footer)
print("ok", OUT)
