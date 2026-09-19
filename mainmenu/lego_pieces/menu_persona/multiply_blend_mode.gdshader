shader_type canvas_item;
render_mode blend_mul;

void fragment() {
	vec4 tx = texture(TEXTURE,UV);
	COLOR.rgb = mix(vec3(1.0),tx.rgb*COLOR.rgb,tx.a*COLOR.a);
}
