shader_type canvas_item;
render_mode unshaded;

uniform sampler2D source_sheet : filter_linear, repeat_disable;
uniform vec2 sheet_size = vec2(1448.0, 1086.0);
uniform vec2 frame_origin = vec2(0.0);
uniform vec4 content_rect = vec4(0.0, 0.0, 384.0, 512.0);
uniform vec2 stream_bounds = vec2(130.0, 280.0);
uniform vec2 stream_core = vec2(149.0, 266.0);
uniform float splash_start = 350.0;
uniform float original_bottom = 480.0;
uniform float target_bottom = 480.0;
uniform float edge_cleanup : hint_range(0.0, 1.0) = 1.0;
varying vec2 art_position;
varying vec4 item_color;

float brightness(vec3 c) {
	return max(c.r, max(c.g, c.b));
}

vec4 raw_pixel(vec2 p) {
	// Atlas margins can fall on half pixels. Tolerance avoids flickering at a
	// boundary when a taller quad changes floating-point interpolation slightly.
	if (p.x < content_rect.x - 0.001 || p.y < content_rect.y - 0.001 || p.x > content_rect.x + content_rect.z + 0.001 || p.y > content_rect.y + content_rect.w + 0.001) {
		return vec4(0.0);
	}
	return texture(source_sheet, (frame_origin + p) / sheet_size);
}

vec4 clean_pixel(vec2 p) {
	vec4 source = raw_pixel(p);
	float b = brightness(source.rgb);
	float coverage = smoothstep(0.018, 0.085, b);
	if (source.a > 0.0 && coverage > 0.0 && edge_cleanup > 0.0) {
		// Estimate black-matte coverage at silhouettes; retain interior shading.
		float darkest = b;
		float lightest = b;
		for (int i = 0; i < 8; i++) {
			float angle = float(i) * 0.78539816339;
			vec2 direction = vec2(cos(angle), sin(angle));
			float near_b = brightness(raw_pixel(p + direction * 2.0).rgb);
			float far_b = brightness(raw_pixel(p + direction * 4.0).rgb);
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

float water_mask(vec2 p, vec4 colour) {
	if (p.y <= 94.0) { return 0.0; }
	if (p.y >= 318.0) { return 1.0; }
	float b = brightness(colour.rgb);
	float minimum = min(colour.r, min(colour.g, colour.b));
	bool cyan = colour.g > colour.r + 0.025 && colour.b > colour.r + 0.065 && colour.b > colour.g + 0.015;
	bool white = minimum > 0.68 && b - minimum < 0.24 && colour.g >= colour.r - 0.015 && colour.b >= colour.g - 0.015;
	bool in_stream = p.x >= stream_bounds.x && p.x <= stream_bounds.y;
	bool low_drop = p.y > 286.0 && cyan && p.x > stream_core.x - 35.0 && p.x < stream_core.y + 35.0;
	return ((in_stream && (cyan || white)) || low_drop) ? 1.0 : 0.0;
}

void vertex() {
	art_position = VERTEX;
	item_color = COLOR;
}

void fragment() {
	vec2 p = art_position;
	vec4 result = clean_pixel(p);
	if (abs(target_bottom - original_bottom) > 0.01 && p.y > 94.0) {
		vec4 island = result;
		island.a *= 1.0 - water_mask(p, island);
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
		vec2 water_position = vec2(p.x, source_y);
		vec4 water = clean_pixel(water_position);
		water.a *= water_mask(water_position, water);
		// Keep the falling ribbon within its calibrated banks while it passes
		// the island: blue-tinted stones must never become stretched water.
		float spread = smoothstep(270.0, 318.0, source_y) * 24.0;
		float ribbon = smoothstep(stream_core.x - spread, stream_core.x + 1.0 - spread, p.x) * (1.0 - smoothstep(stream_core.y - 1.0 + spread, stream_core.y + spread, p.x));
		water.a *= mix(ribbon, 1.0, smoothstep(314.0, 318.0, source_y));
		float alpha = water.a + island.a * (1.0 - water.a);
		vec3 rgb = (water.rgb * water.a + island.rgb * island.a * (1.0 - water.a)) / max(alpha, 0.001);
		result = vec4(rgb, alpha);
	}
	COLOR = result * item_color;
}
