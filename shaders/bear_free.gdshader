shader_type canvas_item;
uniform float freed : hint_range(0.0,1.0) = 0.0;
uniform float hit_flash = 0.0;
void fragment(){
 vec4 c=texture(TEXTURE,UV);
 float purple=smoothstep(0.015,0.12,min(c.r,c.b)-c.g);
 float light=max(c.r,max(c.g,c.b));
 vec3 healed=vec3(light*0.64,light*0.96,light*0.30);
 c.rgb=mix(c.rgb,healed,purple*freed);
 c.rgb=mix(c.rgb,vec3(1.0,0.9,0.85),hit_flash);
 COLOR=c;
}
