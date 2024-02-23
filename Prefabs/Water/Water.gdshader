shader_type spatial;

render_mode cull_disabled;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D normalMap;

uniform vec4 deepWaterColor : source_color;

uniform float depthFactor : hint_range(0.0, 10.0);
uniform float distortionFactor : hint_range(0.0, 1.0);
uniform float tiling : hint_range(0.125, 1.0);
uniform float speed : hint_range(0.03125, 1.0);
uniform float roughness : hint_range(0.0, 1.0);

void fragment() {
	vec3 UP = vec3(0.0, 1.0, 0.0);
	vec2 shift = vec2(0.1, 0.3) * TIME * speed * 2.0;
	vec2 shift2 = vec2(0.3, -0.2) * TIME * speed;
	vec3 nc1 = texture(normalMap, UV * tiling + shift).xyz;
	vec3 nc2 = texture(normalMap, UV * tiling + shift2).xyz;
	vec3 normalColor1 = nc1 * 2.0 - 1.0;
	vec3 normalColor2 = nc2 * 2.0 - 1.0;
	vec3 normalColor = ((normalColor1 + normalColor2) / 2.0) * distortionFactor / 10.0;
	vec2 dist = vec2(normalColor.x, normalColor.y);
	vec2 uv = SCREEN_UV + dist;
	
	float depth = texture(depth_texture, uv).r;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;

	float depth2 = 1.0 - exp(-depth * 20.0);
	depth = 1.0 - exp(-depth * depthFactor);
	
	vec4 surfaceScreenColor = vec4(0.0, 0.0, 0.0, 1.0);

	float samples = 10.0;
	float angle = 6.283 / 10.0;

	for (float i = 0.0; i < samples; i += 1.0) {
		vec2 uv2 = uv + vec2(cos(angle * i), sin(angle * i)) * 0.005;
		surfaceScreenColor += texture(screen_texture, uv2 - dist * (1.0 - depth2));
	}

	surfaceScreenColor /= samples;

	vec4 deepScreenColor = deepWaterColor;

	NORMAL_MAP = (nc1 + nc2) / 2.0;
	NORMAL_MAP_DEPTH = 1.0 * distortionFactor * 2.0;
	ALBEDO = mix(surfaceScreenColor, deepScreenColor, depth).rgb;
	ROUGHNESS = roughness;
	ALPHA = depth2;
}
