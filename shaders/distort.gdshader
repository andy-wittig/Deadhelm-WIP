shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise: repeat_enable, filter_nearest;
uniform float speed : hint_range(0.05, 0.5) = 0.1;
uniform float strength : hint_range(0.005, 0.5) = 0.1;

void fragment() {
	float noise_value = texture(noise, UV + TIME * speed).r;
	COLOR = texture(TEXTURE, UV - (strength / 2.0) + vec2(noise_value) * strength);
}

