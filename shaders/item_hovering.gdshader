shader_type canvas_item;

uniform float speed : hint_range(-5, 5) = 1.0;
uniform bool hovering = true;

// Function to move the texture vertically
float move_texture(float time) {
	return sin(TIME * speed) - 4.0;
}
// Apply the vertical movement to the Y coordinate of the vertex
void vertex() {
	if(hovering) {
		VERTEX.y += move_texture(TIME);
	}
}
