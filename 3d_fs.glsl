#version 330

layout(location = 1) out vec4 mgl_FragColor;
layout(location = 0) out float fragmentdepth;
//layout(location=2) out vec4 mgl_object;

uniform sampler2D tex;
uniform sampler2D bumpmap;
uniform sampler2D diffusemap;
uniform sampler2D specularmap;
uniform sampler2D gaussianmap;
uniform sampler2D shadowmap;
uniform vec3 lightDiffuse;
uniform vec3 lightSpecular;
uniform vec3 lightGaussian;
uniform vec3 fogColor;
uniform float ambient;

in vec2 texcoords;
in vec3 toEye;
in vec3 toLight;
in float attenuation;
in vec3 normals;
in vec3 shadow_position;
in vec3 world;
in float fog;

void main (void)
{ 
  vec4 texture_color =  texture(tex,texcoords);
  vec2 tv=vec2(sin(texcoords.x),cos(texcoords.y));
  vec2 t=vec2(tan(texcoords.x),tan(texcoords.y));
  texture_color=texture(tex,refract(tv,t,dot(toEye,normals)*1.33f));
  if (texture_color.w == 0) {
      discard;
  }
  vec3 normals_bumpmap = normalize(texture(bumpmap,texcoords).xyz);
  vec3 normals=normals_bumpmap*normals;
  float brightness = dot(normals,toLight);
  brightness=clamp(brightness,0,1);
  vec3 ReflectedVector = normalize(reflect(toLight, normals));
  float SpecularFactor = dot(toEye, ReflectedVector);
  SpecularFactor=clamp(pow(SpecularFactor,32),0, 1);
  
  vec3 diffuse = clamp(vec3(1,1,1)*brightness,0,1);
  vec3 specular = clamp(vec3(1,1,1) * SpecularFactor,0,1);
  vec3 gaussian = vec3(1,1,1)*clamp(refract(ReflectedVector,toEye,0.5f),0,1);
  gaussian = clamp(cross(refract(ReflectedVector,toEye,0.5f),refract(normals,toEye,0.5f)),0,1);
//gaussian = vec3(1,1,1)*clamp(cross(toLight,cross(toEye,normals)).y,0,1);
  diffuse*=lightDiffuse*texture(diffusemap,texcoords).xyz;
  specular*=lightSpecular*texture(specularmap,texcoords).xyz;
  gaussian*=lightGaussian*texture(gaussianmap,texcoords).xyz;
  float visibility = 1.0;
  if ( texture( shadowmap, shadow_position.xy ).x  <  shadow_position.z){
    visibility = 1-abs(texture( shadowmap, shadow_position.xy ).x-shadow_position.z)*3;
  }
  visibility=clamp(visibility,0,1);
  //mgl_FragColor=vec4(gaussian,1.0f);
  //mgl_FragColor=texture(shadowmap,shadow_position.xy);
  //mgl_FragColor=vec4(fog,fog,fog,1.0f);
  //mgl_FragColor=vec4(specular.x,diffuse.y,gaussian.z,texture_color.w);
mgl_FragColor=vec4(clamp((fogColor*fog*ambient*visibility)+((1.0-fog)*texture_color.xyz*ambient+visibility*attenuation*texture_color.xyz*0.5f*(gaussian+diffuse+(1-specular))),0,1),texture_color.w);
  
  float ndcDepth =
    (2.0 * gl_FragCoord.z - gl_DepthRange.near - gl_DepthRange.far) /
    (gl_DepthRange.far - gl_DepthRange.near);
float clipDepth = ndcDepth / gl_FragCoord.w;
  fragmentdepth = ((clipDepth * 0.5) + 0.5)/100.0f/* gl_FragCoord.z/gl_FragCoord.w*/;
  //mgl_object=vec4(1,1,1,1);
  //mgl_FragColor=vec3(fragmentdepth,fragmentdepth,fragmentdepth);
   //mgl_FragColor=vec4(clamp(texture_color.xyz*ambient+visibility*(texture_color.xyz*attenuation*(diffuse*lightDiffuse*texture(diffusemap,texcoords_pass).xyz+specular*lightSpecular*texture(specularmap,texcoords_pass).xyz+gaussian*lightGaussian*texture(gaussianmap,texcoords_pass).xyz)),0,1),texture_color.w)
}