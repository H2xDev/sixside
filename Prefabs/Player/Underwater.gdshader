shader_type spatial;

render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable;

uniform float depthFactor : hint_range(0.0, 10.0);
uniform vec4 deepWaterColor : source_color;

void vertex() {
 	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = 1.0 - exp(-depth * depthFactor);

	vec3 surfaceScreenColor = texture(screen_texture, SCREEN_UV).rgb;

	ALBEDO = mix(surfaceScreenColor, deepWaterColor.rgb, depth);
}
