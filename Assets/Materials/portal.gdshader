shader_type spatial;
render_mode unshaded;

uniform sampler2D viewport_texture: source_color;
varying vec4 screenPos;

void fragment() {
	vec2 uv = SCREEN_UV;
	ALBEDO = texture(viewport_texture, uv).rgb;
}
