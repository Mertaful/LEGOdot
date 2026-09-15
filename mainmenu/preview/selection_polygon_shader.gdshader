shader_type canvas_item;
render_mode blend_add;

uniform float amplitude: hint_range(0.0, 1.0);
uniform float speed: hint_range(0.0, 2.0);

float hash(vec2 p) {
  return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

float noise(vec2 x) {
  vec2 p = floor(x);
  vec2 f = fract(x);
  f = f * f * (3.0 - 2.0 * f);
  vec2 a = vec2(1.0, 0.0);
  return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x),
         mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

void vertex() {
	// Called for every vertex the material is visible on.
	float time = TIME * (30. * speed);
	float wobbling = sin(time) * 40. * amplitude;
	float direction = sin(VERTEX.x / 2.);
	VERTEX += vec2(direction * wobbling, wobbling);
	//VERTEX += direction;
}

void fragment() {
	//vec4 tx = texture(TEXTURE,UV);
	//COLOR.rgb = mix(vec3(1.0),tx.rgb+COLOR.rgb,tx.a+COLOR.a);
}
