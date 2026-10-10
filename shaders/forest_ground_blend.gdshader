shader_type canvas_item;

// Only the short cut edge of a ground lip fades into its matching earth bank.
// Coordinates are local pixels, independent of atlas coordinates or bank width.
uniform float blend_start = 16.0;
uniform float blend_end = 34.0;
varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	if (COLOR.a < 0.025) {
		COLOR.a = 0.0;
	}
	COLOR.a *= 1.0 - smoothstep(blend_start, blend_end, local_y);
}
