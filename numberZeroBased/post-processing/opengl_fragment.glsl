uniform sampler2D baseTexture;
uniform sampler2D depthmap; /*Required, but currently just BLACK. C++ code needs to have a change.*/

uniform float resolution;

/*
Usage : 
radius - Blur radius in px
step - Blur stepsize in px
*/
vec4 average(float radius, float step)
{
   vec2 texcoords_pass = gl_TexCoord[0].st; /*I miss the texcoords*/
   vec2 dirs[]=vec2[8] (vec2(1.0f/resolution,0.0f),vec2(-1.0f/resolution,0.0f),vec2(0.0f,1.0f/resolution),vec2(0.0f,-1.0f/resolution),vec2(1.0f/resolution,1.0f/resolution),vec2(-1.0f/resolution,-1.0f/resolution),vec2(-1.0f/resolution,1.0f/resolution),vec2(1.0f/resolution,-1.0f/resolution));
   vec4 result=texture(baseTexture,texcoords_pass);
   float sum=1.0f;
   for (float i=0; i < radius; i+= step) {
       for (int j=0; j < 8; j++) {
           result+=texture(baseTexture,texcoords_pass+i*dirs[j]);
       }
       sum+=8;
   }
   return result/sum;
}
/*
Just for fun : 
Edgefinder, depthmap based
Usage : 
radius - Blur radius in px
step - Blur stepsize in px
tc - starting uv coordinates
*/
float edge(float radius, float step, vec2 tc)
{
   float sd=texture(depthmap,tc).x;
   if (sd==1.0f) {
       return 0.0f;
   }
   float edge=1.0f;
   for (float i=0; i < radius; i+=step) {
       for (int j=0; j < 8; j++) {
           float w=abs(1-abs(texture(depthmap, tc+i*dirs[j]).x-sd));
           edge*=w;
       }
   }
   return edge;
}

/*
Just for fun : 
Edgefinder, texture based
Usage : 
radius - Blur radius in px
step - Blur stepsize in px
tc - starting uv coordinates
*/
float edge_texture(float radius, float step, vec2 tc)
{
   vec3 sd=texture(baseTexture,tc).xyz;
   if (sd.x+sd.y+sd.z==0.0f) {
       return 0.0f;
   }
   float edge=1.0f;
   for (float i=0;i < radius; i+= step) {
       for (int j=0; j < 8; j++) {
           vec3 rgb=texture(baseTexture, tc+i*dirs[j]).xyz;
           vec3 diff=round(vec3(1,1,1)-abs(rgb-sd)*vec3(4,4,4))/2.5f;
           float w=diff.x*diff.y*diff.z;
           edge*=w*w;
       }
   }
   return sqrt(edge);
}



#if ENABLE_TONE_MAPPING

/* Hable's UC2 Tone mapping parameters
	A = 0.22;
	B = 0.30;
	C = 0.10;
	D = 0.20;
	E = 0.01;
	F = 0.30;
	W = 11.2;
	equation used:  ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F
*/

vec3 uncharted2Tonemap(vec3 x) {
	return ((x * (0.22 * x + 0.03) + 0.002) / (x * (0.22 * x + 0.3) + 0.06)) - 0.03333;
}

vec4 applyToneMapping(vec4 color) {
	color = vec4(pow(color.rgb, vec3(2.2)), color.a);
	const float gamma = 1.6;
	const float exposureBias = 5.5;
	color.rgb = uncharted2Tonemap(exposureBias * color.rgb);
	// Precalculated white_scale from
	//vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
	vec3 whiteScale = vec3(1.036015346);
	color.rgb *= whiteScale;
	return vec4(pow(color.rgb, vec3(1.0 / gamma)), color.a);
}
#endif

#if ENABLE_FOCUS
const float focus_radius=3.0f;
const float focus_step=1.0f;
const float focus_start=0.2f;
#endif

#if ENABLE_TOON
const float toon_radius=3.0f;
const float toon_step=1.0f;
#endif

void main(void)
{
	vec2 uv = gl_TexCoord[0].st;
	vec4 color = texture2D(baseTexture, uv).rgba;
#if ENABLE_TONE_MAPPING
	color = applyToneMapping(color);
#endif
#if ENABLE_FOCUS
        /*I assume the depth values are all linearized !*/
        float depth_at_center=texture(depthmap,vec2(0.5f,0.5f)).x; /*Depth value at the center of the screen, the distance where the player is focusing at*/
        float depth_here=texture(depthmap,uv).x; /*Depth value here*/
	float difference=abs(depth_at_center-depth_here);
	if (focus_start > 0.2f) {
	    color=vec4(average(difference*focus_radius,focus_step), color.w);
	}
#endif
#if ENABLE_TOON
        /*I assume the depth values are all linearized !*/
	edge_tex=edge_texture(toon_radius, toon_step, uv);
	edge_depth=edge(toon_radius, toon_step, uv);
	edge=max(edge_tex, edge_depth);
	color=vec4(color.x*(1-edge), color.y*(1-edge), color.z*(1-edge), color.w);
#endif
	gl_FragColor = clamp(color, 0, 1); /*Safety : Clamping*/
}
