# Herní hudba STARBIT

`adventure.ogg` je herní úprava nahrávky z uživatelem dodaného souboru
`hudba .mp4`. Hudební systém ji už používá pod názvem `adventure` během běžného
hraní; výměna nevyžaduje změnu skriptů ani levelů.

## Výsledný soubor

- Délka 80,845 s; stereo, 48 kHz, Ogg Vorbis (kvalita 4).
- Přibližné tempo původní nahrávky: 95 BPM.
- Naměřená hlasitost po zakódování: −18,05 LUFS; true peak −4,39 dBTP.
- Smyčka je zapnutá v importu, začíná od 0 s. Řadič `Progress.play_music`
  ji navíc zapíná stejně jako u dosavadní herní hudby.

## Úpravy

Z původních 52,181 s byla použita část 5,465–48,414 s. Přechod o délce jednoho
taktu (2,526 s) spojuje její konec se začátkem a vytváří 40,422s smyčku.
Dva průchody tvoří delší celek; ve druhé části se zvuk velmi jemně zateplí,
stereo nepatrně zúží a následně se vrátí k původní barvě. Tempo ani melodie
se neposouvají. Byly omezeny nejnižší frekvence pod 32 Hz a nejvyšší nad
14,5 kHz, hlasitost byla snížena o 4,5 dB.

Soubor pro hru nemá vloženou pauzu ani závěrečné ztišení. Nástup po zapnutí
zajišťuje stávající prolínání v `Progress`. MP3 náhled mimo repozitář má
krátký nástup a zakončení pouze pro pohodlný poslech.

## Ověření

Původní soubory byly načteny z `dersi128/STARBIT`, commit
`90e3b0916ade1c25d0948148182d77a81dc542fc`.

Dekódovaný OGG nemá ticho na spoji a nepřekračuje strop −2 dBFS. Krok mezi
posledním a prvním vzorkem je menší než běžné změny signálu uvnitř skladby.
Godot 4.7.2 prošel devíti kontrolami existujícího hudebního řadiče: načtení,
smyčka, hlasitost, skutečné přehrání přes konec skladby, pauza, pokračování,
volba menu skladby, přechod na bosse a ztlumení.

Test byl spuštěn samostatně přes autoload `Progress`. Celou hru z tohoto
commitu nelze spustit: `project.godot` odkazuje na `res://Main.tscn`, který
v repozitáři chybí. Tato změna hlavní scénu nedoplňuje.
