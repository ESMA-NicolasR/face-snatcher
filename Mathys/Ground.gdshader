shader_type spatial;
uniform sampler2D groundTexture;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 fake_uvs = world_position.xz/5.0 + vec2(0.0, TIME);
	ALBEDO = texture(groundTexture, fake_uvs).rgb;
	
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
