shader_type canvas_item;
render_mode unshaded;

uniform sampler2D source_art : filter_linear, repeat_disable;
uniform vec3 matte_color = vec3(0.047,0.075,0.133);
uniform vec2 stream_bounds = vec2(483.0,639.0);
uniform vec2 spray_bounds = vec2(363.0,740.0);
uniform float head_y = 350.0;
uniform float target_bottom = 820.0;
uniform float effect_strength : hint_range(0.0,1.0) = 0.7;
uniform float clock = 0.0;
varying vec2 art_position;
varying vec4 item_color;

vec4 pixel(vec2 p) {
	if (p.x<0.0 || p.x>=1672.0 || p.y<0.0 || p.y>=941.0) {return vec4(0.0);}
	vec4 c=texture(source_art,p/vec2(1672.0,941.0));
	vec3 delta=abs(c.rgb-matte_color);
	float distance_to_matte=max(delta.r,max(delta.g,delta.b));
	float coverage=smoothstep(0.028,0.14,distance_to_matte);
	// The supplied foam has blue haze painted into the navy backdrop. Treat
	// this low, blue-only fringe as translucent spray rather than a dark outline.
	if (p.y>665.0 && p.x>spray_bounds.x && p.x<spray_bounds.y && c.b>c.r+0.035 && c.b>c.g+0.02) {
		coverage=min(coverage,clamp((c.b-matte_color.b)/(0.91-matte_color.b),0.0,1.0));
	}
	// Decontaminate only the semitransparent silhouette; opaque art is unchanged.
	c.rgb=clamp((c.rgb-matte_color*(1.0-coverage))/max(coverage,0.001),vec3(0.0),vec3(1.0));
	c.a*=coverage;
	return c;
}

float water(vec2 p,vec4 c) {
	float cyan=smoothstep(0.025,0.09,min(c.g-c.r,c.b-c.r));
	float white=smoothstep(0.66,0.85,min(c.r,min(c.g,c.b)))*step(c.r-0.035,c.b);
	float column=smoothstep(stream_bounds.x,stream_bounds.x+7.0,p.x)*(1.0-smoothstep(stream_bounds.y-7.0,stream_bounds.y,p.x));
	float splash=smoothstep(665.0,705.0,p.y)*step(spray_bounds.x,p.x)*step(p.x,spray_bounds.y);
	return max(cyan,white)*max(column,splash)*smoothstep(head_y-12.0,head_y+12.0,p.y)*step(0.001,c.a);
}

vec4 moving_water(vec2 p) {
	vec4 base=pixel(p);
	float mask=water(p,base);
	float foam=smoothstep(675.0,735.0,p.y);
	vec2 drift=vec2(sin(p.y*0.043-clock*3.0)*1.5,sin(p.y*0.034-clock*4.8)*5.5);
	drift=mix(drift,vec2(sin(clock*2.1+p.y*0.026)*1.8,cos(clock*2.7+p.x*0.023)*1.5),foam);
	vec4 shifted=pixel(p+drift*effect_strength);
	float safe_mask=mask*water(p+drift*effect_strength,shifted)*effect_strength;
	base.rgb=mix(base.rgb,shifted.rgb,safe_mask*0.8);
	float ribbon=pow(max(0.0,sin(p.y*0.045-clock*5.5+sin(p.x*0.08))),10.0);
	float glint=mix(ribbon*0.12,0.035*sin(clock*3.0+p.x*0.046),foam);
	base.rgb=clamp(base.rgb+vec3(0.65,0.88,1.0)*glint*mask*effect_strength,vec3(0.0),vec3(1.0));
	return base;
}

void vertex() {art_position=VERTEX;item_color=COLOR;}

void fragment() {
	vec2 p=art_position;
	vec4 result=moving_water(p);
	if (abs(target_bottom-820.0)>0.01 && p.y>head_y) {
		vec4 island=pixel(p);island.a*=1.0-water(p,island);
		float foam_scale=min(1.0,(target_bottom-head_y)*0.4/130.0);
		float target_foam=target_bottom-130.0*foam_scale;
		float source_y=p.y;
		if (p.y>=target_foam) {source_y=690.0+(p.y-target_foam)/foam_scale;}
		else {source_y=head_y+(p.y-head_y)*(690.0-head_y)/max(target_foam-head_y,1.0);}
		vec2 water_p=vec2(p.x,source_y);
		vec4 flowing=moving_water(water_p);flowing.a*=water(water_p,flowing);
		float alpha=flowing.a+island.a*(1.0-flowing.a);
		result=vec4((flowing.rgb*flowing.a+island.rgb*island.a*(1.0-flowing.a))/max(alpha,0.001),alpha);
	}
	COLOR=result*item_color;
}
