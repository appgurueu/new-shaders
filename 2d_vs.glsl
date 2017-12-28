#version 330

in vec3 attribute_Position;
in vec2 texcoords;
in vec3 normal;
in vec3 transform;

out vec2 texcoords_pass;

void main(void) 
{ 
  texcoords_pass=texcoords;
  gl_Position=vec4(attribute_Position,1.0f);
} 
