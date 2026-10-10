shader_type canvas_item;
render_mode unshaded;
void fragment(){
 vec4 c=texture(TEXTURE, UV);
 float k=smoothstep(0.24,0.65,min(c.r,c.b)-c.g);
 c.a*=1.0-k;
 if(c.a<0.35){discard;}
 COLOR=c;
}
