shader_type canvas_item;

float random(vec2 uv)
{
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 438.5453);
}

uniform float sensitivity : hint_range(0.0, 1.0) = 0.0;

void fragment()
{
	float size_x = float(textureSize(TEXTURE, 0).x);
	float size_y = float(textureSize(TEXTURE, 0).y);
	vec4 pixelColor = texture(TEXTURE, UV);
	vec2 UVr = vec2(floor(UV.x * size_x) / size_x, floor(UV.y * size_y) / size_y);
	float visible = step(sensitivity, random(UVr));
	COLOR = vec4(pixelColor.r, pixelColor.g, pixelColor.b, min(visible, pixelColor.a));
}