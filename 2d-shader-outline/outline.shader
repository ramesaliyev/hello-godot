// outline2 is improved version and actually easier to understand.

shader_type canvas_item;

uniform float width : hint_range(0.0, 30.0);
uniform vec4 outline_color : hint_color;

void fragment() {
	// a little bit improved code
    vec2 size = vec2(width) / vec2(textureSize(TEXTURE, 0));

	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -8.0 * sprite_color.a;
	
	alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
	alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
	
	vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
}