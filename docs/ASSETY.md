# Rozcestník assetů

Pro stavění prvního levelu začni v `assets/environment/forest/cutouts/`.
Všechny výřezy jsou samostatná PNG s průhledným pozadím.

| Podsložka výřezů | Obsah |
| --- | --- |
| `landmarks/` | Dutý strom, jeskynní oblouk, dřevěná branka, kapradiny |
| `trees_and_structures/` | Další stromy, kmen, ruiny, vyhlídka, plot |
| `plants_and_rocks/` | Keře, houby, kameny, pařez a liány |
| `props/` | Lucerny, ploty, lavička a budka |
| `platforms/` | Čtyři obrázky plošin bez vlastní kolize |

Původní pozadí je `assets/environment/forest/higgsfield/forest_glade.png`.
Zemina je `assets/environment/forest/higgsfield/forest_soil.png`.
Každá textura je v projektu pouze jednou; kopie z rozbaleného balíčku byly sloučeny.

[Přehled výřezů](assets/forest/PREHLED.jpg) · [Návod](assets/forest/JAK_POUZIT.txt)

## Další sady prostředí

`environment/worldkit/` obsahuje původní společné atlasy, textury terénu a jejich
`.tres` výřezy. `environment/supplied/pieces/` obsahuje starší jednotlivé obrázky;
jejich hotové herní scény jsou stále v `scenes/supplied/`.

`environment/scenery/` obsahuje sadu stromů a ruin. `environment/expansion/`
obsahuje vesnické a zahradní atlasy. `environment/castle/` obsahuje hradní sady.
Podadresáře různých generací jsou zachované, protože se kresby skutečně liší.

Atlasy a samostatné výřezy nejsou automaticky duplicity: `.tres` zdroje často
vyžadují celý atlas. Ověřené totožné velké atlasy jsou sjednoceny v `worldkit/`.

## Postavy, zvuky a podklady

- `characters/animations/`: SpriteFrames a kresby animací; soubory jako
  `boss.tres` a `rock_enemy.tres` používá také dynamické načítání podle typu.
- `characters/bit/`: další pózy Bita a původní dodané animační podklady.
- `characters/fouk/`, `characters/stinko/`, `characters/bosses/`: konkrétní postavy.
- `shared/pieces/`: výřezy používané společným vykreslováním a jako náhradní pózy.
- `source_sheets/`: původní celkové předlohy; nejsou určené k přetažení jako jeden objekt.
- `audio/alternatives/`: dřívější varianty zvuků bosse, nyní mimo aktivní banku.
  Zůstaly k případnému opětovnému použití; Android export je vynechává.
- `audio/sources/`: zdrojové MIDI. Licence zvuků a fontů jsou zachované.

Scéna `scenes/Bit.tscn` používá `scripts/player.gd`. Odložený zkušební hráč
z původního kořene projektu je v `archive/prototypes/bit/`.

Staré generátory map v `archive/generators/` jsou historické podklady, nikoli
nástroj pro dnešní ruční úpravy. Jejich původní algoritmus přepisuje celé levely.

Soubor [maintenance/cleanup-2026-10-10.json](maintenance/cleanup-2026-10-10.json)
obsahuje přesnou mapu přesunů a záznam sloučených duplicit.
