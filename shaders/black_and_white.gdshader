shader_type canvas_item;

uniform vec3 tint;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool enabled = false;
render_mode unshaded;

void fragment() 
{
	if (enabled)
	{
	    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	    float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	    COLOR.rgb = vec3(avg);
	}
}
