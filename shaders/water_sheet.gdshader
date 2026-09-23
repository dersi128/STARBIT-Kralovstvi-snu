shader_type canvas_item;
render_mode unshaded;

uniform bool remove_black = false;
uniform bool blend_bottom = false;
uniform float frame_height = 218.0;
varying float local_y;
varying vec4 item_color;

void vertex() {
	local_y = VERTEX.y;
	item_color = COLOR;
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float coverage = 1.0;
	if (remove_black) {
		float brightness = max(source.r, max(source.g, source.b));
		coverage = smoothstep(0.018, 0.085, brightness);
		// Reconstruct the soft edge from the supplied black-backed art.
		source.rgb = clamp(source.rgb / max(coverage, 0.001), 0.0, 1.0);
	}
	if (blend_bottom) {
		coverage *= 1.0 - smoothstep(frame_height * 0.82, frame_height, local_y);
	}
	COLOR = vec4(source.rgb, source.a * coverage) * item_color;
}
