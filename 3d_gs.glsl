#version 330

layout (triangles) in;
layout (triangle_strip, max_vertices=6) out;

in vec3 world_pass[];
in vec2 texcoords_pass[];
in float attenuation_pass[];
in vec3 normals_pass[];
in vec3 shadow_position_pass[];
in vec3 toLight_pass[];
in vec3 toEye_pass[];
in float fog_pass[];

out vec3 world;
out float attenuation;
out vec3 normals;
out vec3 shadow_position;
out vec3 toLight;
out vec3 toEye;
out float fog;
out vec2 texcoords;

void main(void)
{
    int i;

    for (i = 0; i < gl_in.length(); i++)
    {
        texcoords=texcoords_pass[i];
        world=world_pass[i];
        attenuation=attenuation_pass[i];
        normals=normals_pass[i];
        shadow_position=shadow_position_pass[i];
        toLight=toLight_pass[i];
        toEye=toEye_pass[i];
        fog=fog_pass[i];
        gl_Position = gl_in[i].gl_Position;/*-vec4(normalize(normals_pass[i]),0)*0.5;*/
        EmitVertex();
        /*gl_Position=gl_in[i].gl_Position-vec4(normals_pass[i],0)*0.5;
        EmitVertex();*/
        /*gl_Position = gl_in[i].gl_Position;
        EmitVertex();*/
    }
    EndPrimitive();
    for (i = 0; i < gl_in.length(); i++)
    {
        texcoords=texcoords_pass[i];
        world=world_pass[i];
        attenuation=attenuation_pass[i];
        normals=normals_pass[i];
        shadow_position=shadow_position_pass[i];
        toLight=toLight_pass[i];
        toEye=toEye_pass[i];
        fog=fog_pass[i];
        gl_Position = gl_in[i].gl_Position;/*-vec4(normalize(normals_pass[i]),0)*0.5;*/
        EmitVertex();
        /*gl_Position=gl_in[i].gl_Position-vec4(normals_pass[i],0)*0.5;
        EmitVertex();*/
        /*gl_Position = gl_in[i].gl_Position;
        EmitVertex();*/
    }
    EndPrimitive();
    /*vec3 a=(gl_in[0].gl_Position.xyz+gl_in[1].gl_Position.xyz)/2;
    vec3 b=(gl_in[0].gl_Position.xyz+gl_in[2].gl_Position.xyz)/2;
    vec3 c=(gl_in[1].gl_Position.xyz+gl_in[2].gl_Position.xyz)/2;
    gl_Position = vec4((a+b+c)/3,1);
    EmitVertex();*/
    //EndPrimitive();
}
