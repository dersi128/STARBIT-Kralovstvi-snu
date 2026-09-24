shader_type canvas_item;

void fragment() {
	if (COLOR.a < 0.025) {
		COLOR.a = 0.0;
	}
}
