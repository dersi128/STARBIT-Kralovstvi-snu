shader_type canvas_item;
render_mode unshaded;

// All poses share the same body bounds. Blend premultiplied samples so the
// middle of a transition remains solid, including at the silhouette.
uniform sampler2D pose_a : source_color, filter_linear, repeat_disable;
uniform sampler2D pose_b : source_color, filter_linear, repeat_disable;
uniform sampler2D pose_c : source_color, filter_linear, repeat_disable;
uniform vec4 rect_a;
uniform vec4 rect_b;
uniform vec4 rect_c;
uniform vec2 cloud_size = vec2(300.0, 244.0);
uniform float edge_a[64];
uniform float edge_b[64];
uniform float edge_c[64];
uniform float frame_mix = 0.0;
uniform float phase_mix = 0.0;
varying vec4 item_color;
varying vec2 art_uv;

void vertex() {
	item_color = COLOR;
	art_uv = (VERTEX + vec2(cloud_size.x * 0.5, cloud_size.y)) / cloud_size;
}

vec4 clean_pose(vec4 sample_color, float edge[64]) {
	sample_color.a = smoothstep(0.12, 0.70, sample_color.a);
	float column = clamp(art_uv.x * 63.0, 0.0, 63.0);
	int left = int(floor(column));
	float bottom = mix(edge[left], edge[min(left + 1, 63)], fract(column));
	sample_color.a *= 1.0 - smoothstep(bottom - 0.003, bottom + 0.003, art_uv.y);
	sample_color.rgb *= sample_color.a;
	return sample_color;
}

void fragment() {
	vec4 a = clean_pose(texture(pose_a, rect_a.xy + art_uv * rect_a.zw), edge_a);
	vec4 b = clean_pose(texture(pose_b, rect_b.xy + art_uv * rect_b.zw), edge_b);
	vec4 c = clean_pose(texture(pose_c, rect_c.xy + art_uv * rect_c.zw), edge_c);
	vec4 result = mix(mix(a, b, frame_mix), c, phase_mix);
	COLOR = vec4(result.rgb / max(result.a, 0.0001), result.a) * item_color;
}
