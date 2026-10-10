# Ověření prvního levelu

Engine: Godot 4.7.2.stable.official.ed1daf0bf, 60 fyzikálních kroků/s.
Testování probíhalo bez grafického okna, s původní fyzikou projektu.

- Běžná cesta od spawnu k výsledkové obrazovce: prošla, 0 úmrtí, 19/25 diamantů.
- Celý průchod včetně všech odboček: prošel, 0 úmrtí, 25/25 diamantů.
- Oba průchody ovládaly Bita vstupy; neposouvaly jej, neodemkly puzzle ani bránu
  testovacím kódem. Rychlost 390, skok 650, bez Fouka v 1. levelu.
- Skutečné kontakty s nepřáteli, tlačítky, bednou, pružinou, pohyblivými plošinami,
  hvězdou i portálem ověřeny během průchodu.
- Krtečkův dialog vyvolal pozastavení a byl potvrzen skutečným UI vstupem.
- Samostatné kontroly před vizuální úpravou: návraty z dolních cest, první skoky z obou stran,
  západní návrat od vodopádu, nezvednutý most, dolní cesta pod plošinou,
  oba návraty zpod korun stromů. Prošly.
- Tyto dílčí kontroly nastavily jen počáteční pozici testovacího úseku;
  samotný návrat pak proběhl pomocí ovládání a původních kolizí.
- Oba checkpointy aktivovány kontaktem. Tři skutečné pády následně vedly
  k bezpečnému respawnu. Otevření průchodu bednou zůstalo po respawnu zachováno.
- Přímé spuštění Level_01 (stejná vstupní cesta jako F6) ověřeno.
- git diff --check: bez problémů.

Po sjednocení prostředí byly znovu provedeny běžný průchod a průchod se všemi
25 diamanty. Průchod se všemi diamanty používá finální podobu souborů.
Porovnání scény s předchozím tutoriálem ověřuje zachování herních pozic,
kolizí, rozměrů, dráhy a rychlosti pohyblivých plošin. Přidané uzly jsou dekorace.

Hranice ověření: zkontrolovány zdrojové PNG, geometrie a šest softwarových
kompozic částí scény. Kompozice nejsou skutečné screenshoty z Godotu a neověřují
vykreslení shaderů. Grafické prostředí zde nešlo spustit; nebyl proveden vizuální
průchod celé scény v grafickém okně ani test na telefonu. Hlavička se zachovaným
UID a závislosti scény se v Godotu načítají. Automatické ukončení Godotu vypisuje upozornění na zbývající prostředky při ukončení procesu;
průchody nezaznamenaly chybu skriptu za běhu. Přehled není tvrzením, že je hra
kompletně bez chyb. Pětiminutové tempo a srozumitelnost pro děti vyžadují hráčský test.
