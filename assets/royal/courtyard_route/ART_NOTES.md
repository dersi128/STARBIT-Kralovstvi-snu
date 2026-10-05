# Courtyard route backgrounds

Created with the built-in image generation tool for level 8, using `assets/environments/near_castle.png` as the visual style reference. This is one opaque background atlas; it is not a gameplay platform or a collision sprite. The original generated PNG is preserved without pixel edits.

Requested canvas: 2048 × 1152. Actual output: **1672 × 941 RGB PNG** (opaque), 2,568,050 bytes. Exact Godot AtlasTexture crop rectangles:

| Route environment | Position in atlas | Rect2(x, y, width, height) |
| --- | --- | --- |
| Sunny arrival courtyard | Top left | `Rect2(0, 0, 836, 470)` |
| Sheltered exterior aqueduct | Top right | `Rect2(836, 0, 836, 470)` |
| Quiet moat | Bottom left | `Rect2(0, 470, 836, 471)` |
| Garden gatehouse | Bottom right | `Rect2(836, 470, 836, 471)` |

Use AtlasTexture filter clipping so neighboring regions do not bleed across crop edges. The one-pixel bottom-row height difference follows the actual generated image dimensions.

The four locations are ordered along the main route: sunny arrival courtyard, sheltered exterior aqueduct gallery, quiet moat, gatehouse overlooking dream gardens. Draw one region at a time, never the whole atlas. Background transitions should be slow and screen-wide. Keep foreground gameplay geometry visually dominant and avoid placing additional busy decorative props over these paintings.

## Generation prompt

```text
Use case: illustration-story.
Asset type: a production background atlas for STARBIT, a whimsical children's side-scrolling platform game.
Use the supplied image only as a STYLE AND WORLD reference: soft hand-painted fairytale illustration, ivory stone, blue cobalt roofs, gold trim, leafy mint greenery, floating dream-kingdom islands, pastel luminous atmosphere. Create new compositions, not the same castle arrangement.

Deliver ONE OPAQUE full-bleed landscape PNG, ideally 2048 x 1152 pixels. Divide the canvas EXACTLY into four equally sized 16:9 rectangular paintings in a 2x2 layout: each quadrant1024x576. Each quadrant must completely fill its rectangle, with NO gutters, separators, outlines, rounded corners, text, labels, or decorative borders. Quadrants touch exactly at the center horizontal/vertical axes. Each painting is an independent scenery background, NOT a sprite sheet of objects. No gradients fading into a transparent background.

TOP LEFT: sunny exterior royal courtyard seen from a calm distance. Ivory arcades along the lower corners, modest cobalt roof watchtowers far away at the outer sides, clear pastel blue sky and warm clouds filling the middle and upper area. Courtyard architecture feels grounded within the same dream castle, not one huge central castle.
TOP RIGHT: sheltered old aqueduct and exterior arched stone gallery with trailing ivy, misty distant waterfalls visible through broad arches, pale blue sky openings. Large calm architectural masses at the outer edges, broad airy open center. It remains an OUTDOOR gallery, not an indoor palace.
BOTTOM LEFT: quiet castle moat and garden-side service court, gentle bluegreen water low in the frame, one distant pergola to the side, broad pale stone architectural masses, soft early evening peach-blue light. Calm spacious middle, slightly cooler lush green mood.
BOTTOM RIGHT: outside the gatehouse overlooking dreamy gardens: pale outer gatehouse sides framing an open distant view, sunlit luminous foliage and soft blue rooftops far away. Warm green-gold glow, clear open center, no closed door filling the image.

Across all four paintings: coherent proportions/style/color family but clearly different locations. Distant, soft low contrast supporting backgrounds. The central 80 percent must remain visually calm with broad tonal areas so small foreground characters and gameplay geometry read clearly. Charming polished painterly depth, subtle leafy forms and stone variation, restrained details. No playable foreground platforms, no foreground ledges running across the screen, no characters, no creatures, no collectibles, no fountains or gadgets in front, no machinery, no elevators, no HUD or UI, no writing or logos, no busy repeated grid patterns, no black outlines, no photorealism, no close-up huge castle. Match the supplied reference's storybook painted world.
```
