# Grafika a původ: STARBIT Worlds

Vytvořeno 11. 10. 2026 podle `AGENTS.md` a `docs/design/STARBIT-GRAFICKY-STYL.md` v commitu `6b4d4f37aab920ad86d0069710cfe1763693d56d`. Obsah prostředí vychází z dodaného `STARBIT-Pribeh-hry(4).txt`.

## Reference a výtvarný směr

Před tvorbou byly prohlédnuty skutečné obrázky Bita, travnaté plošiny, lesních dominant, opravného navijáku, královských rekvizit a úplných pozadí z projektu. Nové objekty drží barevné tmavé obrysy, měkký malovaný objem, přátelské zaoblené tvary, tyrkysové detaily, teplé zlato a konzistentní boční pohled. Vzdálená pozadí mají měkčí kresbu než popředí.

| Reference | Úloha |
| --- | --- |
| `assets/shared/pieces/idle.png` | Identita Bita a kontrola měřítka; nevytvářela se nová postava. |
| `assets/environment/forest/cutouts/platforms/plosina_travnata.png` | Kontura, vegetace a materiály venkovních plošin. |
| `assets/environment/forest/awakening/winch.png` | Nejbližší stávající opravný mechanismus. |
| `assets/environment/forest/higgsfield/forest_landmarks.png` | Lesní dominanty a měkká kresba dřeva a listí. |
| `assets/environment/castle/royal_props.png` | Kámen, zlato, krystaly, portály a velké rostliny. |
| Kompletní pozadí 01, 03, 06, 09, 10 | Původní malba světa, prostor, atmosféra a světlo. |

Čtyřdílná původní pozadí byla v Higgsfieldu nejprve složena na původních 1672 × 941 pixelů, po odstranění dvoupixelového paddingu **ve všech směrech**. SHA-256 původního RGB pole souhlasí s manifestem všech pěti použitých pozadí. Žádný úzký díl se neroztahoval přes celou referenci.

## Generace

- Poskytovatel: **Higgsfield**.
- Model: **gpt_image_2_5**, `quality=high`, `resolution=2k`.
- 18 atlasů: poměr 1:1, průhledné pozadí, skutečný výstup 2048 × 2048 RGBA, vždy 9 objektů v pořadí 3 × 3.
- 6 pozadí: požadovaný poměr 16:9, neprůhledné, skutečný výstup 2688 × 1520 RGB. Zachován celý výstup bez ořezu.
- Každý prompt výslovně rozlišuje úlohu tří obrázkových referencí. Pozdější sady používají jako prostředí již dokončené nové pozadí.

Úplné nezkrácené prompty, konkrétní obrázkové vstupy, parametry, ID generací, adresy originálů a přesné pořadí objektů jsou v `generation_manifest.json`. Indexy 0–15 tvoří postupně dvojice mechanismy/dekorace osmi prostředí, 16 společné díly, 17 příběhové předměty a 18–23 pozadí. Originální atlasy zůstávají dostupné ve výstupech Higgsfieldu; archiv neduplikuje jejich celé bitmapy vedle samostatných PNG.

## Příprava obrázků

Veškeré rozřezání atlasů a příprava obrazových částí proběhly v **Higgsfield sandboxu**, pomocí Pillow a OpenCV. Mřížka určuje pouze totožnost objektu; výřez sleduje celou skutečnou siluetu. Pevné dělení po třetinách bylo při kontrole odmítnuto, protože generované kresby někdy překračují teoretickou hranici buňky. Konečná verze využívá souvislé komponenty alfa kanálu, včetně samostatných částí jednoho objektu. Nemá varování o dotyku obrysu s hranou celého atlasu.

Odstraněny byly pouze zanedbatelné alfa hodnoty 0–8 a drobné izolované fragmenty pod 5 pixelů; hodnoty 250–254 byly normalizovány na neprůhledných 255. Zachován průběh ostatního vyhlazení. Každý PNG má 8 pixelů průhledného ochranného okraje. Žádné bílé nebo šachovnicové pozadí nebylo přimalováno.

Pro plošiny byl zaměřen začátek souvislého povrchu ve střední části obrázku; dekorace mají kotvu dole. Obrysy pastí vycházejí z alfa siluety. Otvory mechanismů mají samostatné kotevní body v `socket_anchors.json`; šířka vkládaného kola byla kontrolována na skutečných složených náhledech a konzervativně zmenšena tam, kde by zasahovala rám.

## Kontrola

Prohlédnuty byly všechny atlasy, nová pozadí, připravené díly a osm kompozic s původním Bitem nad odpovídajícím prostředím. Kontrolní kompozice jsou v `previews/scale_*.jpg`; listy objektů v `previews/*_mechanics.jpg` a `previews/*_decor.jpg`. Obrázky obsahují celé tvary, průhlednost a materiály navazující na původní reference.

Pohyby páky, plošin a vrat používají samostatné objekty; neroztahují hotovou kresbu celého mechanismu. Nový sprite sheet postav, animační cyklus nepřátel ani automatické přepsání stávajících levelů nejsou součástí této změny.
