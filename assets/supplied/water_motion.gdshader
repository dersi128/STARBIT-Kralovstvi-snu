shader_type canvas_item;
uniform float elapsed=0.0;
void fragment() {
 vec2 uv=UV;
 uv.x+=sin(uv.y*38.0-elapsed*2.8)*0.0025*sin(uv.x*3.14159);
 vec4 water=texture(TEXTURE,uv);
 water.rgb*=0.98+0.02*sin(uv.y*65.0-elapsed*7.0);
 COLOR=water;
}
