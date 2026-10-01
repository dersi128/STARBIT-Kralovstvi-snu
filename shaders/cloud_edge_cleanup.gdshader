shader_type canvas_item;

// Trim the thin blue/white matte left in the supplied cutouts. Work in source
// pixels so the cleanup scales with a cloud and does not change its collider.
uniform float edge_pixels = 6.0;
varying vec4 cloud_tint;

void vertex() {
	cloud_tint = COLOR;
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec2 radius = TEXTURE_PIXEL_SIZE * edge_pixels;
	float inner_alpha = source.a;
	vec3 inner_color = source.rgb * source.a;
	float color_weight = source.a;
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.78539816339;
		vec4 nearby = texture(TEXTURE, UV + vec2(cos(angle), sin(angle)) * radius);
		inner_alpha = min(inner_alpha, nearby.a);
		float weight = smoothstep(0.8, 0.98, nearby.a);
		inner_color += nearby.rgb * weight;
		color_weight += weight;
	}
	// Average only the inside colors at the boundary, keeping the painted
	// highlights untouched through the solid interior of the cloud.
	vec3 clean_color = mix(source.rgb, inner_color / max(color_weight, 0.001),
		(1.0 - inner_alpha) * 0.85);
	COLOR = vec4(clean_color, smoothstep(0.12, 0.92, inner_alpha)) * cloud_tint;
}
