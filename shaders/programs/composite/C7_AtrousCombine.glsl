#define WHITEWORLD Off // [On Off]

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

#include "../../lib/debug.glsl"
#include "../../lib/utility.glsl"
#include "../../lib/encoding.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex5;
uniform bool accum;

noperspective in vec2 texcoord;

/* DRAWBUFFERS:5 */
#if (defined DEBUG) && (DEBUG_PROGRAM == ShaderStage)
	/* DRAWBUFFERS:57 */
	#define DEBUG_OUT gl_FragData[1]
#endif
#include "../../lib/exit.glsl"

void main() {
	vec3 albedo = texelFetch(colortex1, ivec2(gl_FragCoord.xy), 0).rgb;
	
	vec4 prevCol = max(texture(colortex5, texcoord), 0) * float(accum);
	vec4 currCol = texture(colortex2, texcoord);
	
	if (!WHITEWORLD) {
		currCol.rgb *= albedo;
	}
	
	gl_FragData[0] = prevCol + currCol;
	
	exit();
}

#endif
/***********************************************************************/
