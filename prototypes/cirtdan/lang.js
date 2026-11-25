// PROTOTYPE - NOT FOR PRODUCTION
// Player-facing text for Cırtdan: Köhnə Bakıda Qaçış. Azerbaijani is the source language: each key
// is the Azerbaijani string exactly as it appears in index.html, with ${...} template parts written
// as named placeholders ({n} = a single number). A missing language or key falls back to the key
// itself (Azerbaijani). The word-hunt words (WORDS) are Azerbaijani on purpose and are not here.
//
// Glossary used throughout (keep consistent when adding strings):
//   Cırtdan      tr Cırtdan          en Jirtdan            ru Джыртдан
//   Div          tr Dev              en the Div            ru Див
//   Nənə         tr Nene             en Grandma            ru бабушка
//   Simurq       tr Simurg           en Simurgh            ru Симург
//   Novruz       tr Nevruz           en Novruz             ru Новруз
//   yağ çörəyi   tr yağlı çörek      en butter bread       ru сдобный хлеб
//   nar          tr nar              en pomegranate        ru гранат
//   uçan xalça   tr uçan halı        en flying carpet      ru ковёр-самолёт
//   təndir       tr tandır           en tandir             ru тендир
//   çarıq        tr çarık            en shoes              ru чарыхи
//   tapşırıq     tr görev            en mission            ru задание
//   vurğu (x)    tr çarpan           en multiplier         ru множитель
// Russian count phrases use "noun: {n}" or "×{n}" so they read correctly for any number
// (one/few/many) without plural rules; English uses "butter bread" as an uncountable currency.
window.LANG = {
  langs: ['az', 'tr', 'en', 'ru'],
  names: { az: 'Azərbaycan', tr: 'Türkçe', en: 'English', ru: 'Русский' },
  t: {
    // added with the playtest fixes: touch versions without key hints, the pause buttons, purchase confirm
    'Təsdiq?': { tr: 'Onayla?', en: 'Sure?', ru: 'Точно?' },
    'Davam': { tr: 'Devam', en: 'Resume', ru: 'Дальше' },
    'Davam  P': { tr: 'Devam  P', en: 'Resume  P', ru: 'Дальше  P' },
    'Menyu': { tr: 'Menü', en: 'Menu', ru: 'Меню' },
    'Menyu  Q': { tr: 'Menü  Q', en: 'Menu  Q', ru: 'Меню  Q' },
    'Yenidən qaç': { tr: 'Tekrar koş', en: 'Run again', ru: 'Ещё раз' },
    'Keç': { tr: 'Geç', en: 'Skip', ru: 'Пропустить' },
    'Toxun': { tr: 'Dokun', en: 'Tap', ru: 'Коснись' },
    'Nar ilə davam et ({n})': { tr: 'Narla devam et ({n})', en: 'Continue ({n})', ru: 'Продолжить ({n})' },
    '{page} / {pages}   Toxun: davam': { tr: '{page} / {pages}   Dokun: devam', en: '{page} / {pages}   Tap: next', ru: '{page} / {pages}   Коснись: дальше' },
    '{got} / {need} · bir qaçışda · mükafat: {prize}': { tr: '{got} / {need} · tek koşuda · ödül: {prize}', en: '{got} / {need} · in one run · prize: {prize}', ru: '{got} / {need} · за один забег · награда: {prize}' },
    'səndə: {n} · bir toqquşmadan qoruyur': { tr: 'sende: {n} · bir çarpmadan korur', en: 'you have: {n} · saves you from one crash', ru: 'у тебя: {n} · спасает от одного удара' },
    'səndə: {n} · startda bir toxun': { tr: 'sende: {n} · başlangıçta bir dokun', en: 'you have: {n} · one tap at the start', ru: 'у тебя: {n} · одно касание на старте' },
    '{lv}/{max} · {n} s · {what}': { tr: '{lv}/{max} · {n} sn · {what}', en: '{lv}/{max} · {n} s · {what}', ru: '{lv}/{max} · {n} с · {what}' },
    // ---- Title, page title, controls ------------------------------------------------------
    'Cırtdan: Köhnə Bakıda Qaçış': { tr: 'Cırtdan: Eski Bakü\'de Kaçış', en: 'Jirtdan: Run Through Old Baku', ru: 'Джыртдан: Побег по старому Баку' },
    'Cırtdan': { tr: 'Cırtdan', en: 'Jirtdan', ru: 'Джыртдан' },
    'Köhnə Bakıda Qaçış': { tr: 'Eski Bakü\'de Kaçış', en: 'Run Through Old Baku', ru: 'Побег по старому Баку' },
    '«Mən balacayam, amma ağlım böyükdür!»': { tr: '«Ben küçüğüm ama aklım büyük!»', en: '“I may be small, but my mind is big!”', ru: '«Я маленький, но ум у меня большой!»' },
    'Söz ovu: hərfləri yolda yığ': { tr: 'Kelime avı: harfleri yolda topla', en: 'Word hunt: grab letters on the road', ru: 'Охота за словом: собирай буквы' },
    'Rekord: {n}': { tr: 'Rekor: {n}', en: 'Best: {n}', ru: 'Рекорд: {n}' },
    'Sürüşdür ← →  və ya oxlar: zolaq dəyiş': { tr: 'Kaydır ← →  ya da oklar: şerit değiştir', en: 'Swipe ← →  or arrows: change lane', ru: 'Свайп ← →  или стрелки: смена полосы' },
    'Sürüşdür ↑  və ya ↑ / Boşluq: tullan': { tr: 'Kaydır ↑  ya da ↑ / Boşluk: zıpla', en: 'Swipe ↑  or ↑ / Space: jump', ru: 'Свайп ↑  или ↑ / Пробел: прыжок' },
    'Sürüşdür ↓  və ya ↓: sürüş': { tr: 'Kaydır ↓  ya da ↓: kay', en: 'Swipe ↓  or ↓: slide', ru: 'Свайп ↓  или ↓: подкат' },
    'İki dəfə toxun  və ya Shift: uçan xalça': { tr: 'Çift dokun  ya da Shift: uçan halı', en: 'Double-tap  or Shift: flying carpet', ru: 'Двойное касание  или Shift: ковёр' },
    'P: fasilə   M: səs': { tr: 'P: duraklat   M: ses', en: 'P: pause   M: sound', ru: 'P: пауза   M: звук' },
    'Sürüşdür: ← → ↑ ↓': { tr: 'Kaydır: ← → ↑ ↓', en: 'Swipe: ← → ↑ ↓', ru: 'Свайп: ← → ↑ ↓' },
    '← → zolaq   ↑ tullan   ↓ sürüş': { tr: '← → şerit   ↑ zıpla   ↓ kay', en: '← → lane   ↑ jump   ↓ slide', ru: '← → полоса   ↑ прыжок   ↓ подкат' },

    // ---- Main menu ------------------------------------------------------------------------
    'Oyna': { tr: 'Oyna', en: 'Play', ru: 'Играть' },
    'Nənənin dükanı': { tr: 'Nene\'nin dükkânı', en: 'Grandma\'s shop', ru: 'Бабушкина лавка' },
    'Personajlar': { tr: 'Karakterler', en: 'Characters', ru: 'Персонажи' },
    'Tapşırıqlar': { tr: 'Görevler', en: 'Missions', ru: 'Задания' },
    'Şəhərlər': { tr: 'Şehirler', en: 'Cities', ru: 'Города' },
    'Tədbirlər': { tr: 'Etkinlikler', en: 'Events', ru: 'События' },
    'Nağıl': { tr: 'Masal', en: 'Story', ru: 'Сказка' },
    'Liderlər': { tr: 'Liderler', en: 'Leaders', ru: 'Лидеры' },
    'Ayarlar': { tr: 'Ayarlar', en: 'Settings', ru: 'Настройки' },
    'Geyim dükanı': { tr: 'Kıyafet dükkânı', en: 'Outfit shop', ru: 'Лавка нарядов' },
    'Nənənin gündəlik hədiyyəsi: {gift}!': { tr: 'Nene\'nin günlük hediyesi: {gift}!', en: 'Grandma\'s daily gift: {gift}!', ru: 'Бабушкин подарок дня: {gift}!' },
    'Toxun və ya Enter': { tr: 'Dokun ya da Enter', en: 'Tap or Enter', ru: 'Коснись или Enter' },

    // ---- List screens: headers, notes, buttons --------------------------------------------
    '← Geri': { tr: '← Geri', en: '← Back', ru: '← Назад' },
    'Güclənmələr hər səviyyədə daha uzun çəkir': { tr: 'Güçlendirmeler her seviyede daha uzun sürer', en: 'Power-ups last longer with every level', ru: 'С каждым уровнем усиления длятся дольше' },
    'İndi qaçan: {name}': { tr: 'Şimdi koşan: {name}', en: 'Now running: {name}', ru: 'Сейчас бежит: {name}' },
    'Azərbaycan turu: Div səni hər şəhərdə qovur': { tr: 'Azerbaycan turu: Dev seni her şehirde kovalar', en: 'Azerbaijan tour: the Div chases you in every city', ru: 'Тур по Азербайджану: Див гонится за тобой везде' },
    'Bayram küçələri bəzəyir; təqvimə görə özü açılır': { tr: 'Bayram sokakları süsler; takvime göre kendi açılır', en: 'Festivals decorate the streets; they start by the calendar', ru: 'Праздник украшает улицы; включается по календарю' },
    'Kilidli': { tr: 'Kilitli', en: 'Locked', ru: 'Закрыто' },
    'Seçilib': { tr: 'Seçili', en: 'Selected', ru: 'Выбрано' },
    'Seç': { tr: 'Seç', en: 'Choose', ru: 'Выбрать' },
    'Aç': { tr: 'Aç', en: 'Open', ru: 'Открыть' }, // see the 'Aç' note under Settings
    'Tezliklə': { tr: 'Yakında', en: 'Soon', ru: 'Скоро' },
    '{what} · tezliklə': { tr: '{what} · yakında', en: '{what} · coming soon', ru: '{what} · скоро' },
    'MAKS': { tr: 'MAKS', en: 'MAX', ru: 'МАКС' },

    // ---- Settings (Ayarlar) ---------------------------------------------------------------
    // NOTE 'Aç' is one key with two meanings in the source: unlock (characters) and switch on
    // (Səslər, Musiqi). The translations use "open"/"unlock" sense; for the sound rows it reads loosely.
    'Dil': { tr: 'Dil', en: 'Language', ru: 'Язык' },
    'Azərbaycan (tərcümələr hazırlanır)': { tr: 'Azerbaycanca (çeviriler hazırlanıyor)', en: 'Azerbaijani (translations coming)', ru: 'Азербайджанский (перевод готовится)' },
    'Dəyiş': { tr: 'Değiştir', en: 'Change', ru: 'Сменить' },
    'Səslər': { tr: 'Sesler', en: 'Sounds', ru: 'Звуки' },
    'Musiqi': { tr: 'Müzik', en: 'Music', ru: 'Музыка' },
    'açıq': { tr: 'açık', en: 'on', ru: 'вкл.' },
    'söndürülüb': { tr: 'kapalı', en: 'off', ru: 'выкл.' },
    'Söndür': { tr: 'Kapat', en: 'Turn off', ru: 'Выключить' },
    'Cırtdanın hekayəsinə yenidən bax': { tr: 'Cırtdan\'ın hikâyesini yeniden izle', en: 'Watch Jirtdan\'s story again', ru: 'Посмотреть сказку снова' },
    'Bax': { tr: 'İzle', en: 'Watch', ru: 'Смотреть' },

    // ---- Costumes (Geyim dükanı) -----------------------------------------------------------
    'Adi geyim': { tr: 'Günlük kıyafet', en: 'Everyday clothes', ru: 'Обычный наряд' },
    'Novruz geyimi': { tr: 'Nevruz kıyafeti', en: 'Novruz outfit', ru: 'Наряд на Новруз' },
    'Qış geyimi': { tr: 'Kış kıyafeti', en: 'Winter outfit', ru: 'Зимний наряд' },
    'Dənizçi geyimi': { tr: 'Denizci kıyafeti', en: 'Sailor outfit', ru: 'Матросский наряд' },
    'Cırtdan üçün': { tr: 'Cırtdan için', en: 'For Jirtdan', ru: 'Для Джыртдана' },
    'Cırtdan üçün geyimlər': { tr: 'Cırtdan için kıyafetler', en: 'Outfits for Jirtdan', ru: 'Наряды для Джыртдана' },
    'qırmızı papaq, naxışlı jilet': { tr: 'kırmızı kalpak, işlemeli yelek', en: 'red papakh, embroidered vest', ru: 'красная папаха, расшитый жилет' },
    'Geyin': { tr: 'Giy', en: 'Wear', ru: 'Надеть' },
    'Geyinib': { tr: 'Giyili', en: 'Wearing', ru: 'Надето' },
    'Cırtdan: {name}': { tr: 'Cırtdan: {name}', en: 'Jirtdan: {name}', ru: 'Джыртдан: {name}' },

    // ---- Leaders (Liderlər) ---------------------------------------------------------------
    'Hələ qaçış yoxdur': { tr: 'Henüz koşu yok', en: 'No runs yet', ru: 'Забегов пока нет' },
    'Qaç və rekordunu yaz!': { tr: 'Koş ve rekorunu yaz!', en: 'Run and set a record!', ru: 'Беги и ставь рекорд!' },
    '{score} xal': { tr: '{score} puan', en: '{score} points', ru: 'Очки: {score}' },
    '{name} · {city} · {bread} çörək · {date}': { tr: '{name} · {city} · {bread} çörek · {date}', en: '{name} · {city} · {bread} bread · {date}', ru: '{name} · {city} · хлеб: {bread} · {date}' },
    'Div liqası': { tr: 'Dev Ligi', en: 'Div League', ru: 'Лига Дива' },
    'Qızıl liqa': { tr: 'Altın Lig', en: 'Gold League', ru: 'Золотая лига' },
    'Gümüş liqa': { tr: 'Gümüş Lig', en: 'Silver League', ru: 'Серебряная лига' },
    'Bürünc liqa': { tr: 'Bronz Lig', en: 'Bronze League', ru: 'Бронзовая лига' },
    '{league} · Rekord: {best} · onlayn reytinq server tələb edir (sonra)': { tr: '{league} · Rekor: {best} · çevrimiçi sıralama sunucu ister (sonra)', en: '{league} · Best: {best} · online ranking needs a server (later)', ru: '{league} · Рекорд: {best} · онлайн-рейтингу нужен сервер (позже)' },

    // ---- Nənənin dükanı (shop) ------------------------------------------------------------
    'Nənənin sinisi': { tr: 'Nene\'nin sinisi', en: 'Grandma\'s tray', ru: 'Бабушкин поднос' },
    'Sehrli çarıq': { tr: 'Sihirli çarık', en: 'Magic shoes', ru: 'Волшебные чарыхи' },
    'Qoşa təndir': { tr: 'Çifte tandır', en: 'Double tandir', ru: 'Двойной тендир' },
    'Kəndirbaz çubuğu': { tr: 'Cambaz sırığı', en: 'Rope walker\'s pole', ru: 'Шест канатоходца' },
    'Simurq quşu': { tr: 'Simurg kuşu', en: 'Simurgh bird', ru: 'Птица Симург' },
    'çörəkləri özünə çəkir': { tr: 'çörekleri kendine çeker', en: 'pulls bread to you', ru: 'притягивает хлеб' },
    'çox hündür tullanır': { tr: 'çok yükseğe zıplatır', en: 'super high jumps', ru: 'очень высокие прыжки' },
    'xalı ikiqat edir': { tr: 'puanı ikiye katlar', en: 'doubles your score', ru: 'удваивает очки' },
    'böyük sıçrayışlar': { tr: 'büyük sıçrayışlar', en: 'giant leaps', ru: 'большие прыжки' },
    'göydə uçur': { tr: 'gökyüzünde uçar', en: 'fly through the sky', ru: 'полёт по небу' },
    '{what} · {n} s · {lv}/{max}': { tr: '{what} · {n} sn · {lv}/{max}', en: '{what} · {n} s · {lv}/{max}', ru: '{what} · {n} с · {lv}/{max}' },
    '{name}: səviyyə {n}': { tr: '{name}: {n}. seviye', en: '{name}: level {n}', ru: '{name}: уровень {n}' },
    'Uçan xalça': { tr: 'Uçan halı', en: 'Flying carpet', ru: 'Ковёр-самолёт' },
    'bir toqquşmadan qoruyur · səndə: {n}': { tr: 'bir çarpışmadan korur · sende: {n}', en: 'saves you from one crash · you have: {n}', ru: 'спасает от одного удара · у тебя: {n}' },
    'Uçan xalça alındı!': { tr: 'Uçan halı alındı!', en: 'Flying carpet bought!', ru: 'Ковёр-самолёт куплен!' },
    'Xalça ilə uçuş': { tr: 'Halıyla uçuş', en: 'Carpet flight', ru: 'Полёт на ковре' },
    'startda bir toxun: xalça səni uçurub qabağa aparır · səndə: {n}': { tr: 'başta bir dokun: halı seni uçurup ileri taşır · sende: {n}', en: 'tap at the start: the carpet flies you ahead · you have: {n}', ru: 'коснись на старте: ковёр унесёт тебя вперёд · у тебя: {n}' },
    'Xalça ilə uçuş alındı!': { tr: 'Halıyla uçuş alındı!', en: 'Carpet flight bought!', ru: 'Полёт на ковре куплен!' },
    'Nənənin bağlaması': { tr: 'Nene\'nin bohçası', en: 'Grandma\'s bundle', ru: 'Бабушкин узелок' },
    'içində təsadüfi hədiyyə: çörək, nar, xalça': { tr: 'içinde sürpriz hediye: çörek, nar, halı', en: 'a surprise gift inside: bread, pomegranate, carpet', ru: 'внутри сюрприз: хлеб, гранат, ковёр' },
    'Bağlamadan {n} yağ çörəyi çıxdı!': { tr: 'Bohçadan {n} yağlı çörek çıktı!', en: 'The bundle had {n} butter bread!', ru: 'В узелке сдобный хлеб ×{n}!' },
    'Bağlamadan nar çıxdı!': { tr: 'Bohçadan nar çıktı!', en: 'The bundle had a pomegranate!', ru: 'В узелке гранат!' },
    'Bağlamadan uçan xalça çıxdı!': { tr: 'Bohçadan uçan halı çıktı!', en: 'The bundle had a flying carpet!', ru: 'В узелке ковёр-самолёт!' },
    'Bağlamadan iki nar çıxdı!': { tr: 'Bohçadan iki nar çıktı!', en: 'The bundle had two pomegranates!', ru: 'В узелке два граната!' },

    // ---- Characters -----------------------------------------------------------------------
    // 'Cırtdan' is above (title and character share the key)
    'Əsas qəhrəman': { tr: 'Ana kahraman', en: 'The main hero', ru: 'Главный герой' },
    'Tıq-Tıq xanım': { tr: 'Tıq-Tıq Hanım', en: 'Lady Tiq-Tiq', ru: 'Тык-Тык ханум' },
    'Cəld və şən qız': { tr: 'Çevik ve neşeli kız', en: 'A quick, cheerful girl', ru: 'Ловкая и весёлая девочка' },
    'Keçəl': { tr: 'Keloğlan', en: 'Kechal', ru: 'Кечал' },
    'Zarafatcıl və bic oğlan': { tr: 'Şakacı ve kurnaz oğlan', en: 'A cheeky, joking boy', ru: 'Шутник и хитрец' },
    'Kəndirbaz': { tr: 'Cambaz', en: 'Rope Walker', ru: 'Канатоходец' },
    'İp üstündə oynayan cəld oğlan': { tr: 'İp üstünde oynayan çevik oğlan', en: 'A nimble boy who dances on a rope', ru: 'Ловкий мальчик, пляшущий на канате' },
    'Məlikməmməd': { tr: 'Melikmemmed', en: 'Malik-Mammad', ru: 'Меликмамед' },
    'Cəsur şahzadə, qılınclı': { tr: 'Kılıçlı, cesur şehzade', en: 'A brave prince with a sword', ru: 'Храбрый царевич с мечом' },
    'Pəri qız': { tr: 'Peri Kız', en: 'Fairy Girl', ru: 'Девочка-пери' },
    'Sehrli qanadlı qız': { tr: 'Sihirli kanatlı kız', en: 'A girl with magic wings', ru: 'Девочка с волшебными крыльями' },
    'Kosa': { tr: 'Kosa', en: 'Kosa', ru: 'Коса' },
    'Novruz bayramının obrazı': { tr: 'Nevruz Bayramı karakteri', en: 'A character of the Novruz holiday', ru: 'Персонаж праздника Новруз' },
    '{desc} · şəkərbura və paxlava: {have}/{need} (Novruzda)': { tr: '{desc} · şekerbura ve baklava: {have}/{need} (Nevruz\'da)', en: '{desc} · shekerbura and pakhlava: {have}/{need} (at Novruz)', ru: '{desc} · шекербура и пахлава: {have}/{need} (на Новруз)' },
    '{name} qaçır!': { tr: '{name} koşuyor!', en: '{name} is running!', ru: '{name} бежит!' },
    '{name} açıldı!': { tr: '{name} açıldı!', en: '{name} unlocked!', ru: 'Открыт персонаж: {name}!' },
    '{desc} · həftəlik ov: buta daşları {have}/{need}': { tr: '{desc} · haftalık av: buta taşları {have}/{need}', en: '{desc} · weekly hunt: buta stones {have}/{need}', ru: '{desc} · охота недели: камни-бута {have}/{need}' },
    '{desc} · sehrli daşlar: {have}/{need}': { tr: '{desc} · sihirli taşlar: {have}/{need}', en: '{desc} · magic stones: {have}/{need}', ru: '{desc} · волшебные камни: {have}/{need}' },
    '{desc} · pulsuz: {have}/{need} tapşırıq': { tr: '{desc} · ücretsiz: {have}/{need} görev', en: '{desc} · free: {have}/{need} missions', ru: '{desc} · бесплатно: заданий {have}/{need}' },

    // ---- Cities ---------------------------------------------------------------------------
    'Köhnə Bakı': { tr: 'Eski Bakü', en: 'Old Baku', ru: 'Старый Баку' },
    'İçərişəhər: Qız Qalası, bazar, faytonlar': { tr: 'İçerişehir: Kız Kalesi, çarşı, faytonlar', en: 'Old City: Maiden Tower, bazaar, carriages', ru: 'Ичеришехер: Девичья башня, базар, фаэтоны' },
    'Şəki': { tr: 'Şeki', en: 'Shaki', ru: 'Шеки' },
    'Xan sarayı, şəbəkə pəncərələr, Şəki halvası': { tr: 'Han Sarayı, şebeke pencereler, Şeki helvası', en: 'Khan\'s Palace, shebeke windows, Shaki halva', ru: 'Ханский дворец, окна-шебеке, шекинская халва' },
    'Qəbələ': { tr: 'Gebele', en: 'Gabala', ru: 'Габала' },
    'meşə cığırı, şəlalə, kötüklər, qayalar, fındıq': { tr: 'orman patikası, şelale, kütükler, kayalar, fındık', en: 'forest path, waterfall, stumps, rocks, hazelnuts', ru: 'лесная тропа, водопад, пни, скалы, фундук' },
    'Naxçıvan': { tr: 'Nahçıvan', en: 'Nakhchivan', ru: 'Нахчыван' },
    'Möminə Xatın türbəsi, İlandağ, Badamlı suyu': { tr: 'Mümine Hatun Türbesi, İlandağ, Badamlı suyu', en: 'Momine Khatun Tomb, Ilandag, Badamli water', ru: 'Мавзолей Момине-хатун, Иландаг, вода «Бадамлы»' },
    'Lənkəran': { tr: 'Lenkeran', en: 'Lankaran', ru: 'Ленкорань' },
    'çay plantasiyaları, yağış, mayak, naringi': { tr: 'çay bahçeleri, yağmur, deniz feneri, mandalina', en: 'tea fields, rain, lighthouse, tangerines', ru: 'чайные плантации, дождь, маяк, мандарины' },
    'Quba': { tr: 'Kuba', en: 'Guba', ru: 'Губа' },
    'alma bağları, xalça dəzgahları, Şahdağ': { tr: 'elma bahçeleri, halı tezgâhları, Şahdağ', en: 'apple orchards, carpet looms, Shahdag', ru: 'яблоневые сады, ковровые станки, Шахдаг' },
    'Qobustan': { tr: 'Gobustan', en: 'Gobustan', ru: 'Гобустан' },
    'qayaüstü təsvirlər, palçıq vulkanları, Xəzər': { tr: 'kaya resimleri, çamur volkanları, Hazar', en: 'rock carvings, mud volcanoes, the Caspian', ru: 'наскальные рисунки, грязевые вулканы, Каспий' },
    '{name}! Div səni orada da tapacaq': { tr: '{name}! Dev seni orada da bulacak', en: '{name}! The Div will find you there too', ru: '{name}! Див найдёт тебя и там' },

    // ---- Events (festivals) ---------------------------------------------------------------
    'Novruz bayramı': { tr: 'Nevruz Bayramı', en: 'Novruz holiday', ru: 'Праздник Новруз' },
    '15 mart – 5 aprel': { tr: '15 Mart – 5 Nisan', en: '15 March – 5 April', ru: '15 марта – 5 апреля' },
    'tonqallar, səməni, şəkərbura və paxlava; Kosa açılır': { tr: 'ateşler, semeni, şekerbura ve baklava; Kosa açılır', en: 'bonfires, semeni, shekerbura, pakhlava; unlocks Kosa', ru: 'костры, семени, шекербура и пахлава; открыт Коса' },
    'Qış (Yeni il)': { tr: 'Kış (Yılbaşı)', en: 'Winter (New Year)', ru: 'Зима (Новый год)' },
    '15 dekabr – 31 yanvar': { tr: '15 Aralık – 31 Ocak', en: '15 December – 31 January', ru: '15 декабря – 31 января' },
    'qar yağır, Div qış paltarında': { tr: 'kar yağıyor, Dev kışlık giysilerinde', en: 'snow falls, the Div in winter clothes', ru: 'идёт снег, Див в зимней одежде' },
    'Nar bayramı': { tr: 'Nar Bayramı', en: 'Pomegranate Festival', ru: 'Праздник граната' },
    '20 oktyabr – 10 noyabr': { tr: '20 Ekim – 10 Kasım', en: '20 October – 10 November', ru: '20 октября – 10 ноября' },
    'Göyçay nar bağları, nar ikiqat çox düşür': { tr: 'Göyçay nar bahçeleri, iki kat daha çok nar', en: 'Goychay orchards, twice the pomegranates', ru: 'гранатовые сады Гёйчая, гранатов вдвое больше' },
    'Xəzər yayı': { tr: 'Hazar Yazı', en: 'Caspian Summer', ru: 'Каспийское лето' },
    'iyun – avqust': { tr: 'Haziran – Ağustos', en: 'June – August', ru: 'Июнь – август' },
    'dənizkənarı: qum qalaları, dondurma, gəmilər, neft buruqları; Cırtdan dənizçi geyimində': { tr: 'deniz kenarı: kum kaleleri, dondurma, gemiler, petrol kuleleri; Cırtdan denizci kıyafetinde', en: 'seaside: sandcastles, ice cream, ships, oil rigs; Jirtdan in a sailor suit', ru: 'у моря: замки из песка, мороженое, корабли, нефтяные вышки; Джыртдан в морской форме' },
    'Təqvimə görə': { tr: 'Takvime göre', en: 'By the calendar', ru: 'По календарю' },
    'indi: {name}': { tr: 'şimdi: {name}', en: 'now: {name}', ru: 'сейчас: {name}' },
    'indi heç bir bayram yoxdur': { tr: 'şu an hiç bayram yok', en: 'no festival right now', ru: 'сейчас праздников нет' },
    'Bayramsız': { tr: 'Bayramsız', en: 'No festival', ru: 'Без праздника' },
    'adi köhnə Bakı': { tr: 'her zamanki Eski Bakü', en: 'plain old Baku', ru: 'обычный старый Баку' },
    '{name} seçildi': { tr: '{name} seçildi', en: '{name} chosen', ru: 'Выбрано: {name}' },

    // ---- Missions -------------------------------------------------------------------------
    'Bir qaçışda {n} yağ çörəyi topla': { tr: 'Tek koşuda {n} yağlı çörek topla', en: 'Collect {n} butter bread in one run', ru: 'За один забег собери хлеба: {n}' },
    'Simurq quşundan {n} dəfə istifadə et': { tr: 'Simurg kuşunu {n} kez kullan', en: 'Simurgh flights: {n}', ru: 'Полёты на Симурге: {n}' },
    'Yük arabalarının damında {n} saniyə qaç': { tr: 'Yük arabalarının üstünde {n} saniye koş', en: 'Run on cart roofs for {n} seconds', ru: 'Беги по крышам телег: {n} сек.' },
    'Xalça ipinin altından {n} dəfə sürüş': { tr: 'Halı ipinin altından {n} kez kay', en: 'Slide under carpet ropes {n} times', ru: 'Подкаты под ковры на верёвке: {n}' },
    'Divi {n} dəfə yaxınlaşdırıb yenə qaç': { tr: 'Dev\'i {n} kez yaklaştırıp yine kaç', en: 'Let the Div get close, then escape: {n}', ru: 'Побеги у Дива из-под носа: {n}' },
    'Bir qaçışda {n} m qaç': { tr: 'Tek koşuda {n} m koş', en: 'Run {n} m in one run', ru: 'Пробеги {n} м за один забег' },
    'Səbətlərin üstündən {n} dəfə tullan': { tr: 'Sepetlerin üstünden {n} kez zıpla', en: 'Jump over baskets {n} times', ru: 'Прыжки через корзины: {n}' },
    '{n} güclənmə topla': { tr: '{n} güçlendirme topla', en: 'Collect {n} power-ups', ru: 'Собери усилений: {n}' },
    'Cəmi {n} yağ çörəyi topla': { tr: 'Toplam {n} yağlı çörek topla', en: 'Collect {n} butter bread in total', ru: 'Всего собери хлеба: {n}' },
    'Bitdi! Bas və mükafatı al': { tr: 'Tamam! Bas ve ödülü al', en: 'Done! Tap to claim', ru: 'Готово! Нажми и забери' },
    'Bitən tapşırığa bas, çörəyi al · hər 3 tapşırıq: vurğu +1 (indi x{n})': { tr: 'Biten göreve bas, çöreği al · her 3 görev: çarpan +1 (şimdi x{n})', en: 'Tap a done mission for bread · every 3: multiplier +1 (now x{n})', ru: 'Жми на готовое задание за хлебом · каждые 3: множитель +1 (сейчас x{n})' },
    '+{n} çörək! Vurğu x{mult}': { tr: '+{n} çörek! Çarpan x{mult}', en: '+{n} bread! Multiplier x{mult}', ru: '+{n} хлеба! Множитель x{mult}' },
    '+{n} çörək! Yeni tapşırıq': { tr: '+{n} çörek! Yeni görev', en: '+{n} bread! New mission', ru: '+{n} хлеба! Новое задание' },
    'Həftəlik ov: buta daşlarını tap': { tr: 'Haftalık av: buta taşlarını bul', en: 'Weekly hunt: find the buta stones', ru: 'Охота недели: найди камни-бута' },
    // mission progress: {run} is ' (bir qaçışda)' (its own key below) or empty
    '{got} / {need}{run} · mükafat: {prize}': { tr: '{got} / {need}{run} · ödül: {prize}', en: '{got} / {need}{run} · prize: {prize}', ru: '{got} / {need}{run} · награда: {prize}' },
    '{got} / {need} · mükafat: {prize}': { tr: '{got} / {need} · ödül: {prize}', en: '{got} / {need} · prize: {prize}', ru: '{got} / {need} · награда: {prize}' },
    '3 bağlama və 1000 çörək': { tr: '3 bohça ve 1000 çörek', en: '3 bundles and 1000 bread', ru: '3 узелка и хлеб ×1000' },
    'Bu həftə bitdi! Gələn həftə yenisi': { tr: 'Bu hafta bitti! Gelecek hafta yenisi', en: 'Done for this week! New one next week', ru: 'Неделя пройдена! Новая охота скоро' },
    'Həftəlik ov bitdi! Məlikməmməd açıldı!': { tr: 'Haftalık av bitti! Melikmemmed açıldı!', en: 'Weekly hunt done! Malik-Mammad unlocked!', ru: 'Охота недели окончена! Открыт Меликмамед!' },
    'Həftəlik ov bitdi! {gifts}, 1000 çörək': { tr: 'Haftalık av bitti! {gifts}, 1000 çörek', en: 'Weekly hunt done! {gifts}, 1000 bread', ru: 'Охота недели окончена! {gifts}, хлеб ×1000' },
    ' (bir qaçışda)': { tr: ' (tek koşuda)', en: ' (in one run)', ru: ' (за один забег)' },
    'Tapşırıq bitdi! Mükafatı Tapşırıqlarda al': { tr: 'Görev tamam! Ödülü Görevler\'de al', en: 'Mission done! Claim it in Missions', ru: 'Задание выполнено! Награда — в Заданиях' },

    // ---- In-run banners -------------------------------------------------------------------
    'Ay Cırtdaaan!': { tr: 'Hey Cırtdaaan!', en: 'Hey, Jirtdaaan!', ru: 'Эй, Джыртдааан!' },
    'Uçan xalça səni qorudu!': { tr: 'Uçan halı seni korudu!', en: 'The flying carpet saved you!', ru: 'Ковёр-самолёт тебя спас!' },
    'Uçan xalça!': { tr: 'Uçan halı!', en: 'Flying carpet!', ru: 'Ковёр-самолёт!' },
    'Xalça ilə uçuş!': { tr: 'Halıyla uçuş!', en: 'Carpet flight!', ru: 'Полёт на ковре!' },
    'Uçuş! x{n}': { tr: 'Uçuş! x{n}', en: 'Fly! x{n}', ru: 'Полёт! x{n}' },
    'Simurq səni yerə qoydu': { tr: 'Simurg seni yere indirdi', en: 'The Simurgh set you down', ru: 'Симург опустил тебя вниз' },
    'Nar!': { tr: 'Nar!', en: 'Pomegranate!', ru: 'Гранат!' },
    'Nar ilə davam!': { tr: 'Narla devam!', en: 'Run on with pomegranate!', ru: 'Гранат! Бежим дальше!' },
    'Nənənin sinisi!': { tr: 'Nene\'nin sinisi!', en: 'Grandma\'s tray!', ru: 'Бабушкин поднос!' },
    'Sehrli çarıq!': { tr: 'Sihirli çarık!', en: 'Magic shoes!', ru: 'Волшебные чарыхи!' },
    'Qoşa təndir: x2!': { tr: 'Çifte tandır: x2!', en: 'Double tandir: x2!', ru: 'Двойной тендир: x2!' },
    'Kəndirbaz çubuğu!': { tr: 'Cambaz sırığı!', en: 'Rope walker\'s pole!', ru: 'Шест канатоходца!' },
    'Simurq quşu!': { tr: 'Simurg kuşu!', en: 'Simurgh bird!', ru: 'Птица Симург!' },
    'Vurğu x{n}!': { tr: 'Çarpan x{n}!', en: 'Multiplier x{n}!', ru: 'Множитель x{n}!' },
    'Div büdrədi! Hə-hə!': { tr: 'Dev tökezledi! Ha-ha!', en: 'The Div tripped! Ha-ha!', ru: 'Див споткнулся! Ха-ха!' },
    'Div yıxıldı, Cırtdan dil çıxardı!': { tr: 'Dev düştü, Cırtdan dil çıkardı!', en: 'The Div fell! Jirtdan pulls a face!', ru: 'Див упал, Джыртдан показал язык!' },
    'Div çarığını itirdi!': { tr: 'Dev çarığını kaybetti!', en: 'The Div lost his shoe!', ru: 'Див потерял чарых!' },
    'Div yoruldu, amma əl çəkmir!': { tr: 'Dev yoruldu ama vazgeçmiyor!', en: 'The Div is tired but won\'t give up!', ru: 'Див устал, но не сдаётся!' },
    // the day's word: {gifts} is a ', '-joined list of the gift strings below, each translated on its own
    '{word}! Hədiyyə: {gifts}': { tr: '{word}! Hediye: {gifts}', en: '{word}! Gift: {gifts}', ru: '{word}! Подарок: {gifts}' },
    '{n} yağ çörəyi': { tr: '{n} yağlı çörek', en: '{n} butter bread', ru: 'сдобный хлеб ×{n}' },
    'nar': { tr: 'nar', en: 'a pomegranate', ru: 'гранат' },
    'uçan xalça': { tr: 'uçan halı', en: 'a flying carpet', ru: 'ковёр-самолёт' },
    'iki nar': { tr: 'iki nar', en: 'two pomegranates', ru: 'два граната' },

    // ---- Pause, story, game over ----------------------------------------------------------
    'Fasilə': { tr: 'Mola', en: 'Paused', ru: 'Пауза' },
    'Toxun və ya P: davam': { tr: 'Dokun ya da P: devam', en: 'Tap or P: resume', ru: 'Коснись или P: дальше' },
    '{page} / {pages}   Toxun və ya Enter: davam': { tr: '{page} / {pages}   Dokun ya da Enter: devam', en: '{page} / {pages}   Tap or Enter: next', ru: '{page} / {pages}   Коснись или Enter: дальше' },
    'Keç  Esc': { tr: 'Geç  Esc', en: 'Skip  Esc', ru: 'Далее  Esc' },
    'Div səni tutdu!': { tr: 'Dev seni yakaladı!', en: 'The Div caught you!', ru: 'Див тебя поймал!' },
    'Bam! Div səni tutdu!': { tr: 'Bam! Dev seni yakaladı!', en: 'Bam! The Div caught you!', ru: 'Бам! Див тебя поймал!' },
    'Hamm! Div Cırtdanı torbaya qoydu.': { tr: 'Hamm! Dev Cırtdan\'ı torbaya koydu.', en: 'Hamm! The Div put Jirtdan in his sack.', ru: 'Хамм! Див посадил Джыртдана в мешок.' },
    'Cırtdan toqquşdu, Div çatdı!': { tr: 'Cırtdan çarptı, Dev yetişti!', en: 'Jirtdan crashed, the Div caught up!', ru: 'Джыртдан врезался, Див догнал!' },
    'Xal: {n}': { tr: 'Puan: {n}', en: 'Score: {n}', ru: 'Очки: {n}' },
    'Yeni rekord!': { tr: 'Yeni rekor!', en: 'New record!', ru: 'Новый рекорд!' },
    'Nar ilə davam et ({n})  C': { tr: 'Narla devam et ({n})  C', en: 'Continue ({n})  C', ru: 'Продолжить ({n})  C' },
    'Yenidən qaç  Enter': { tr: 'Tekrar koş  Enter', en: 'Run again  Enter', ru: 'Ещё раз  Enter' },
    'Nar yoxdur: yolda nar tap': { tr: 'Nar yok: yolda nar bul', en: 'No pomegranates: grab some!', ru: 'Нет гранатов: найди в пути' },
    'Menyu  Esc': { tr: 'Menü  Esc', en: 'Menu  Esc', ru: 'Меню  Esc' },
    'Tapşırıqlar: {done}/3 · vurğu x{mult}': { tr: 'Görevler: {done}/3 · çarpan x{mult}', en: 'Missions: {done}/3 · multiplier x{mult}', ru: 'Задания: {done}/3 · множитель x{mult}' },

    // ---- Story (STORY captions, in full) --------------------------------------------------
    'Çox-çox qədimlərdə, Xəzərin sahilində, qala divarları ilə əhatə olunmuş köhnə Bakıda Cırtdan adlı balaca bir oğlan yaşayırdı. O, boyca balaca idi, amma ağılda hamıdan böyük idi.': {
      tr: 'Çok çok eskiden, Hazar kıyısında, kale surlarıyla çevrili eski Bakü\'de Cırtdan adında küçük bir oğlan yaşardı. Boyu küçüktü ama aklı herkesten büyüktü.',
      en: 'Long, long ago, on the shore of the Caspian Sea, in old Baku behind its fortress walls, there lived a little boy called Jirtdan. He was small in size, but bigger than anyone in wits.',
      ru: 'Давным-давно, на берегу Каспия, в старом Баку за крепостными стенами жил маленький мальчик по имени Джыртдан. Ростом он был мал, зато умом больше всех.',
    },
    'Nənəsi hər səhər təndirdə isti, ətirli yağ çörəkləri bişirir, Cırtdan da onları məhəllənin uşaqlarına paylayırdı.': {
      tr: 'Nenesi her sabah tandırda sıcacık, mis kokulu yağlı çörekler pişirir, Cırtdan da onları mahallenin çocuklarına dağıtırdı.',
      en: 'Every morning his Grandma baked warm, sweet-smelling butter bread in her tandir, and Jirtdan shared it with the children of the neighbourhood.',
      ru: 'Каждое утро бабушка пекла в тендире тёплый душистый сдобный хлеб, а Джыртдан раздавал его детям всего квартала.',
    },
    'Bir gecə dağlarda yaşayan nəhəng və acgöz Div çörəklərin ətrini hiss etdi. Gizlicə şəhərə enib bütün çörəkləri oğurladı, üstəlik nənənin sehrli təndirini də apardı!': {
      tr: 'Bir gece dağlarda yaşayan koca ve açgözlü Dev çöreklerin kokusunu aldı. Gizlice şehre inip bütün çörekleri çaldı, üstelik Nene\'nin sihirli tandırını da götürdü!',
      en: 'One night the huge, greedy Div who lived in the mountains smelled the bread. He crept down into the city and stole all the bread, and he took Grandma\'s magic tandir too!',
      ru: 'Однажды ночью огромный и жадный Див, живший в горах, учуял запах хлеба. Он тайком спустился в город, украл весь хлеб, да ещё и унёс бабушкин волшебный тендир!',
    },
    'Cırtdan qorxmadı. Gecə yarısı Divin mağarasına girdi və Div xoruldayıb yatanda çörəklərlə dolu torbanı götürdü... Amma ayağı Divin nəhəng çarığına ilişdi!': {
      tr: 'Cırtdan korkmadı. Gece yarısı Dev\'in mağarasına girdi ve Dev horlayıp uyurken çöreklerle dolu torbayı aldı... Ama ayağı Dev\'in kocaman çarığına takıldı!',
      en: 'Jirtdan was not afraid. At midnight he slipped into the Div\'s cave, and while the Div lay snoring he took the sack full of bread... But his foot caught on the Div\'s giant shoe!',
      ru: 'Джыртдан не испугался. В полночь он пробрался в пещеру Дива и, пока Див храпел во сне, забрал мешок, полный хлеба... Но его нога зацепилась за огромный чарых Дива!',
    },
    '— Ay Cırtdan! Yenə sənsən?! Dayan, səni tutub yeyəcəm! Qaç, Cırtdan! Torba yırtıldı, çörəklər Bakının küçələrinə səpələndi. Divdən qaç və nənənin çörəklərini yığ!': {
      tr: '— Hey Cırtdan! Yine mi sensin?! Dur, seni yakalayıp yiyeceğim! Kaç, Cırtdan! Torba yırtıldı, çörekler Bakü\'nün sokaklarına saçıldı. Dev\'den kaç ve Nene\'nin çöreklerini topla!',
      en: '— Hey, Jirtdan! You again?! Stop, I\'ll catch you and eat you up! Run, Jirtdan! The sack tore, and the bread scattered across the streets of Baku. Run from the Div and gather Grandma\'s bread!',
      ru: '— Эй, Джыртдан! Опять ты?! Стой, вот поймаю и съем! Беги, Джыртдан! Мешок порвался, и хлеб рассыпался по улицам Баку. Убегай от Дива и собери бабушкин хлеб!',
    },
  },
};
