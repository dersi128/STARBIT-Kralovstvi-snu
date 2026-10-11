# Probuzení pod kořeny – nové assety

Vytvořeno v Higgsfield pro tento projekt, 10. října 2026, model GPT Image 2.5.
Referenční vzhled pochází ze stejného repozitáře, commitu
`e9e435e24bda24ed7e3800058c887436d5c04a5e`.

- Rekvizity: job `c40889e9-eb40-4292-8b3c-fbb962a0b9dd`.
  Reference `assets/environment/forest/higgsfield/forest_landmarks.png`.
  Zarostlá dílna, naviják s chybějícím kolem, páka a ozubené kolo.
- Bitovy interakce: job `fbb89c2b-065b-42b3-a6dc-233284f34ad0`.
  Reference `assets/characters/animations/bit_v2/motion.png` a
  `assets/characters/animations/bit_push.png`. Čtyři snímky opravy klíčem,
  čtyři snímky natažení a zatažení rukou, čtyři snímky zvednutí předmětu.

Rekvizity byly rozděleny a bílé pozadí převedeno na průhlednost. U Bita se
odstranilo jen pozadí spojené s okrajem, aby jeho bílý pancíř zůstal neprůhledný.
Všechny akční snímky používají společné měřítko a zarovnaná chodidla.
Páka má samostatnou základnu a rukojeť; základna se při aktivaci nepohybuje.

Původní barevnost: zelená a tyrkysová, teplé dřevo a mosaz, tmavé kreslené
obrysy. Dřevěné plošiny používají existující lesní textury.

## Oprava návaznosti terénu

- Travnatý lem: Higgsfield GPT Image 2.5, job
  `8de4faad-2fc0-44dd-9205-76c703f8cc63`, 10. října 2026.
  Stejná reference lesních rekvizit. Zadání: rovný travnatý pás s převislými
  listy, bez kmenů, keřů a hlíny, bílé pozadí pro extrakci průhlednosti.
- `grass_rim.png`: ořez výšky a odstranění bílého pozadí, 1344 × 197 px.
  Návaznost se řeší zrcadleným vzorkováním textury ve shaderu, není závislá
  na tom, zda generátor vytvořil totožné pixely na obou stranách obrázku.
- Srdíčka a ikona pauzy jsou nové vektorové SVG v `assets/ui/adventure`.
  Kolečka, diamanty a hvězda zachovávají původní ilustrace a poměr stran.
