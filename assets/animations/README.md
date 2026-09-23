# Animace v6
Nové rastrové snímky vytvořené generátorem obrázků podle dodaných referencí.
PNG mají alfa kanál; SpriteFrames .tres ukládají výřezy a zarovnání jednotlivých póz.
Nepřátelé a boss: 4 × 4 snímky (idle / chůze / útok / zásah a porážka).
Krteček: 4 × 2 snímky (idle a mrkání / vyprávění).
Směr doprava je výchozí; AnimatedSprite2D.flip_h zajišťuje otočení.
Rychlost, rozsah hlídkování a kolize se nastavují v kořenovém uzlu scény.
Animace jsou posloupnost samostatných kreslených póz, nikoliv kosterní rig.
Mezi snímky se mohou mírně lišit drobné detaily kresby.

## Zadání pro reprodukci
Společné zadání: konzistentní postava podle reference STARBIT, dětská 2,5D plošinovka,
celá postava, průhledné pozadí, bez podlahy, textu, UI a jiných objektů.
Rovnoměrná mřížka, oddělené pózy s dostatečným okrajem.
Kostík: kamenný malý nepřítel s mechem a květinou, 16 póz, idle/chůze/útok/zásah/porážka.
Bublík: malý obláčkový nepřítel, 16 póz se stejným rozvržením.
Boss: velký medvěd podle reference, 16 póz, příprava útoku, výpad, odpočinek a porážka.
Stínko: tmavě fialový stín bez nohou, zářící žluté oči, měkká silueta, 16 póz.
Krteček: průvodce s brýlemi a lucernou podle reference, 8 póz,
dýchání, mrknutí, otevřená ústa při vyprávění a gesto tlapkou.

## Portal and shackles sheet v7
Built-in image generator. Prompt: Production game VFX sprite sheet for STARBIT cozy
2.5D children's fantasy platformer, transparent background with actual alpha,
no text no labels no grid lines. Exactly 4 columns x4 rows of equal cells.
First three rows: 12 successive frames of luminous turquoise/violet vertical oval
magical portal interior, no stone gate or scenery, clockwise spiral with gold
sparkles; opening first row, rotating stable oval second/third row.
Last row: dark purple shadow bracelet with short chain; intact, cracking, falling
broken pieces, dispersing purple wisps. No characters or background.
Output: portal_shackles.png; AtlasTexture frames in portal_shackles.tres.

## Bit push v8
Built-in image generation, reference assets/pieces/run1.png. Prompt: exact cream/mint robot with cyan CRT eyes, blue scarf and chest star; four right-facing full-body pushing walk poses, arms extended with palms against imaginary crate, alternating planted feet, consistent identity, transparent background, 2x2 grid, no crate, text or floor.
Output bit_push.png. Four trimmed AtlasTexture resources push1–push4 keep the generated alpha.
