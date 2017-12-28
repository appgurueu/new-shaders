#version 330

uniform mat4 uniform_Transformation;
uniform mat4 uniform_Modelview;
uniform mat4 uniform_Projection;
uniform mat4 lightMatrix;
uniform float lightConstant;
uniform float lightLinear;
uniform float lightQuadratic;
uniform vec3 lightPos;

in vec4  attribute_Position;
in vec2 texcoords;

out vec2 texcoords_pass;
out float attenuation;
out vec3 shadow_position;

void main(void) 
{ 
  vec4 pos = uniform_Transformation * attribute_Position;
  vec4 camrel = uniform_Modelview * pos;
  texcoords_pass=texcoords;
  float dtl=length(pos.xyz-lightPos);
  attenuation=1.0f/(lightConstant+dtl*lightLinear+pow(dtl,2)*lightQuadratic);
  shadow_position=(lightMatrix*pos).xyz;
  gl_Position=uniform_Projection * camrel;
} 