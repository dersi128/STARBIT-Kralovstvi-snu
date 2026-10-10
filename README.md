# STARBIT – Království snů

Existující hra pro Godot 4.7.2. Otevři `project.godot`; hlavní scéna je `Main.tscn`.
Hratelné levely jsou v `levels/Level_01.tscn` až `levels/Level_10.tscn`.

## Kde najít assety

| Co hledáš | Složka |
| --- | --- |
| Rozstříhané dekorace a plošiny pro první lesní level | `assets/environment/forest/cutouts/` |
| Původní lesní pozadí, zemina a Higgsfield atlasy | `assets/environment/forest/higgsfield/` |
| Ostatní pozadí | `assets/environment/backgrounds/` |
| Mraky, mlýny, zvonky, vodní ostrovy | `assets/environment/sky/` |
| Hrad, nádvoří a zahrady | `assets/environment/castle/` |
| Animovaná voda | `assets/environment/water/animated/` |
| Původní sady plošin a dekorací | `assets/environment/worldkit/`, `scenery/`, `expansion/`, `supplied/` |
| Bit, Fouk, bossové a animace postav | `assets/characters/` |
| Menu a fonty | `assets/ui/` |
| Hudba / zvukové efekty | `assets/audio/music/`, `assets/audio/sfx/` |
| Společné starší výřezy používané herním vykreslováním | `assets/shared/pieces/` |

PNG je jen obrázek. Hotové objekty s kolizemi a chováním najdeš v `scenes/`;
ukázky sad jsou v `scenes/showcases/`. Rozložení vlastní hry upravuj v `levels/`.

Podrobný rozcestník: [ASSETY.md](docs/ASSETY.md).
Obrázkový přehled lesních výřezů: [PREHLED.jpg](docs/assets/forest/PREHLED.jpg).

## Pravidla pro pořádek

- Nové obrázky vkládej do příslušné složky v `assets/`, ne do kořene projektu.
- Soubory v již používané hře přesouvej přes panel FileSystem v Godotu, který
  umí aktualizovat návaznosti. Při změnách mimo editor je nutné opravit i odkazy.
- Soubory `.import` a `.uid` verzuj společně se zdrojem. Obsahují nastavení
  importu a identifikátory; nejsou to zbytečné duplikáty.
- Exportované APK patří mimo projekt nebo do `builds/`. Importní cache `.godot/`
  a lokální exporty se na GitHub nepřidávají.
- Historické pokusy jsou v `archive/`, dokumentace a starší ověření v `docs/`.
  Tyto složky jsou skryté před importem Godotu.

## Kontrola projektu

Po stažení přesunutých souborů nech Godot dokončit import.
Kontrola vazeb a načtení všech deseti levelů:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/repository_integrity.gd
```

Test spusť nad testovací kopií uloženého postupu. Kontrola ověřuje načítání,
nikoli úplný průchod levely ani jejich vizuální vzhled.
