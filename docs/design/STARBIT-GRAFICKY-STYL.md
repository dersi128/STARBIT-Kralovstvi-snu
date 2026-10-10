# STARBIT – jednotný grafický styl

Nové postavy, nepřátelé, bossové, objekty, animace a pozadí rozšiřují existující
Království snů. Les, vesnička, oblačné ostrovy i hrad mají působit jako jeden svět.
Základem jsou konkrétní obrázky ze hry a nová dodaná série deseti pozadí.

## Výtvarný základ

| Oblast | Co zachovat |
| --- | --- |
| Kresba | Barevná pohádková 2D ilustrace s měkkým objemem a malovaným stínováním. |
| Tvary | Zaoblené siluety, srozumitelné velké tvary, přiměřeně zjednodušené detaily. |
| Postavy a objekty | Zřetelné obrysy jako u Bita, čisté hrany, měkké odlesky; síla obrysu odpovídá referenci v herním měřítku. |
| Pozadí | Jemnější obrysy, vrstvy hloubky, vzdálené části světlejší a méně kontrastní. |
| Barvy | Zelená a tyrkysová, modrá, krémová, zlatá; růžové a levandulové světlo v pozadí. Poměr barev vybírat podle cílového levelu. |
| Materiály | Malované dřevo, kámen, listí a kov se stejnou mírou stylizace jako sousední assety. |
| Světlo | Měkké světlo a teplé akcenty. Směr osvětlení převzít z reference cílového místa. |
| Motivy světa | Hvězdy, lucerny, mechem porostlé kameny, kořeny, oblouky, oblaky, vodopády a plovoucí ostrovy podle prostředí. |
| Kamera | Boční pohled pro hraní. Nové plošiny a objekty mají perspektivu svých sousedů. |

Prostorový dojem je součást kresby. Fotorealismus, nový vzhled 3D renderu,
pixel art nebo změna na úplně plochou vektorovou kresbu by narušily kontinuitu.
Stejně ji naruší příliš ostré realistické textury, odlišná síla obrysů nebo jiný
poměr velikosti hlavy a těla postavy.

## Konkrétní reference

Cesty jsou relativní ke kořenu stávajícího Godot projektu. Obrázky se musí
před zadáním generace skutečně prohlédnout a přiložit; jejich názvy v promptu
samy o sobě generátoru neposkytnou předlohu.

| Účel | Reference |
| --- | --- |
| Identita Bita | `assets/shared/pieces/idle.png` |
| Pózy a animace Bita | `assets/characters/animations/bit_v2/motion.png` a stávající `bit_frames.tres` |
| Zip, dříve Fouk | `assets/shared/pieces/fouk.png` a `assets/characters/fouk/fouk_repair_sheet.png` |
| Krteček a Jiskra | `assets/shared/pieces/mole.png`, `assets/shared/pieces/jiskra.png` |
| Nepřátelé a bossové | Odpovídající PNG a SpriteFrames v `assets/characters/animations/`; pro nový druh také Bit a cílové prostředí. |
| Lesní plošiny | `assets/environment/forest/cutouts/platforms/plosina_travnata.png` a další plošiny stejné sady. |
| Lesní dekorace | `assets/environment/forest/cutouts/` – vybrat nejbližší typ objektu. |
| Hradní objekty | `assets/environment/castle/royal_props.png` a používaný objekt cílové scény. |
| Nová řada pozadí | `assets/environment/backgrounds/story/manifest.json` a příslušný `level_01/` až `level_10/`. |
| Doplňková lesní reference | `assets/environment/forest/higgsfield/forest_glade.png`; pro nová pozadí upřednostnit novou dodanou sérii. |

Bit má světlé tělo, zelenotyrkysové díly, tmavý obličej s tyrkysovýma očima,
kulatou anténu, modrý šátek a zlatou hvězdu na hrudi. Tyto prvky a jeho proporce
musí zůstat stejné i při opravě, aktivaci páky, sbírání předmětu a dalších pózách.

Nový typ nepřítele může mít jinou siluetu i chování, ale kresbu, materiály
a stínování přebírá ze společné sady. Temnota Morouse používá hlubší fialové
odstíny a stejné měkké tvary; nemění celý výtvarný směr na horor.

## Jak zadávat práci v Higgsfieldu

1. Vyber identitu nebo nejbližší existující objekt, referenci kresby stejné
   kategorie a obrázek cílového prostředí. U každé předlohy napiš její účel.
2. Když jde o stejnou postavu či objekt, zadávej jeho úpravu podle předlohy.
   U nového druhu popiš nový tvar, přitom zachovej společnou kresbu.
3. Pro nové pozadí použij celý zdrojový obrázek z dodané série. Pokud jsou
   dostupné pouze díly, v Higgsfieldu je slož podle `manifest.json` včetně
   odstranění technického překryvu okrajů. Úzký díl nenatahuj na celé pozadí.
4. Pro sprity požaduj skutečnou průhlednost PNG, celý objekt a čisté okraje.
   Pro atlas určuj počet snímků, mřížku a rozestupy podle konkrétní animace.
5. V Higgsfieldu připrav jednotlivé výřezy nebo díly. U postav drž společný
   kotevní bod, stejné proporce a měřítko. Výchozí směr přizpůsob existujícím
   animacím; pohyb nesmí vypadat jako chůze pozpátku.
6. Porovnej výsledek s předlohami a vlož jej do cílové scény v Godotu.
   Posuzuj jej také ve skutečné herní velikosti, kde musí zůstat čitelný.

Společný základ promptu, doplněný o skutečně přiložené obrázky:

```text
Create [ASSET / ACTION] for the existing STARBIT: Kingdom of Dreams game.
Image 1 defines [CHARACTER IDENTITY / CLOSEST EXISTING OBJECT].
Image 2 defines the drawing style of this asset category.
Image 3 defines the target environment, palette and lighting.
Keep the reference silhouettes, proportions, outline treatment, painted
shading, material stylization and level of detail. Match the existing game's
soft illustrated depth and its side-view gameplay perspective.
Keep established character features identical throughout every animation frame.
Use [OUTPUT DIMENSIONS / GRID / FRAME COUNT / FACING DIRECTION / PIVOT].
For isolated sprites: real alpha transparency, complete silhouettes, clean
edges and enough spacing for extraction. No text, UI or baked checkerboard.
For backgrounds: preserve the identity of the kingdom and its recurring
landmarks; keep the gameplay area readable and distant scenery softer.
No photorealism, pixel art, or change of rendering style.
```

Část o spritech či pozadích použij podle skutečného výstupu. Pokud chybí
potřebná předloha, nejprve ji vyhledej mezi assety; nevymýšlej nový styl podle
samotného názvu hry. Pro nové nepřátele přebírej styl, nikoli siluetu Bita.

## Kontrola před zapojením

- Nový prvek ladí s Bitem, sousedními objekty a pozadím při herním měřítku.
- Barvy, obrysy, perspektiva, světlo a hustota detailů odpovídají jeho kategorii.
- Pózy nemění tvar hlavy, šátek, anténu, hvězdu ani rozměry postavy.
- Čisté alfa okraje nemají barevné lemy, useknuté části ani zbytky sousedních póz.
- Chodidla, základna objektu a kolize odpovídají obrázku; animace neskáče
  kolem kotevního bodu.
- Pozadí navazují na cestu příběhu a opakují stejnou identitu hradu a krajiny.

Když výsledek neladí, uprav nový asset a znovu jej porovnej. U nové sady ulož
použité reference, model, prompt a rozměry nebo výřezy do jejího `ART_NOTES.md`.
