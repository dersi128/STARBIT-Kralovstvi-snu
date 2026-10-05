# STARBIT courtyard workshop atlas

Created with the built-in `image_gen` tool, one generation. The source PNG is copied unchanged; no raster resizing, alpha processing, or retouching was performed.

Reference style: `assets/royal/expansion/level08_atlas.png` and `assets/royal/living/royal_life_atlas.png` (visually inspected). Glossy, rounded hand-painted 2D sprites, ivory and mint stone, golden trim, cobalt roofs, honey wood, small ivy.

The 1536 × 1024 RGBA atlas contains six separated sprites. 72.69% of pixels are fully transparent. Arch openings are transparent. Use bounded AtlasTexture regions below to exclude stray near-transparent pixels away from the silhouettes. A few alpha <= 5 fringe pixels may remain; the main artwork remains intact.

| Sprite | Godot region |
| --- | --- |
| LiftDeck | Rect2(22, 309, 527, 116) |
| WinchHeader | Rect2(580, 202, 430, 190) |
| Arcade | Rect2(1042, 24, 462, 422) |
| Balcony | Rect2(24, 721, 524, 159) |
| FlowerPlanter | Rect2(583, 707, 417, 219) |
| GardenGate | Rect2(1055, 475, 444, 490) |

Gameplay alignment: LiftDeck straight wooden walking edge is approximately source y=326; the small end caps rise to y=313. Balcony stone walking edge is approximately source y=776; greenery is decorative and should not define collision height. Align platform collision to those edges, not to the top of each crop. The winch header is stationary decoration; ropes and turning pulleys can be animated by the engine.

Prompt:

> Use case: stylized-concept. Generate ONE production-ready transparent sprite atlas for the existing STARBIT 2D children's fantasy platformer, matching the two reference atlases visible above. This is a new coordinated atlas, not a scene or background. Exactly SIX isolated sprites arranged as a regular 3 columns by 2 rows grid on a 1536 x 1024 landscape transparent canvas, one object per cell, at least 30 pixels clear gutters and outer margins. True alpha transparency, INCLUDING inside arches, no black or colored backdrop, no checkerboard, no glow fog behind the objects. Matching style: glossy rounded hand-painted family-friendly 2D game sprites, soft ivory and mint stone, warm golden trim, cobalt-blue roof tile, honey-colored wood, bright small ivy leaves; clean confident dark colored outlines, soft dimensional painted shading. Not pixel art, not realistic, not flat vector. Front-on side-scroller view, only a little top surface visible. TOP LEFT: horizontal rectangular cargo-elevator deck, slim wooden plank floor with a straight LEVEL walkable top edge, mint metal end caps and gold edge trim, no ropes or posts, no tall protrusions. TOP MIDDLE: compact horizontal wooden winch header crossbeam with exactly two large golden circular pulleys attached beneath its ends, mint brackets; no long ropes or posts, this will be mounted above an elevator. TOP RIGHT: wide open stone arcade arch, two slim ivory columns with small ivy, golden trim, broad curved arch across top, generous completely transparent empty space underneath, no floor across the opening. BOTTOM LEFT: thin wide ivory stone balcony platform with a straight level walkable top edge, tiny grass tufts at far ends, gold trim, two small curved brackets underneath, no back wall, no railings or posts. BOTTOM MIDDLE: low oval ivory-and-gold planter filled with ivy and three round little luminous BLUE FLOWERS, compact ground decoration, no independent glow outside the silhouette. BOTTOM RIGHT: ornate OPEN garden gate FRAME, two ivory supports, rounded gold-trimmed arch and little cobalt tiled cap roof, single small golden star set within upper frame; center opening completely transparent, no gate leaf, no glowing portal, no floor spanning the opening. Keep entire silhouettes uncut and clearly separated in their cells. Every sprite is a distinct usable cutout. NO labels, letters, numbers, captions, watermark, UI, characters, extra objects or additional sprites.
