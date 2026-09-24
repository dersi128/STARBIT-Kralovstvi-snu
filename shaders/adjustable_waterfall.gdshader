shader_type canvas_item;
render_mode unshaded;

uniform sampler2D source_sheet : filter_linear, repeat_disable;
uniform vec2 sheet_size = vec2(1448.0, 1086.0);
uniform vec2 frame_origin = vec2(0.0);
uniform vec4 content_rect = vec4(0.0, 0.0, 384.0, 512.0);
uniform vec2 reference_frame_origin = vec2(0.0);
uniform vec4 reference_content_rect = vec4(0.0, 0.0, 384.0, 512.0);
uniform vec2 stream_bounds = vec2(130.0, 280.0);
uniform vec2 stream_core = vec2(149.0, 266.0);
uniform vec2 reference_stream_core = vec2(148.0, 267.0);
uniform float splash_start = 350.0;
uniform float original_bottom = 480.0;
uniform float target_bottom = 480.0;
uniform float edge_cleanup : hint_range(0.0, 1.0) = 1.0;
varying vec2 art_position;
varying vec4 item_color;

float brightness(vec3 c) {
	return max(c.r, max(c.g, c.b));
}

vec4 raw_pixel(vec2 p, bool reference) {
	vec4 bounds = reference ? reference_content_rect : content_rect;
	vec2 origin = reference ? reference_frame_origin : frame_origin;
	// Atlas margins can fall on half pixels. Tolerance avoids flickering at a
	// boundary when a taller quad changes floating-point interpolation slightly.
	if (p.x < bounds.x - 0.001 || p.y < bounds.y - 0.001 || p.x > bounds.x + bounds.z + 0.001 || p.y > bounds.y + bounds.w + 0.001) {
		return vec4(0.0);
	}
	return texture(source_sheet, (origin + p) / sheet_size);
}

vec4 clean_pixel(vec2 p, bool reference) {
	vec4 source = raw_pixel(p, reference);
	float b = brightness(source.rgb);
	float coverage = smoothstep(0.018, 0.085, b);
	if (source.a > 0.0 && coverage > 0.0 && edge_cleanup > 0.0) {
		// Estimate black-matte coverage at silhouettes; retain interior shading.
		float darkest = b;
		float lightest = b;
		for (int i = 0; i < 8; i++) {
			float angle = float(i) * 0.78539816339;
			vec2 direction = vec2(cos(angle), sin(angle));
			float near_b = brightness(raw_pixel(p + direction * 2.0, reference).rgb);
			float far_b = brightness(raw_pixel(p + direction * 4.0, reference).rgb);
			darkest = min(darkest, min(near_b, far_b));
			lightest = max(lightest, max(near_b, far_b));
		}
		float boundary = 1.0 - smoothstep(0.018, 0.055, darkest);
		float edge_alpha = min(coverage, b / max(lightest, 0.001));
		coverage = mix(coverage, edge_alpha, boundary * edge_cleanup);
	}
	source.rgb = clamp(source.rgb / max(coverage, 0.001), vec3(0.0), vec3(1.0));
	return vec4(source.rgb, source.a * coverage);
}

float water_mask(vec2 p, vec4 colour, vec2 core) {
	if (p.y <= 94.0) { return 0.0; }
	if (p.y >= 318.0) { return 1.0; }
	float b = brightness(colour.rgb);
	float minimum = min(colour.r, min(colour.g, colour.b));
	bool cyan = colour.g > colour.r + 0.025 && colour.b > colour.r + 0.065 && colour.b > colour.g + 0.015;
	bool white = minimum > 0.68 && b - minimum < 0.24 && colour.g >= colour.r - 0.015 && colour.b >= colour.g - 0.015;
	bool in_stream = p.x >= stream_bounds.x && p.x <= stream_bounds.y;
	bool low_drop = p.y > 286.0 && cyan && p.x > core.x - 35.0 && p.x < core.y + 35.0;
	return ((in_stream && (cyan || white)) || low_drop) ? 1.0 : 0.0;
}

float ribbon_mask(vec2 p, vec2 core) {
	// Keep animated pixels away from blue-tinted stones along the banks.
	float spread = smoothstep(270.0, 318.0, p.y) * 24.0;
	float ribbon = smoothstep(core.x - spread, core.x + 1.0 - spread, p.x) * (1.0 - smoothstep(core.y - 1.0 + spread, core.y + spread, p.x));
	return mix(ribbon, 1.0, smoothstep(314.0, 318.0, p.y));
}

void vertex() {
	art_position = VERTEX;
	item_color = COLOR;
}

void fragment() {
	vec2 p = art_position;
	vec4 result = clean_pixel(p, true);
	if (p.y > 94.0) {
		vec4 island = result;
		island.a *= 1.0 - water_mask(p, island, reference_stream_core) * ribbon_mask(p, reference_stream_core);
		float drop = max(target_bottom - 94.0, 0.001);
		float foam_height = max(original_bottom - splash_start, 1.0);
		float foam_scale = min(1.0, drop * 0.45 / foam_height);
		float target_splash = target_bottom - foam_height * foam_scale;
		float head = min(16.0, drop * 0.2);
		float source_y = p.y;
		if (p.y > target_splash) {
			source_y = splash_start + (p.y - target_splash) / foam_scale;
		} else if (p.y > 94.0 + head) {
			source_y = 94.0 + head + (p.y - 94.0 - head) * (splash_start - 94.0 - head) / max(target_splash - 94.0 - head, 0.001);
		}
		// Atlas frames have slightly different widths. Align the flow to the
		// fixed opening while allowing free droplets and foam below the island.
		float across = (p.x - reference_stream_core.x) / max(reference_stream_core.y - reference_stream_core.x, 1.0);
		float aligned_x = mix(stream_core.x, stream_core.y, across);
		float source_x = mix(aligned_x, p.x, smoothstep(270.0, 318.0, source_y));
		vec2 water_position = vec2(source_x, source_y);
		vec4 water = clean_pixel(water_position, false);
		water.a *= water_mask(water_position, water, stream_core) * ribbon_mask(water_position, stream_core);
		// The fixed island is always in front: even short falls cannot animate
		// the foliage or paint moving stones over the reference silhouette.
		float alpha = island.a + water.a * (1.0 - island.a);
		vec3 rgb = (island.rgb * island.a + water.rgb * water.a * (1.0 - island.a)) / max(alpha, 0.001);
		result = vec4(rgb, alpha);
	}
	COLOR = result * item_color;
}
