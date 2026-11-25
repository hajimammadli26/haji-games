# Buraxılış siyahısı: Cırtdan 1.0.0, Google Play (sonra App Store)

Hazırlanıb: 2026-11-25. Bu siyahıda **yalnız sahibin (sizin) özünüzün edə biləcəyi** addımlar var: hesablar, açarlar, imzalı build.
Mağaza mətnləri, şəkillər və məxfilik siyasəti artıq hazırdır: `production/release/`.

## Versiya

- İndi `export_presets.cfg`-də: `version/code=1`, `version/name="0.1.0"`.
- **Tövsiyə: `version/name="1.0.0"`, `version/code=1`.** Play-ə hər yeni yükləmədə code **1 artırılmalıdır** (2, 3, ...). Bu, sınaq yükləmələrinə də aiddir. Bir dəfə istifadə olunmuş code bir daha istifadə oluna bilməz.
- Play-ə gedən build hansı commit-dən yığılıbsa, həmin commit-ə `v1.0.0` tag-ı qoyun. Tag sonradan başqa commit-ə köçürülmür. Düzəliş lazım olsa, o artıq 1.0.1 olur.
- `package/unique_name="com.hajigames.cirtdan"`: ilk yükləmədən sonra **heç vaxt dəyişmir**. Uyğun olduğunu indi yoxlayın.

## Google Play: addımlar

1. **Play Console hesabı** açın: https://play.google.com/console. Birdəfəlik ödəniş **$25**, şəxsiyyət təsdiqi lazımdır. Şirkət hesabı üçün D-U-N-S nömrəsi də istənir.
   - Diqqət: yeni **şəxsi** hesablarda Google production-a çıxmazdan əvvəl **qapalı sınaq** tələb edir: **ən azı 12 sınaqçı, 14 gün** ardıcıl. Planı buna görə qurun (addım 7).
2. **Yükləmə açarı (upload keystore)** yaradın. Bunu öz kompüterinizdə edin, buludda yox. Java (JDK 17) quraşdırılmalıdır:
   ```
   keytool -genkeypair -v -keystore cirtdan-upload.jks -alias cirtdan -keyalg RSA -keysize 2048 -validity 10000
   ```
   - Parolu və `cirtdan-upload.jks` faylını **ömürlük** saxlayın: parol menecerində və bir ehtiyat nüsxədə (məsələn, şifrəli USB).
   - Faylı **heç vaxt git-ə qoymayın**. Tövsiyə: `.gitignore`-a `*.jks` və `*.keystore` sətirlərini əlavə edin (indi orada yoxdur).
   - Play-də "Play App Signing" açıq olacaq: tətbiqi Google öz açarı ilə imzalayır, sizin açarınız yalnız yükləmə üçündür. İtirsəniz, Google dəstəyi vasitəsilə yeni yükləmə açarı almaq olar, amma bu vaxt aparır.
3. **Android ixracını hazırlayın.** Godot 4.7.2 redaktorunda, öz kompüterinizdə:
   1. Android Studio-nu (və ya yalnız Android SDK command-line tools-u) və JDK 17-ni quraşdırın.
   2. Editor → Editor Settings → Export → Android: **Java SDK Path** və **Android SDK Path**.
   3. Project → **Install Android Build Template**.
   4. Project → Export → Android:
      - Gradle Build → **Use Gradle Build: On**, **Export Format: AAB**
      - Version → Code `1`, Name `1.0.0`
      - Keystore → **Release**: `cirtdan-upload.jks` faylının yolu, User `cirtdan`, Password: sizin parolunuz.
        Godot bunları `.godot/export_credentials.cfg` faylında saxlayır. Bu fayl git-ə düşmür, `export_presets.cfg`-ə yazılmır.
        Başqa yol: mühit dəyişənləri `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`.
      - Permissions → **Internet**: yalnız liderlər cədvəli açıqdırsa (addım 4).
   5. **Export Project** → "Export With Debug" **söndürülmüş** → `cirtdan-1.0.0-1.aab`.
   - Niyə burada yox: bizim bulud mühitində tam Android SDK yoxdur, çünki dl.google.com bağlıdır. Ona görə AAB-ni ya siz redaktorda yığırsınız, ya da GitHub Actions yığır:
     `production/release/android-release.yml.draft` (hələ söndürülüb). Onu işə salmaq üçün:
     1. Repo Settings → Secrets bölməsinə `ANDROID_UPLOAD_KEYSTORE_BASE64`, `ANDROID_UPLOAD_KEY_ALIAS`, `ANDROID_UPLOAD_KEY_PASSWORD` əlavə edin.
     2. Faylı `.github/workflows/android-release.yml` adı ilə köçürün.
     3. Actions → "Android release (AAB)" → Run.
4. **Liderlər cədvəli barədə qərar verin** (ətraflı: `store-listing.md` §5).
   - **Tövsiyə: 1.0-da AÇIQ**, Worker deploy olunubsa:
     - `project.godot`-da `cirtdan/online/leaderboard_url` = Worker ünvanı (`https://…workers.dev`)
     - Android ixracında Permissions → **Internet: On**
     - GitHub Actions draft-ı `leaderboard_url` sahəsi doldurulanda hər ikisini özü edir.
     - Data safety: install ID, ləqəb kodu, xal, məsafə, şəhər bəyan olunur.
   - **Bağlı da olar**, əgər Worker hələ deploy olunmayıbsa: URL boş qalır, Data safety-də "No data collected" seçilir. Bu halda təsvirlərdəki liderlər cümləsini silin.
