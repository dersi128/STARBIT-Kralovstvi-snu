# STARBIT — assety pro všech 30 levelů

Balíček prostředí navazuje na grafická pravidla projektu a nový třicetilevelový příběh. Obsahuje **162 samostatných průhledných PNG, 6 nových pozadí, 171 přednastavených scén a jednu hratelnou zkušebnu**. Osm sad pokrývá les, vesnici, oblohu, hrad, obří zahrady, řeku vzpomínek, hvězdné hory a Srdce království. Dalších 18 objektů tvoří společné mechanismy a příběhové předměty.

## Instalace

1. Rozbal archiv a zkopíruj jeho složky `assets`, `scenes`, `scripts`, `docs` a `tools` do kořene existujícího projektu STARBIT, vedle `project.godot`.
2. Otevři projekt v Godotu **4.7.2** a nech dokončit import obrázků.
3. Otevři `scenes/showcases/WorldAssets.tscn` a stiskni **F6**.
4. Klávesy **1–8** přepínají prostředí; **A/D nebo šipky** ovládají Bita, **mezerník** skok, **E** interakci a **R** obnovu zkušebny.

Balíček rozšiřuje existující repozitář `dersi128/STARBIT-Kralovstvi-snu`, základ `6b4d4f37aab920ad86d0069710cfe1763693d56d`. Potřebuje původní Bita, jeho animace, systém interakcí a původní pozadí. Nejde o samostatný nový projekt. Žádný současný level ani hlavní scéna se nepřepisuje.

## Katalog a soubory

- **KATALOG.html**: otevři dvojklikem po rozbalení; vyhledávání, filtry, PNG, scény, náhledy prostředí a rozpis levelů. Funguje offline bez instalace.
- `assets/environment/worlds/<sada>/`: samostatná PNG s opravdovým alfa kanálem.
- `assets/environment/worlds/backgrounds/`: šest celých pozadí v rozlišení 2688 × 1520.
- `scenes/world_assets/<sada>/`: scény k přetažení do editoru.
- `LEVEL_MAP.md`: konkrétní vazba všech 30 levelů na objekty a prostředí.
- `ART_NOTES.md`, `generation_manifest.json`: reference, prompty a původ grafiky.
- `assets/environment/worlds/manifest.json`: rozměry, kotevní body, obrysy pastí a kontrolní součty.

## Připravené chování

| Scéna | Chování a umístění |
| --- | --- |
| `platform_long`, `ledge` | Pevná kolize; počátek scény leží uprostřed nášlapné hrany. |
| `lift_deck` | Pohyblivá plošina s fyzikálním převozem Bita. `travel` určuje dráhu, `period` délku celého cyklu. |
| `Lift` | Složený výtah: pevné kladky, dvě průběžně navazující lana a pohyblivá podlaha. Nastavení pohybu je na uzlu `Deck`. |
| `crumble_platform` | Po stoupnutí upozorní chvěním, po sekundě zmizí kolize a za 3,5 s se obnoví. Časy lze změnit. |
| `pressure_plate` | Spouští cíle po došlápnutí Bita nebo přitlačení bedny. Výchozí `latch` ponechá aktivovaný stav. |
| `gate` | Po `set_powered(true)` se vysune nahoru včetně kolize. |
| `hazard` | Kolize podle obrysu; zavolá stávající `Bit.hurt()`. Respektuje jeho dobu nezranitelnosti. |
| `repair_socket` | Vyžaduje předmět `repair_gear`, spustí Bitovu opravu a vloží kolečko do samostatně zaměřeného otvoru. |
| `common/gear` | Sbíratelná součástka pro opravu; využívá existující inventář a animaci sběru. |
| `common/Lever` | Hotová páka s oddělenou otočnou rukojetí a animací aktivace Bita. |
| `story/*` | Sbíratelné příběhové předměty s vlastními ID. |

Propojení se nastavuje v poli `targets` na spínači, páce nebo opravovaném mechanismu. Vyber uzly, které podporují `set_powered(bool)` — například bránu nebo složený výtah. Pro podmíněnou interakci použij existující `required_item`, `required_flag` a `completion_flag`. Level musí používat původní skupinu `level`, slovníky `inventory` a `completed_actions` a Bitův systém `story_interactions`, stejně jako první level.

Dekorace mají počátek u paty, samostatná kola lze otáčet kolem středu. Výtah je připravený pro svislý pohyb; pro změnu výšky uprav i polohu horních kladek. Plošiny jsou celé siluety, nikoli bezešvé dlaždice: nenapojuj jejich ukončené hrany jako opakovanou texturu země. Pro souvislou zem používej existující terénní systém hry. Měřítko měň rovnoměrně, aby se kresba nedeformovala.

## Rozsah balíčku

Balíček poskytuje stavební grafiku a základní opakovaně použitelné objekty. Rozmístění ve všech 30 levelech, příběhové události a bossové se řeší při stavbě levelů. Pružina, ventil, řetěz, zrcadla, lucerna checkpointu a podobné dekorativní díly nemají v tomto balíčku vlastní specializovanou herní logiku. Nepřidává nové postavy, animace nepřátel, hudbu ani zvuky.

Sady mají jednu základní grafickou podobu; rozsvícení, vypnutí, pohyb a upozornění používají samostatné díly a nastavení scén. Světlo nebo stín pro konkrétní level lze doplnit přes `CanvasModulate` a `PointLight2D`, bez překreslení původních souborů. Podzemní kořeny a potemnělý návrat mají navíc vlastní pozadí.

## Ověření a opakování

Grafika byla skutečně prohlédnuta samostatně i v kompozicích s Bitem při herním měřítku. Příprava obrázků proběhla v Higgsfieldu. Ověření Godotu probíhá bez grafického okna; plnohodnotnou vizuální kontrolu živé zkušebny proveď po otevření F6. Přiložené kompozice jsou kontrolní náhledy, nikoli snímky z běžícího Godotu.

Kontrolu scén a propojení lze spustit příkazem:

```sh
godot --headless --path . --fixed-fps 60 --script res://tools/world_assets/verify.gd
```

`tools/world_assets/build_prefabs.py` obnoví pouze scény tohoto balíčku; nepoužívej jej po vlastních ručních úpravách těchto nových scén. `build_catalog.py` obnoví katalog. `higgsfield_process.py` dokumentuje zpracování v Higgsfieldu a očekává tam stažené zdrojové atlasy. Historické generátory levelů se nepoužily.
