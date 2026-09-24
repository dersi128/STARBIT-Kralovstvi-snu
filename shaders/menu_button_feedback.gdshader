shader_type canvas_item;
render_mode unshaded;

uniform vec2 button_size = vec2(410.0, 94.0);
uniform float hover_amount : hint_range(0.0, 1.0) = 0.0;
uniform float press_amount : hint_range(0.0, 1.0) = 0.0;
uniform float sweep = -1.0;

void fragment() {
	// This transparent overlay leaves the original illustration untouched at rest.
	vec2 half_size = button_size * 0.5 - vec2(4.0);
	float radius = half_size.y;
	vec2 q = abs(UV * button_size - button_size * 0.5) - half_size + vec2(radius);
	float distance_to_edge = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
	float mask = 1.0 - smoothstep(-1.5, 0.0, distance_to_edge);
	float rim = 1.0 - smoothstep(1.0, 4.0, abs(distance_to_edge + 3.0));
	float gleam = 1.0 - smoothstep(0.02, 0.16, abs(UV.x + UV.y * 0.16 - sweep));
	float light = clamp(hover_amount * (0.08 + rim * 0.24) + gleam * 0.30, 0.0, 0.48);
	float dark = press_amount * 0.24;
	float alpha = light + dark * (1.0 - light);
	vec3 tint = (vec3(1.0, 0.99, 0.88) * light + vec3(0.03, 0.07, 0.19) * dark * (1.0 - light)) / max(alpha, 0.001);
	COLOR = vec4(tint, alpha * mask);
}