5. **Tətbiqi yaradın** (Play Console → Create app): ad `Cırtdan: Köhnə Bakıda Qaçış`, dil az-AZ, **Game**, **Free**. Bəyanatları təsdiqləyin.
6. **Daxili sınaq (Internal testing)** ilə başlayın: AAB-ni yükləyin, öz e-poçtunuzu sınaqçı kimi əlavə edin. Play-dən endirib real telefonda yoxlayın:
   - quraşdırma və açılış
   - 4 dil
   - səs
   - ekranın kəsilməməsi
   - fon/geri qayıtma (pause)
   - internetsiz oyun
7. **Qapalı sınaq (Closed testing):** 12+ sınaqçı (ailə, dostlar), 14 gün. Sonra Console-da **production-a giriş** üçün müraciət edin.
8. **App content (Policy) formalarını** doldurun (cavablar `store-listing.md`-dədir):
   - Privacy policy URL
   - Ads: **No**
   - App access: hər şey açıqdır
   - **Content rating** (IARC)
   - **Target audience**: **13-15, 16-17, 18+**. 13 yaşdan kiçik qrupları **işarələməyin**. Oyun hamı üçündür, amma Families proqramında deyil.
   - **"Could your app unintentionally appeal to children?"**: cizgi üslubuna görə Google bunu soruşa bilər. Düzgün cavab verin: oyun bütün yaşlar üçündür, uşaqlar üçün nəzərdə tutulmayıb.
   - Mağaza səhifəsində **"uşaqlar üçün"** yazılmamalıdır (heç bir dildə). Yalnız "hər yaş üçün" və "bütün ailə üçün" yazılır. Mətnlər artıq buna uyğundur.
   - **Data safety**
   - News, Government, Financial, Health: hamısına **No**
9. **Məxfilik siyasətini dərc edin:**
   - `[OWNER EMAIL]`, `[DEVELOPER NAME]`, `[DATE]` yerlərini doldurun.
   - `production/release/privacy-policy.html` faylını Render saytının **`site` branch-ına `privacy.html` adı ilə** qoyun. `tools/publish_web.sh` yalnız `index*` fayllarını əvəz edir, bu faylı silmir.
   - Ünvan: **https://cirtdan.onrender.com/privacy.html**. Bu ünvanı Play-də göstərin.
   - Tövsiyə: bu link oyunun içində də (Ayarlar) olsun. Bu, proqramçının işidir.
10. **Store listing:** `store-listing.md`-dən 4 dildə ad, qısa və tam təsvir, kateqoriya (Games › Arcade), əlaqə e-poçtu.
    Şəkillər:
    - ikon: `graphics/app-icon-512.png`
    - feature graphic: `graphics/feature-graphic-1024x500.png`
    - 6 ekran görüntüsü: `screenshots/`
    Tərcümələri doğma dil daşıyıcısına yoxlatdırın.
11. **Production-a buraxın:** ölkələri seçin, mərhələli buraxılış (məsələn, 20%) edin, ilk 72 saatda Android vitals-da çökmələrə baxın. Yoxlama bir neçə gün çəkə bilər.
12. Play Console "target API level" xəbərdarlığı versə, buna Godot 4.7.2-nin hədəf SDK-sı səbəb olur. Xəbərdarlığı bizə göstərin, birlikdə həll edək.

## App Store (sonra)

1. **Apple Developer Program**: **$99/il**.
2. iOS build üçün **Mac + Xcode** lazımdır (Godot Xcode layihəsi ixrac edir). Mac yoxdursa, **Codemagic** kimi bulud macOS xidmətindən istifadə edin. Açarları (sertifikat, provisioning) orada saxlayın.
3. **Kids Category seçməyin**: oyun hamı üçündür.
   - Yaş reytinqi anketi, çox güman, **4+** verəcək.
   - Kateqoriya: Games › Arcade (və ya Casual).
4. **App Privacy**: leaderboard söndürülübsə "Data Not Collected". Açıqdırsa: "Gameplay Content" və "User ID" (identity ilə bağlı deyil, izləmə üçün istifadə olunmur).
5. Ekran görüntüləri yeni ölçüdə lazımdır (məsələn, 1290x2796). Eyni əmrlərlə `--resolution` dəyişib yığmaq olar.

---

## Buraxılış qapısı (release-checklist, qısa)

| Bölmə | Vəziyyət |
|---|---|
| Kod | `src/`-də 20 `.gd` fayl yoxlanıldı: TODO 0, FIXME 0, HACK 0 |
| Testlər | gdUnit4 dəsti və `.github/workflows/tests.yml` var. Nəticələr: **NOT ASSESSED** (CI çıxışı oxunmayıb) |
| Açıq baglar | **NOT ASSESSED**: `production/qa/bugs/` yoxdur |
| Sertifikasiya | **NOT ASSESSED**: `platform.cert_tier` təyin olunmayıb. Google Play mobil mağazadır, onun tələbləri yuxarıdakı addımlardadır |
| Mobil cihaz | Toxunma idarəsi müxtəlif ekranlarda, fon/geri qayıtma, batareya: addım 6-da real telefonda yoxlanmalıdır |
| İcazələr | Yalnız INTERNET (yalnız variant B). Başqa icazə yoxdur |
| IAP / reklam | Yoxdur |

**Go / No-Go: NOT ASSESSED.** Səbəblər: bag qeydləri yoxdur, test nəticəsi oxunmayıb, imzalı AAB hələ yığılmayıb və real telefonda yoxlanmayıb.
