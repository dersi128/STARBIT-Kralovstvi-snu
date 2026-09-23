shader_type canvas_item;
render_mode unshaded;

uniform sampler2D rain_sheet : source_color, filter_linear, repeat_disable;
uniform vec2 sheet_size = vec2(1448.0, 1086.0);
uniform vec2 rain_size = vec2(260.0, 270.0);
// Supplied by the cloud's physics clock; scene pause freezes every drop.
uniform float elapsed = 0.0;
uniform float opacity = 0.0;
uniform vec4 splash_a;
uniform vec4 splash_b;
uniform float splash_mix = 0.0;
varying vec4 item_color;
varying vec2 art_uv;

void vertex() {
	item_color = COLOR;
	art_uv = (VERTEX + vec2(rain_size.x * 0.5, 6.0)) / rain_size;
}

float hash(float seed) {
	return fract(sin(seed * 127.1 + 311.7) * 43758.5453);
}

vec4 premultiply(vec4 color) {
	return vec4(color.rgb * color.a, color.a);
}

vec4 over(vec4 top, vec4 bottom) {
	return top + bottom * (1.0 - top.a);
}

vec4 drop_sample(vec2 uv) {
	// Only one isolated teardrop is sampled, never the rectangular rain mist.
	vec4 color = texture(rain_sheet, (vec2(248.0, 295.0) + uv * vec2(42.0, 100.0)) / sheet_size);
	float t = clamp(uv.y, 0.0, 1.0);
	float radius = t < 0.72
		? 0.34 * pow(t / 0.72, 1.15)
		: 0.34 * sqrt(max(0.0, 1.0 - pow((t - 0.72) / 0.28, 2.0)));
	float silhouette = 1.0 - smoothstep(radius - 0.035, radius + 0.01, abs(uv.x - 0.50));
	color.a = smoothstep(0.56, 0.93, color.a) * silhouette;
	return premultiply(color);
}

vec4 splash_sample(vec4 rect, vec2 uv) {
	vec4 color = texture(rain_sheet, (rect.xy + uv * rect.zw) / sheet_size);
	// Remove the low-alpha blue panel while keeping opaque spray and foam.
	color.a = smoothstep(0.78, 0.98, color.a);
	color.a *= smoothstep(0.0, 0.25, uv.y) * (1.0 - smoothstep(0.95, 1.0, uv.y));
	color.a *= smoothstep(0.0, 0.04, uv.x) * (1.0 - smoothstep(0.96, 1.0, uv.x));
	return premultiply(color);
}

void fragment() {
	vec2 point = art_uv * rain_size;
	vec4 result = vec4(0.0);
	float size_factor = clamp(rain_size.x / 260.0, 0.7, 1.6);
	for (int i = 0; i < 22; i++) {
		float seed = float(i) + 1.0;
		float h = (23.0 + hash(seed + 8.0) * 31.0) * size_factor;
		vec2 drop_size = vec2(h * 0.42, h);
		float speed = (230.0 + hash(seed + 24.0) * 140.0) * sqrt(size_factor);
		float travel = rain_size.y + h * 2.0;
		float y = mod(elapsed * speed + hash(seed + 40.0) * travel, travel) - h;
		float x = (0.06 + 0.88 * hash(seed)) * rain_size.x;
		x += sin(elapsed * 2.0 + seed) * 1.5 * size_factor;
		vec2 uv = (point - vec2(x - drop_size.x * 0.5, y)) / drop_size;
		if (uv.x > 0.0 && uv.x < 1.0 && uv.y > 0.0 && uv.y < 1.0) {
			result = over(drop_sample(uv), result);
		}
	}
	float splash_height = min(rain_size.y * 0.65, 74.0 * size_factor);
	vec2 splash_uv = vec2(art_uv.x, (point.y - rain_size.y + splash_height) / splash_height);
	if (splash_uv.y > 0.0 && splash_uv.y < 1.0) {
		vec4 splash = mix(splash_sample(splash_a, splash_uv), splash_sample(splash_b, splash_uv), splash_mix);
		result = over(splash, result);
	}
	// Between individual drops the output is exactly transparent.
	COLOR = vec4(result.rgb / max(result.a, 0.0001), result.a * opacity) * item_color;
}
