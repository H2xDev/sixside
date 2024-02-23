// Credit: https://godotshaders.com/shader/decal-shader-4-0-port/
// Upgraded by: https://github.com/H2xDev
shader_type spatial;
render_mode blend_add, world_vertex_coords;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform float cube_half_size = 1.0;
uniform vec3 rotation;
uniform vec3 surfaceNormal;

varying mat4 INV_MODEL_MATRIX;
varying vec2 DECAL_UV;
varying float ATTEN;

void vertex(){
	INV_MODEL_MATRIX = inverse(MODEL_MATRIX);
}

// Credit: https://stackoverflow.com/questions/32227283/getting-world-position-from-depth-buffer-value
vec3 world_pos_from_depth(float depth, vec2 screen_uv, mat4 inverse_proj, mat4 inverse_view) {
	float z = depth;
	
	vec4 clipSpacePosition = vec4(screen_uv * 2.0 - 1.0, z, 1.0);
	vec4 viewSpacePosition = inverse_proj * clipSpacePosition;
	
	viewSpacePosition /= viewSpacePosition.w;
	
	vec4 worldSpacePosition = inverse_view * viewSpacePosition;
	
	return worldSpacePosition.xyz;
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 world_pos = world_pos_from_depth(depth, SCREEN_UV, INV_PROJECTION_MATRIX, (INV_VIEW_MATRIX));
	vec4 test_pos = (INV_MODEL_MATRIX * vec4(world_pos, 1.0));
	
	if (abs(test_pos.x) > cube_half_size || abs(test_pos.y) > cube_half_size || abs(test_pos.z) > cube_half_size) {
		discard;
	}

	vec3 trot = rotation;
	
	mat4 rotation_matrix = mat4(
		vec4(cos(trot.y) * cos(trot.z), cos(trot.y) * sin(trot.z), -sin(trot.y), 0.0),
		vec4(sin(trot.x) * sin(trot.y) * cos(trot.z) - cos(trot.x) * sin(trot.z), sin(trot.x) * sin(trot.y) * sin(trot.z) + cos(trot.x) * cos(trot.z), sin(trot.x) * cos(trot.y), 0.0),
		vec4(cos(trot.x) * sin(trot.y) * cos(trot.z) + sin(trot.x) * sin(trot.z), cos(trot.x) * sin(trot.y) * sin(trot.z) - sin(trot.x) * cos(trot.z), cos(trot.x) * cos(trot.y), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);

	DECAL_UV = (test_pos * rotation_matrix).yz + 0.5;
	
	ALBEDO = texture(texture_albedo, DECAL_UV).rgb * albedo.rgb;
	ALPHA = texture(texture_albedo, DECAL_UV).a * albedo.a;
}
