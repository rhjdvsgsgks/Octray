//#define ATROUS_FILTER

#define ATROUS_FILTER_PASSES_1
#define ATROUS_FILTER_PASSES_2
#define ATROUS_FILTER_PASSES_3
#define ATROUS_FILTER_PASSES_4
#define ATROUS_FILTER_PASSES_5

#ifdef ATROUS_FILTER
#endif
#ifdef ATROUS_FILTER_PASSES_1
#endif
#ifdef ATROUS_FILTER_PASSES_2
#endif
#ifdef ATROUS_FILTER_PASSES_3
#endif
#ifdef ATROUS_FILTER_PASSES_4
#endif
#ifdef ATROUS_FILTER_PASSES_5
#endif

/***********************************************************************/
#if defined vsh

noperspective out vec2 texcoord;

void main() {
	texcoord    = gl_Vertex.xy;
	gl_Position = vec4(gl_Vertex.xy * 2.0 - 1.0, 0.0, 1.0);
}

#endif
/***********************************************************************/



/***********************************************************************/
#if defined fsh

#include "lib/debug.glsl"
#include "lib/utility.glsl"
#include "lib/encoding.glsl"

#if (ATROUS_INDEX == 0)
uniform sampler2D colortex2;
const bool colortex2MipmapEnabled = true;
#define COLORSAMPLER colortex2
#else
uniform sampler2D colortex5;
const bool colortex5MipmapEnabled = true;
#define COLORSAMPLER colortex5
#endif

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

uniform vec2 viewSize;

noperspective in vec2 texcoord;

/* DRAWBUFFERS:5 */
uniform bool DRAWBUFFERS_5;
#include "lib/exit.glsl"

void main() {
	// if (texture(depthtex0, texcoord).x >= 1.0) {
	// 	gl_FragData[0] = texture(COLORSAMPLER, texcoord);
	// 	return;
	// }
	
	vec4 col = vec4(0);
	
	int kernal = 2 << ATROUS_INDEX;
	float weights = 0.0;
	
	vec4 color0 = texture(COLORSAMPLER, texcoord);
	vec3 normal = texture(colortex0, texcoord).rgb;
	float vDepth = texture(colortex0, texcoord).a;
	
	for (int i = -kernal; i <= kernal; i += 1 << ATROUS_INDEX) {
		for (int j = -kernal; j <= kernal; j += 1 << ATROUS_INDEX) {
			vec2 offset = vec2(i,j) / viewSize;
			vec2 coord = texcoord + offset * exp2(-color0.a / 10.0*0);
			
			// if (texture(depthtex0, coord).x >= 1.0) continue;
			
			vec3 samplenormal = texture(colortex0, coord).rgb;
			float sampledepth = texture(colortex0, coord).a;
			
			vec4 color = texture(COLORSAMPLER, coord);
			
			float weight = 1.0;
			// weight *= pow(length(16 - vec2(i,j)) / 16.0, 2.0);
			weight *= max(dot(normal, samplenormal)*16-15, 0.0);
			weight *= max(1.0-distance(vDepth, sampledepth), 0.0);
			weight = weight + 0.000001;
			
			col += color * weight;
			weights += weight;
		}
	}
	
	col /= weights;
	
	gl_FragData[0] = vec4(col);
	
	exit();
}

#endif
/***********************************************************************/
