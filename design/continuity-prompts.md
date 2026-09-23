# Úpravy návaznosti a mraku

Použit vestavěný generátor obrázků; původní pozadí a mrak byly editačními předlohami. Distant castle byl referencí identity hradu. Výstupy jsou zapojené v assets/environments/village.png, assets/environments/guardian.png a assets/pieces/cloud.png. Mrak má skutečný alfa kanál, rozměr 2172 × 724.

## Vesnička a aréna — shodný prompt pro každou scénu

Use case: precise-object-edit. Image 1 is the edit target, Image 2 is ONLY reference for the castle identity. Correct geographic continuity of this STARBIT game background. Preserve the target's entire composition, foreground scenery, lighting, trees, village/ruins and warm painterly pastel style. Replace ONLY the distant castle and its mountain: show the ivory castle with blue roofs and gold star spire from reference 2, SMALL and far away, on a clearly FLOATING island high in the sky. There must be visible empty air/clouds BELOW the floating island, separating it from terrestrial forest and village below. No castle standing on a mountain connected to ground. Preserve 16:9 landscape composition, ideally 1672x941. No characters, text, UI, playable platforms. Keep scene inviting for children. The castle is a distant destination, not dominant.

## Vyčištění mraku

Use case: background-extraction. Edit this exact white-blue cartoon cloud platform sprite: preserve the same elongated cloud silhouette, softly rounded lobes, white and very pale blue shading and fine blue outline. Remove ALL stray fragments and strokes below the cloud (especially cut-off curved fragment at lower left). Only ONE complete cloud centered, with clean alpha transparency around it, no background, no checkerboard, no ground shadow, no text. Horizontal aspect ratio about 3:1. This is a ready-to-use Godot platform sprite. Leave a very small transparent margin around the cloud.
