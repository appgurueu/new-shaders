#version 330

out vec4 mgl_FragColor;

uniform sampler2D tex;
uniform sampler2D shadowmap;
uniform vec3 lightDiffuse;
uniform float ambient;

in vec2 texcoords_pass;
in float attenuation;
in vec3 normals_pass;
in vec3 shadow_position;

void main (void)
{ 
  vec4 texture_color =  texture(tex,texcoords_pass);
  if (texture_color.w == 0) {
      discard;
  }
  float visibility = 1.0;
  if ( texture( shadowmap, shadow_position.xy ).x  <  shadow_position.z){
    visibility = 0.5;
  }
  mgl_FragColor=vec4(texture_color.x*(ambient+visibility*attenuation),texture_color.y*(ambient+visibility*attenuation),texture_color.z*(ambient+visibility*attenuation),texture_color.w);
}