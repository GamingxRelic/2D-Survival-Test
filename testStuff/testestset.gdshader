shader_type canvas_item;

// Pixel size
uniform float pixel_size : hint_range(1.0, 10.0) = 2.0;

void vertex() {
    // Quantize the texture coordinates to create pixel art effect
    VERTEX.x = floor(VERTEX.x / pixel_size) * pixel_size;
    VERTEX.y = floor(VERTEX.y / pixel_size) * pixel_size;
}

void fragment() {
    // Set the color to white (you can customize this based on your preferences)
    COLOR = vec4(1.0, 1.0, 1.0, 1.0);
}
