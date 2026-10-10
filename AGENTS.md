# STARBIT – pravidla práce v projektu

## Rozsah změn

- Základem je existující hra v Godotu. Upravuj jen soubory, scény, skripty
  a assety potřebné pro konkrétní zadání.
- Nový projekt, kompletní přepis hry nebo změnu výtvarného směru dělej pouze
  na výslovné přání uživatele.
- Zachovej ruční úpravy levelů. Historické generátory v `archive/` nepoužívej
  k přepsání současných scén.

## Grafická kontinuita

Před tvorbou nebo úpravou obrázků, animací, nepřátel, bossů, objektů a pozadí
přečti [pravidla grafického stylu](docs/design/STARBIT-GRAFICKY-STYL.md)
a prohlédni skutečné referenční obrázky uvedené v dokumentu.

- Nové assety musí působit jako součást stejného STARBITu. Samotný obecný
  popis „pohádková hra“ není dostatečná reference.
- Zachovej kresbu, proporce, materiály, světlo a čitelnost existujících assetů.
  Prostředí se může měnit podle příběhu; výtvarný jazyk zůstává společný.
- Pro tvorbu nových assetů používej Higgsfield. Potřebné rozstříhání atlasů,
  oddělení objektů a přípravu částí prováděj také v Higgsfieldu.
- Ke každé generaci přilož skutečné obrázkové reference: identitu postavy
  nebo nejbližšího objektu, kresbu odpovídající kategorie a cílové prostředí.
  V promptu výslovně popiš roli každé reference.
- U animací zachovej vzhled postavy napříč všemi snímky a zarovnej její
  chodidla nebo společný kotevní bod. Bit zůstává Bit, dron se jmenuje Zip.
  Starší názvy `fouk` v cestách nejsou pokynem k přejmenování souborů.
- Výsledek zkontroluj vedle původních assetů a v cílovém levelu při herním
  měřítku. Odlišnou kresbu oprav na novém assetu před jeho zapojením.
- Zapiš použité reference, model, prompt a rozvržení atlasu k příslušné sadě.

Novější konkrétní pokyn uživatele má před těmito pravidly přednost.
