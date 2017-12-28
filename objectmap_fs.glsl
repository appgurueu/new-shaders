#version 330
uniform sampler2D tex;
in vec2 texcoords_pass;
layout(location = 0) out float fragmentdepth;
void main() {
    if (texture(tex, texcoords_pass).w == 0) {
      discard;
    }
    fragmentdepth = gl_FragCoord.z;
}
