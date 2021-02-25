// Notes:
// - From Godot 3.1 you can also use the builtin perlin noise textures so you can create it faster.
// - Godot also has OpenSimplex noise built-in.

shader_type canvas_item; // for 2d textures

uniform vec3 color = vec3(0.35, 0.48, 0.95); // fog color
uniform int OCTAVES = 4;

// generate random float by given coord 
float rand(vec2 coord) {
	//return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123); // better randomness
	// This numbers (like the most of the rest) are from https://thebookofshaders.com/13/
	// They picked the numbers because of their indivisibility.
	// If you have numbers that divide neatly then periodically you'll get patterns in the decimals.
	// Numbers that don't divide look more random because it avoid constructive and destructive
	// interference from the sine waves.
}

// generate value noise from given coord
float noise(vec2 coord) {
	vec2 i = floor(coord); // integer
	vec2 f = fract(coord); // fraction
	
	// corners of square
	float a = rand(i); // top-left
	float b = rand(i + vec2(1.0, 0.0)); // top-right
	float c = rand(i + vec2(0.0, 1.0)); // bottom-left
	float d = rand(i + vec2(1.0, 1.0)); // bottom-right
	
	// to make it cubic interpolation instead of linear;
	f = f * f * (3.0 - 2.0 * f);
	
	// mix does linear interpolation
	// value is the 2d interpolation
	float value = mix(a, b, f.x) + (c - a) * f.y * (1.0 - f.x) + (d - b) * f.x * f.y;
	
	// value also can be calculated like this;
	// float htop_mix = mix(a, b, f.x);
	// float hbottom_mix = mix(c, d, f.x);
	// float value = mix(htop_mix, hbottom_mix, f.y);
	
	return value;
}

// Fractal Brownian Motion
float fbm(vec2 coord) {
	float value = 0.0;
	float scale = 0.5;
	
	for (int i = 0; i < OCTAVES; i++) {
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	
	return value;
}

void fragment() {
	vec2 coord = UV * 20.0;
	vec2 motion = vec2(fbm(coord + vec2(TIME * 0.5, TIME * -0.5)));
	COLOR = vec4(color, fbm(coord + motion) * 0.3);
}