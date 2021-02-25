shader_type canvas_item;

uniform vec4 inner : hint_color;
uniform vec4 outer : hint_color;
uniform float inner_threshold = 0.4;
uniform float outer_threshold = 0.15;
uniform float soft_edge = 0.04;

uniform vec2 center = vec2(0.5, 0.8);

// for more info about; rand, noise and fbm functions;
// see 2d-shader-fog example

uniform int OCTAVES = 6;

// generate random float by given coord 
float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123);
}

// generate value noise from given coord
float noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0)); 
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	f = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, f.x) + (c - a) * f.y * (1.0 - f.x) + (d - b) * f.x * f.y;
}

// fractal brownian motion
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

float overlay(float base, float top) {
	if (base < 0.5) {
		return 2.0 * base * top;
	} else {
		return 1.0 - (2.0 * (1.0 - base) * (1.0 - top));
	}
}

float egg_shape(vec2 coord, float radius) {
	vec2 diff = abs(coord - center);
	
	if (coord.y < center.y) {
		diff.y /= 2.0;
	} else {
		diff.y *= 2.0;
	}
  	
	float dist = sqrt(diff.x * diff.x + diff.y * diff.y) / radius;
	float value = sqrt(1.0 - dist * dist);
	return clamp(value, 0.0, 1.0);
}

void fragment() {
	vec4 screen_texture_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 transparent = screen_texture_color;
		
	vec2 coord = UV * 8.0;
	vec2 fbmcoord = coord / 6.0;
	
	float egg_s = egg_shape(UV, 0.4);
	egg_s += egg_shape(UV, 0.2) / 2.0;
	
	float noise1 = noise(coord + vec2(TIME * 0.25, TIME * 4.0));
	float noise2 = noise(coord + vec2(TIME * 0.5, TIME * 7.0));
	float combined_noise = (noise1 + noise2) / 2.0;
	
	float fbm_noise = fbm(fbmcoord + vec2(0.0, TIME * 3.0));
	fbm_noise = overlay(fbm_noise, UV.y);
	
	float everything_combined = combined_noise * fbm_noise * egg_s;
	
	
	if (everything_combined < outer_threshold) {
		COLOR = transparent;
	} else if (everything_combined < outer_threshold + soft_edge) {
		COLOR = mix(transparent, outer, (everything_combined - outer_threshold) / soft_edge);
	} else if (everything_combined < inner_threshold) {
		COLOR = outer;
	} else if (everything_combined < inner_threshold + soft_edge) {
		COLOR = mix(outer, inner, (everything_combined - inner_threshold) / soft_edge);
	} else {
		COLOR = inner;
	}
}