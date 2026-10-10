# Lesní assety STARBIT / Higgsfield

Vytvořeno v Higgsfieldu pro tuto úpravu 1. levelu, model gpt_image_2_5.
Reference: existující Bit, forest.png a platforms_starbit_v2.png z repozitáře
STARBIT-Kralovstvi-snu, commit 103ab43ff5fbad85a2ff0ba6472455c0e8a58eba.

- forest_platforms.png: 2048 × 1360, RGBA; tráva, kmen, kámen, list.
  Job ec1e079e-87c7-4eb1-9fef-ede608c8335e.
- forest_landmarks.png: 2048 × 1360, RGBA; dutý strom, skalní oblouk,
  dřevěná branka, kapradí. Job 9353a39c-3a29-413a-903e-befed8cb0a10.
- forest_glade.png: 2688 × 1520, RGB; klidné lesní pozadí.
  Job 1a737457-8e1d-4823-9cee-b8690f2a91c7.
- forest_soil.png: jemnější lesní zemina, kořínky a drobné kameny.
  Job 4a292932-6833-43e6-b06c-4bfca915d15e; reference forest_platforms.png.
  Přidáno při sjednocení terénu 10. 10. 2026.

PNG jsou původní dokončené výstupy. AtlasTexture .tres oddělují jednotlivé
objekty bez přepisování obrázků. Celkem čtyři dokončené generace obrázků.

Plošiny využívají existující castle_platform.gd (wall_body=false): pevná výška,
opakování vnitřního dílu a zachované proporce krajů. Změna šířky nezvětšuje celý
ostrov. Hodnoty surface_walk_y v Level_01 zarovnávají obrázek s kolizí.
Pohyblivé plošiny používají původní platform.gd/castle_lift.gd; most původní
linked_platform.gd. Nová herní mechanika nebyla přidána.

Vizuální propojení prostředí:
- forest_bank.gd rozšiřuje původní terrain_body.gd a kreslí jemnější zeminu.
  Tráva se se zeminou překrývá; mezi nimi nezůstává pruh oblohy.
- grass_lip.tres / stone_lip.tres a forest_ground_blend.gdshader změkčují
  přechod okraje plošiny do zeminy. Wood atlas vynechává opakované pahýly.
- forest_support.gd kreslí větve, stonky a zavěšení mezi plošinami a prostředím.
  Nemá kolize a nemění pohyb. Anchor / Second Anchor jsou souřadnice v levelu;
  koncový bod se přizpůsobí pohybu plošiny.
- Duby, jeskynní oblouk, kapradí a lucerna propojují jednotlivé úseky.

Tyto doplňky jsou zapojené pouze do Level_01. Ve scéně se nezměnily rozměry
kolizí, dráhy plošin ani pozice herních objektů oproti předchozímu tutoriálu.
Samostatně objednané video textury není součástí herního balíčku.

Další použití: zkopíruj vhodný uzel z Level_01 do vlastního levelu. Uprav Position,
Width, Travel a Period v inspektoru. Atlasové .tres lze také přiřadit Sprite2D.
