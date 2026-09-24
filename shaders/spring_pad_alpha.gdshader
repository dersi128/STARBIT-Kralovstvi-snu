shader_type canvas_item;

void fragment() {
	// Remove barely visible alpha residue in the cutout's otherwise empty space.
	if (COLOR.a < 0.025) {
		COLOR.a = 0.0;
	}
}
