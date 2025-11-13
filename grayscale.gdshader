shader_type canvas_item;
uniform float percent = 0.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    COLOR = texture(TEXTURE, UV);
    float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	COLOR.r = COLOR.r*(1.0-percent)+percent*avg;
	COLOR.g = COLOR.g*(1.0-percent)+percent*avg;
	COLOR.b = COLOR.b*(1.0-percent)+percent*avg;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
