#version 330

layout(location=0) out vec4 mgl_FragColor;

uniform sampler2D tex;
uniform sampler2D depthmap;
//uniform sampler2D objectmap;

in vec2 texcoords_pass;

const vec2 dirs[]=vec2[8] (vec2(1.0f/512.0f,0.0f),vec2(-1.0f/512.0f,0.0f),vec2(0.0f,1.0f/512.0f),vec2(0.0f,-1.0f/512.0f),vec2(1.0f/512.0f,1.0f/512.0f),vec2(-1.0f/512.0f,-1.0f/512.0f)
,vec2(-1.0f/512.0f,1.0f/512.0f),vec2(1.0f/512.0f,-1.0f/512.0f));

vec4 average(float radius, float s)
{
   vec4 result=texture(tex,texcoords_pass);
   float sum=1.0f;
   for (float i=0; i < radius; i+= s) {
       for (int j=0; j < 8; j++) {
           result+=texture(tex,texcoords_pass+i*dirs[j]);
       }
       sum+=8;
   }
   return result/sum;
}

/*vec4 average2(float radius, float s, vec2 tc)
{
   vec4 start=texture(tex,tc);
   float sd=texture(depthmap,tc).x;
   vec4 result=texture(tex,tc);
   float sum=1.0f;
   for (float i=0; i < radius; i+= s) {
       for (int j=0; j < 8; j++) {
           float w=texture(objectmap, tc+i*dirs[j]).x*abs(1.0-abs(texture(depthmap, tc+i*dirs[j]).x-sd));
           result+=texture(tex,tc+i*dirs[j])*w;
           sum+=w;
       }
   }
   return result/sum;
}*/

float edge(float radius, float s, vec2 tc)
{
   float sd=texture(depthmap,tc).x;
   if (sd==1.0f) {
       return 0.0f;
   }
   float edge=1.0f;
   for (float i=0; i < radius; i+= s) {
       for (int j=0; j < 8; j++) {
           float w=abs(1-abs(texture(depthmap, tc+i*dirs[j]).x-sd));
           edge*=w;
       }
   }
   return edge;
}

float edge_texture(float radius, float s, vec2 tc)
{
   vec3 sd=texture(tex,tc).xyz;
   if (sd.x+sd.y+sd.z==0.0f) {
       return 0.0f;
   }
   float edge=1.0f;
   for (float i=0;i < radius; i+= s) {
       for (int j=0; j < 8; j++) {
           vec3 rgb=texture(tex, tc+i*dirs[j]).xyz;
           vec3 diff=round(vec3(1,1,1)-abs(rgb-sd)*vec3(4,4,4))/2.5f;
           float w=diff.x*diff.y*diff.z;
           edge*=w*w;
       }
   }
   return sqrt(edge);
}

void main (void)
{ 
  float depth=texture(depthmap,vec2(0.5f,0.5f)).x;
  float depth_here=texture(depthmap,texcoords_pass).x;
  float difference=abs(depth-depth_here);
  vec4 texcol=texture(tex, texcoords_pass);
  //vec2 texcolor=texture(tex, texcoords_pass);
  //vec2 temp=vec2(texcoords_pass.x,texcoords_pass.y);
  //vec2 t2=vec2(tan(texcoords_pass.x),tan(texcoords_pass.y));
  //vec2 t2=vec2(tan(asin(texcoords_pass.x)),tan(acos(texcoords_pass.y)));
  //vec2 r=refract(temp,vec2(1.0f,1.0f),1.33f*(1.0f-difference));
  //vec2 r=refract(texcoords_pass,t2,difference);
  //vec4 texture_color=average2(/*difference*20*/dot(r,texcoords_pass)*5,0.9f,r);
//vec4 texture_color=average(difference*20,0.9f);
  float green=length(vec3(texcol.x*difference*10,texcol.y/depth_here,texcol.z*depth));
  //float edge=edge(2.0f,0.9f,texcoords_pass);
  float edge=0.0f;
  float edge_tex=max(edge,edge_texture(2.0f,0.9f,texcoords_pass));
  mgl_FragColor=clamp(vec4(depth_here,depth_here,depth_here,1.0f),0.0f,1.0f);
  //mgl_FragColor=clamp(vec4(edge_tex,edge_tex,edge_tex,1.0f),0.0f,1.0f);
  mgl_FragColor=vec4(clamp(texcol.xyz,0,1.0f), 1.0f);
}