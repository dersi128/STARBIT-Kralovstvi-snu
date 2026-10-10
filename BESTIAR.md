# STARBIT – Bestiář

Grafika podle současných předloh z GitHubu a příběhu `STARBIT-Pribeh-hry(2).txt`.

**Stav:** 20 statických PNG (12 nepřátel, 6 bossů, 2 osvobozené podoby). Chování níže je návrh k implementaci, nikoli hotový kód.

## Běžní nepřátelé

| Postava | Levely | Chování | Varování před akcí | Řešení pro Bita |
| --- | --- | --- | --- | --- |
| **Stínko** | 2–4; později 26–29 | Hlídá krátký úsek cesty. | Před obratem zvedne ocas; po krátkém výpadu zastaví. | Přeskočit ho nebo obejít během pauzy. |
| **Kořenový skokan** | 2–4; 13–14 | V pravidelném rytmu skáče mezi dvěma místy. | Před skokem se přikrčí a kořeny se stlačí. | Projít pod ním při výskoku nebo počkat na dopad. |
| **Lampovník** | 3; 9; 22; 26 | Kráčí a občas vyšle nízký světelný pulz. | Fialový plamen krátce zesílí před pulzem. | Přeskočit pulz a přejít za něj. |
| **Mrakomor** | 6–8 | Vznáší se po krátké dráze a vypouští déšť v úzkém sloupci. | Ztmavne, nafoukne tváře a zastaví před deštěm. | Projít po konci deště; povinné řešení v 8. levelu i bez Zipa. |
| **Trnový brouk** | 11–14 | Pomalu hlídkuje; trnitý krunýř chrání shora. | Před rozběhem sklopí hlavu a zvedne krovky. | Vyhnout se mu; nespoléhat na skok na trnitá záda. |
| **Rosička** | 11–14 | Stojí na místě a vystřeluje jednotlivá semínka. | Květ se zavře a nabobtná před výstřelem. | Projít během nadechnutí nebo využít kryt. |
| **Kapkovec** | 12; 16–17 | Vyskakuje z mělčiny na blízký břeh. | Voda se rozvlní před vynořením. | Počkat na jeho návrat do vody. |
| **Vřetenka** | 11; 14; 21 | Létá po čitelné smyčce a krátce klesá. | Zpomalí otáčení křídel před sestupem. | Projít pod ní, když stoupá. |
| **Zrcadlenka** | 17–20 | Krátce napodobuje poslední směr pohybu hráče. | Skutečný tvor nese zlatý zářez; klam ho nemá. | Změnit rytmus a rozpoznat pravou podobu. |
| **Ozvěna** | 16–19 | Pluje nad vodou a na chvíli opakuje svou předchozí dráhu. | Před opakováním zanechá krátkou tyrkysovou stopu. | Využít předvídatelnou mezeru v pohybu. |
| **Můra soumraku** | 21–25 | Přilétá k rozsvíceným lucernám a pokouší se je zhasnout. | Obkrouží vybranou lucernu před sestupem. | Aktivovat světelný mechanismus včas nebo ji odlákat. |
| **Kořenový hlídač** | 26–29 | Pomalý těžký strážce servisních průchodů. | Zvedne pěst před úderem a po něm zůstane stát. | Vyhnout se úderu a v pauze opravit průchod. |

## Bossové

| Boss | Level | Princip souboje | Důležitá návaznost |
| --- | --- | --- | --- |
| **Brúčoun – očarovaný** | 5 | Výpad a úder tlapami s krátkou otřesovou vlnou. Po vyhnutí aktivovat tři pečetě brány, které lámou kouzlo. | Boss z příběhu; zachována koruna, tlapy a kamenné náramky. |
| **Trnový obr – očarovaný** | 15 | Zvedá kořeny a blokuje přívody vody. V pauzách obnovit tři přívody vody; kouzlo povolí. | Boss z příběhu. Kapka života přichází až od uzdraveného stromu. |
| **Zámkovník** | 10 | Hlídá věž a střídavě zakrývá tři stínové zámky. Postupně uvolnit tři zámky a zachránit Jiskru. | Nový volitelný boss navržený k obraně věže; původní příběh ho nejmenuje. |
| **Strážce zrcadel** | 20 | Skrývá se mezi kopiemi a mění jejich rozmístění. Rozpoznat pravého a odkrýt jeho zrcadlo v bezpečné chvíli. | Boss z příběhu; Perla vzpomínek se získá až po něm. |
| **Požírač hvězd** | 25 | Nasává světlo a sesílá pomalé stínové vlny. Udržet osadní lucerny rozsvícené a využít pomoc obyvatel. | Boss z příběhu; Hvězda naděje vznikne po obraně osady. |
| **Morous** | 28 setkání; 30 závěrečný souboj | Ovládá temné kořeny a vytváří stínové kopie. Zapojit tři esence a otočit tok magie mechanismem; vždy stačí obyčejný skok. | Skutečný Morous se Bitovi osobně ukáže až v levelu 28. |

