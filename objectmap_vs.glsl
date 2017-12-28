#version 330
#ifdef GL_ES
precision highp float; 
precision highp int; 
#endif

uniform mat4 uniform_Transformation;
uniform mat4 uniform_Modelview;
uniform mat4 uniform_Projection;
in vec4 attribute_Position;
in vec2 texcoords;
in vec3 normal;
out vec2 texcoords_pass;

void main(void) 
{ 
  texcoords_pass=texcoords;
  vec4 pos = uniform_Transformation * attribute_Position;
  vec4 camrel = pos*uniform_Modelview;
  gl_Position= uniform_Projection*pos;
} 