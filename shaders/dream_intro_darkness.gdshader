shader_type canvas_item;
render_mode unshaded;

// Keep the painted kingdom visible beneath a slowly curling violet shadow.
uniform float elapsed = 0.0;
uniform float darkness : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float soft_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec4 painted = texture(TEXTURE, UV);
	vec2 flow = UV * vec2(3.6, 2.8) + vec2(-elapsed * 0.028, elapsed * 0.018);
	float broad = soft_noise(flow);
	float wisps = soft_noise(flow * 2.1 + vec2(broad * 1.4, -broad));
	float curl = sin(UV.y * 8.0 + broad * 3.0 - elapsed * 0.11) * 0.095;
	float frontier = UV.x * 0.64 + (1.0 - UV.y) * 0.40 + curl + broad * 0.19;
	float veil = smoothstep(frontier - 0.23, frontier + 0.23, darkness * 1.70 - 0.30);
	veil *= smoothstep(0.0, 0.14, darkness);
	float luminance = dot(painted.rgb, vec3(0.299, 0.587, 0.114));
	vec3 moonlit = mix(painted.rgb, vec3(luminance), 0.40);
	moonlit *= vec3(0.28, 0.23, 0.48);
	vec3 violet_fog = vec3(0.115, 0.061, 0.20) * (0.30 + wisps * 0.70);
	vec3 shaded = moonlit + violet_fog;
	COLOR = vec4(mix(painted.rgb, shaded, veil * 0.95), painted.a);
}
