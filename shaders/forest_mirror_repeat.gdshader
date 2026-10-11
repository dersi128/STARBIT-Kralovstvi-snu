shader_type canvas_item;

// Turn at the same edge texel instead of jumping between unrelated atlas cuts.
// World-aligned UVs keep the pattern stable when a bank is resized or split.
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec2 folded = 1.0 - abs(mod(UV, 2.0) - 1.0);
	vec2 half_texel = TEXTURE_PIXEL_SIZE * 0.5;
	vec2 sample_uv = mix(half_texel, vec2(1.0) - half_texel, folded);
	COLOR = vertex_tint * texture(TEXTURE, sample_uv);
}
