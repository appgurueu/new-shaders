#version 330

uniform mat4 uniform_Transformation;
uniform mat4 uniform_Modelview;
uniform mat4 uniform_Projection;
uniform mat4 lightMatrix;
uniform float lightConstant;
uniform float lightLinear;
uniform float lightQuadratic;
uniform vec3 lightPos;
uniform vec3 eyePos;
uniform float time;
uniform float fogConstant;
uniform float fogLinear;
uniform float fogQuadratic;

in vec3 attribute_Position;
in vec2 texcoords;
in vec3 normal;
in vec3 transform;

out vec3 world_pass;
out vec2 texcoords_pass;
out float attenuation_pass;
out vec3 normals_pass;
out vec3 shadow_position_pass;
out vec3 toLight_pass;
out vec3 toEye_pass;
out float fog_pass;

void main(void) 
{ 
  vec4 pos = uniform_Transformation * vec4(attribute_Position+transform*time,1.0f);
  world_pass=pos.xyz;
  vec4 camrel = uniform_Modelview * pos;
  texcoords_pass=texcoords;
  normals_pass=(uniform_Transformation * -vec4(normal.x,normal.y,normal.z,0)).xyz;
  toLight_pass=pos.xyz-lightPos;
  float dtl=length(toLight_pass);
  toLight_pass=normalize(toLight_pass);
  toEye_pass = eyePos-pos.xyz;
  float dte=length(toEye_pass);
  toEye_pass=normalize(toEye_pass);
  fog_pass=(fogConstant+dte*fogLinear+pow(dte,2)*fogQuadratic);
  fog_pass=dte/fog_pass;
  if (fog_pass > 1.0f) {
      fog_pass=1.0f;
  }
  fog_pass=1.0f-fog_pass;
  attenuation_pass=(lightConstant+dtl*lightLinear+pow(dtl,2)*lightQuadratic);
  attenuation_pass=dtl/attenuation_pass;
  if (attenuation_pass > 1.0f) {
      attenuation_pass=1.0f;
  }
  shadow_position_pass=(lightMatrix*pos).xyz;
  gl_Position=uniform_Projection * camrel;
} 