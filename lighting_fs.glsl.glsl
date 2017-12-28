#version 330

layout(location=0) out vec4 litColor;

uniform sampler2D direction_to_light;
uniform sampler2D rendered_scene;
uniform sampler2D normalmap;
uniform sampler2D depthmap;

in vec2 texcoords_pass;

void main (void)
{ 
  //Calculating the direction to viewer, necessary for specular lighting, depthmap used for this
  float depth=1.0f-(texture(depthmap,texcoords_pass).x);
  vec3 dir_to_viewer = vec3((texcoords_pass-0.5f)*depth,(texcoords_pass-0.5f)*depth,depth);
  vec4 color=texture(rendered_scene, texcoords_pass);
  vec3 normal=texture(normalmap, texcoords_pass);
  vec3 to_light=texture(direction_to_light, texcoords_pass);
  normal.x=(normal.x-0.5f)*2.0f;
  normal.y=(normal.y-0.5f)*2.0f;
  normal.z=(normal.z-0.5f)*2.0f;
  float diffuse=dot(normal,to_light);
  litColor=vec4(color.x * diffuse, color.y * diffuse, color.z * diffuse, color.w);
}
