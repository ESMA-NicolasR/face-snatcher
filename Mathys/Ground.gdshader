shader_type spatial;
uniform sampler2D groundTexture;
uniform vec2 uv_tiling;
uniform vec2 uv_panning;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Input:10
	vec3 n_out10p0 = NODE_POSITION_WORLD;
// Input:3
	vec3 n_out3p0 = VERTEX;
// VectorOp:11
	vec3 n_out11p0 = n_out10p0 + n_out3p0;
// VectorDecompose:6
	float n_out6p0 = n_out11p0.x;
	float n_out6p1 = n_out11p0.y;
	float n_out6p2 = n_out11p0.z;
// Mix:22
	float n_in22p0 = 1.00000;
	float n_in22p1 = 2.00000;
	float n_out22p0 = mix(n_in22p0, n_in22p1, n_out6p2);
// FloatOp:20
	float n_out20p0 = pow(n_out6p2, n_out22p0);
// FloatOp:19
	float n_out19p0 = n_out6p1 - n_out20p0;
// VectorCompose:5
	vec3 n_out5p0 = vec3(n_out6p0, n_out19p0, n_out6p2);
// VectorOp:13
	vec3 n_out13p0 = n_out5p0 - n_out10p0;
// Output:0
	vec3 displaced = VERTEX;
	displaced.y += pow(world_position.z, 2.0)/50.0;
	VERTEX = displaced;
}

void fragment() {
	vec2 fake_uvs = world_position.xz/uv_tiling + TIME * uv_panning;
	ALBEDO = texture(groundTexture, fake_uvs).rgb;
	
	// Called for every pixel the material is visible on.
}

