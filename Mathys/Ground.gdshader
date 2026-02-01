shader_type spatial;
uniform sampler2D groundTexture;
uniform vec2 uv_tiling;
uniform vec2 uv_panning;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec3 displaced = VERTEX;
	displaced.y -= pow(world_position.z, 2.0)/600.0;
	VERTEX = displaced;
}

void fragment() {
	vec2 fake_uvs = world_position.xz/uv_tiling + TIME * uv_panning;
	ALBEDO = texture(groundTexture, fake_uvs).rgb;
	
	// Called for every pixel the material is visible on.
}

