shader_type canvas_item;

void vertex() {
	VERTEX.x += sin(TIME * 1.4) * (1.0 - UV.y) * 2.5;
}

void fragment() {

}
