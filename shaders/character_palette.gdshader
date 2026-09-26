shader_type canvas_item;
// Recolor only mint armor. Whites, dark outlines, blue eyes/scarf and gold star stay intact.
uniform float target_hue : hint_range(0.0, 1.0) = 0.58;
uniform float saturation_scale : hint_range(0.0, 2.0) = 1.0;
varying vec4 item_tint;

vec3 rgb_to_hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w-q.y)/(6.0*d+0.000001)), d/(q.x+0.000001), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0/3.0, 1.0/3.0))*6.0-3.0);
	return c.z * mix(vec3(1.0), clamp(p-1.0, 0.0, 1.0), c.y);
}

void vertex() {
	item_tint = COLOR;
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec3 hsv = rgb_to_hsv(source.rgb);
	float mask = smoothstep(0.25, 0.34, hsv.x) * (1.0-smoothstep(0.46, 0.51, hsv.x));
	mask *= smoothstep(0.16, 0.40, hsv.y) * smoothstep(0.08, 0.20, hsv.z);
	vec3 recolored = hsv_to_rgb(vec3(target_hue, clamp(hsv.y*saturation_scale, 0.0, 1.0), hsv.z));
	COLOR = vec4(mix(source.rgb, recolored, mask), source.a) * item_tint;
}