## Osvobozené podoby

- **Brúčoun:** laskavější výraz, zelené listy, zlatá hvězda. Zůstává medvědem se stejnou korunou a kamennými náramky.
- **Trnový obr:** otevřené květy a zdravá zeleň. Zachovává dřevěné tělo i zářící semínkové jádro.

## Pravidla návrhu

- Bit řeší problémy pohybem, načasováním a opravami mechanismů. Souboje nemusejí vyžadovat novou zbraň.
- Každému nebezpečnému pohybu předchází čitelný signál; po útoku následuje prostor k reakci.
- Stíny se rozpouštějí; očarovaní tvorové a předměty se osvobozují.
- Obtížnost vzniká kombinací rozdílných vzorců pohybu, ne jen rychlejšími barevnými kopiemi.
- Žádný pozdější souboj nevyžaduje Zipův dvojskok. Od 9. levelu musí povinné cesty stačit na obyčejný skok.
- Zámkovník je doplnění návrhu pro level 10, nikoli postava výslovně pojmenovaná v dodaném příběhu.
- U Strážce zrcadel zachovat zlatý znak na pravé postavě; levé/pravé otočení nesmí zrušit možnost rozeznání.

## Navržené měřítko vůči Bitovi

| Postava | Výška vůči Bitovi | PNG |
| --- | --- | --- |
| Stínko | 0,65× | `png/nepratele/stinko.png` |
| Kořenový skokan | 0,75× | `png/nepratele/korenovy_skokan.png` |
| Lampovník | 0,8× | `png/nepratele/lampovnik.png` |
| Mrakomor | 0,8× | `png/nepratele/mrakomor.png` |
| Trnový brouk | 0,65× | `png/nepratele/trnovy_brouk.png` |
| Rosička | 0,8× | `png/nepratele/rosicka.png` |
| Kapkovec | 0,65× | `png/nepratele/kapkovec.png` |
| Vřetenka | 0,7× | `png/nepratele/vretenka.png` |
| Zrcadlenka | 0,85× | `png/nepratele/zrcadlenka.png` |
| Ozvěna | 0,65× | `png/nepratele/ozvena.png` |
| Můra soumraku | 0,75× | `png/nepratele/mura_soumraku.png` |
| Kořenový hlídač | 1,2× | `png/nepratele/korenovy_hlidac.png` |
| Brúčoun – očarovaný | 2,3× | `png/bossove/brucoun_ocarovany.png` |
| Brúčoun – osvobozený | 2,3× | `png/osvobozeni/brucoun_osvobozeny.png` |
| Trnový obr – očarovaný | 3× | `png/bossove/trnovy_obr_ocarovany.png` |
| Trnový obr – osvobozený | 3× | `png/osvobozeni/trnovy_obr_osvobozeny.png` |
| Zámkovník | 2,2× | `png/bossove/zamkovnik.png` |
| Strážce zrcadel | 2,5× | `png/bossove/strazce_zrcadel.png` |
| Požírač hvězd | 3,2× | `png/bossove/pozirac_hvezd.png` |
| Morous | 1,5× | `png/bossove/morous.png` |

Měřítka jsou herní návrh. Soubory jsou oříznuty individuálně a jejich pixelové velikosti samy neurčují velikost postav ve scéně.

## Grafický původ

[Existující repozitář STARBIT – Království snů](https://github.com/dersi128/STARBIT-Kralovstvi-snu).
Přímé obrazové předlohy: `assets/shared/pieces/boss.png`, `assets/characters/bit/source_sheets/Run1.png`, `assets/characters/stinko/frames/00.png`.
Generováno pomocí Higgsfieldu. Původní atlasy a zadání jsou součástí balíčku.
