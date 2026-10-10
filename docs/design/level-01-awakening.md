# Level 1 – Probuzení pod kořeny

První hratelná verze nového příběhu. Krteček najde Bita v zarostlé dílně,
předá Jiskřin vzkaz a pošle ho na cestu k hradu. Bit má obyčejný skok.

## Jak vyzkoušet

Otevři tento projekt v Godotu 4.7.2. Spusť `levels/Level_01.tscn` klávesou F6,
nebo celou hru klávesou F5 a zvol Nová hra.

- Pohyb: A/D nebo šipky.
- Skok: mezerník nebo šipka nahoru; delší stisk znamená vyšší skok.
- Interakce: E. Na dotykové obrazovce tlačítko Akce.
- Pauza: Escape.

## Cesta levelem

1. Dílna pod kořeny a Krtečkův vzkaz.
2. Dva kořeny pro bezpečný nácvik skoků; dole je pevná zem.
3. Checkpoint před opravou. Bednu lze přisunout pod polici.
4. Z bedny vyskočit na polici a klávesou E sebrat ozubené kolo.
5. U navijáku stisknout E. Bit dvě sekundy opravuje a vloží součástku.
6. U páky stisknout E. Rukojeť se otočí a most se postupně rozvine.
7. Checkpoint za mostem, jeden pomalý Šutřík a dva krátké přeskoky.
8. Poslední checkpoint, hvězda na větvi a brána do dalšího levelu.

Dvanáct diamantů je dobrovolných. Hvězda a spuštěný most jsou podmínkou cíle.
Prototyp má délku 7 000 herních jednotek; přesný čas a obtížnost doladíme hraním.

## Neúspěch a uložené úkoly

Bit má tři srdíčka. Zásah ubere jedno a na 1,3 sekundy poskytne ochranu.
Pád ubere jedno a vrátí Bita na naposledy ověřenou bezpečnou plochu.
Při vyčerpání srdíček se vrátí na checkpoint se třemi srdíčky.
Nový checkpoint také doplní zdraví. Počet pokusů není omezený.

Sebraná součástka, opravený naviják, otevřený most a sebrané diamanty zůstávají
v aktuálním rozehraném levelu zachované i po neúspěchu. Dokončená oprava součástku
spotřebuje právě jednou. Přerušená oprava ji nespotřebuje. Pauza zastaví i průběh
interakce. Ruční Restartovat level založí nový pokus od začátku; ukládání
rozehraných úkolů po vypnutí aplikace tato verze nepřidává.

## Úpravy v editoru

Rozmístění je přímo v `Level_01.tscn`. Interaktivní uzly Gear, Winch a Lever
používají `story_interaction.gd`: typ akce, předmět, podmínka, příznak dokončení
a cílové NodePath jsou exportované vlastnosti. Nové scény mohou zapnout srdíčka
vlastností `use_hearts` na kořenovém levelu.

`bit_interactions/frames.tres` obsahuje animace repair, activate a pickup.
Všech 12 obrázků má společné měřítko, plátno 384 × 384 a chodidla na y=356.
Animace mění jen kresbu Bita, nikoli jeho kolizní tvar.

## Ověření

V Godotu 4.7.2 je přidaný `tests/awakening_playthrough.gd`. Projde autorskou
cestu skutečným vstupem pro pohyb, skok a interakci: posune bednu, vyskočí
na polici, sebere kolo, opraví naviják, otevře most, překoná nepřítele a
mezery, sebere hvězdu a odemkne druhý level. Kontroluje také ochranu po zásahu,
checkpointy, zachování úkolů, pauzu a přerušení rozpracované opravy.

Spouštěj testy s odděleným adresářem uživatelských dat, aby neovlivnily uloženou hru:

```bash
XDG_DATA_HOME=/tmp/starbit-test-save godot --headless --path . --editor --import
XDG_DATA_HOME=/tmp/starbit-test-save godot --headless --fixed-fps 60 --path . --script res://tests/awakening_playthrough.gd
XDG_DATA_HOME=/tmp/starbit-test-save godot --headless --path . --script res://tests/repository_integrity.gd
```

Grafické assety byly prohlédnuty po odstranění pozadí a zarovnání snímků.
Testovací prostředí umožnilo běh logiky bez okna; výslednou kompozici, zvuk
a pocit z ovládání je ještě potřeba posoudit při hraní v editoru.
