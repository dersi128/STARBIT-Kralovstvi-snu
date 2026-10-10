# Živá zákoutí STARBITu

Nová grafika používá stejnou slonovinovou, zlatou, modrou a mátovou paletu jako palácové atlasy. Jde o dekorace bez kolizí a odměn. Všechny se vykreslují za Bitem.

V Godotu jsou pod uzlem `LivingDetails` v levelech 8–10. U jednotlivých prvků lze změnit `Kind`, `Height`, `Phase`, `Mirrored` a `Growth Source`. Pozice je spodní střed obrázku; u praporu a lustru je to horní závěs. Lustry mají samostatné závěsné řetězy ve scéně. Pole `ground_surface` / `mount_surface` v metadatech označuje opěrnou plošinu nebo konstrukci.

`royal_life.tres` obsahuje výřezy z nového atlasu a původní lucernu i prapor. Průhlednost PNG je zachována. Kašny mají pohyb vody, lustry teplé mihotání, prapory mírný pohyb spodní látky. Motýli odlétnou výš při přiblížení hráče. Vybrané prvky zahrady se rozjasní po aktivaci sluneční nebo měsíční fontány. Pohyb se pozastaví spolu s levelem a mimo záběr se nepočítá.

## Původ grafiky

Nový `royal_life_atlas.png` (1536 × 1024 RGBA) vznikl vestavěným imagegen. Výřezy jsou deklarované jako AtlasTexture; pixely se dodatečně neupravovaly. Nové obrázky: kašna, lavička, květiny, čtecí pult, lustr, kamenná sova.

Zadání: šest oddělených dekorativních objektů ve třech sloupcích a dvou řádcích, shodný lesklý ručně malovaný pohádkový styl STARBITu, zaoblené obrysy, slonovina/zlato/modrá/máta, pohled pro boční plošinovku, průhledné pozadí a široké mezery; nahoře malá dvoupatrová kamenná kašna s tyrkysovou vodou, dřevěná lavička s hvězdnými detaily, nízké květiny s kapradím a modrými houbami; dole pult s otevřenou knihou, závěsný lustr se svíčkami a kamenná spící sova na podstavci; bez textů, popisků, postav a podlahových stínů.
