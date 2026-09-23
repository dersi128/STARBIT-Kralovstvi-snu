# Cesta za sny – hudba menu STARBIT

Původní skladba vytvořená pro STARBIT / Velora. 48 taktů, 4/4, 108 BPM, G dur; délka 106,667 sekundy. Intro, hlavní melodie, její variace, klidnější střední část, návrat a spojení do smyčky. Melodie není převzatá z jiné skladby.

- `menu_adventure.ogg`: hotový stereo záznam 44,1 kHz, který přehrává Godot.
- `menu_adventure.mid`: jednotlivé nástroje pro další úpravy v hudebním editoru.
- `tools/menu_music/compose_menu.py`: noty, aranžmá a export.
- `tools/menu_music/render_score.c`: samostatný offline převod not do zvuku.

## Nástroje a licence

Zvuk nástrojů pochází ze SoundFontu **GeneralUser GS 2.0.3**, autor S. Christian Collins. Licence povoluje tvorbu soukromých i komerčních hudebních nahrávek; přiložena je v `licenses/GeneralUser-GS-LICENSE.txt`. Banka samotná není v projektu přibalena a ke hraní není potřeba.

Oficiální zdroj: https://github.com/mrbumpy409/GeneralUser-GS

Převod zajišťuje **TinySoundFont** (MIT), autor Bernhard Schelling. Zdroj `tsf.h` a licence jsou ve `tools/menu_music`. Oficiální zdroj: https://github.com/schellingb/TinySoundFont

## Opětovné vytvoření zvuku

Pouze pro vývoj; pro hraní nic neinstaluj. Potřeba je Python 3 s numpy a scipy, ffmpeg, C kompilátor a soubor `GeneralUser-GS.sf2` z oficiálního repozitáře.

Z kořene projektu na Linuxu/macOS:

```sh
cc -O2 tools/menu_music/render_score.c -lm -o render_score
python3 tools/menu_music/compose_menu.py --font /cesta/GeneralUser-GS.sf2 --renderer ./render_score
```

Výstup znovu zapíše OGG a MIDI do `assets/audio`. Smyčka obsahuje dozvuk předchozího opakování a krátké vyhlazení švu. Hudbu v menu pouští `Progress.play_music("menu_adventure")`; používá stávající společný vypínač zvuku.

Finální OGG: přibližně −16,98 LUFS, špička −4,44 dBTP. Menu navíc používá hlasitost přehrávače −12 dB a náběh 0,65 s.
