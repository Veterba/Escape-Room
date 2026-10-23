// The CRT look over the password menu's TV: a soft phosphor glow (a small blur of what is
// underneath, added back on top), faint scanlines in real screen pixels, a slow bright band
// sweeping down, and a rare short flicker.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform vec4 phosphor : source_color = vec4(0.275, 1.0, 0.561, 1.0);
// Glow: how far the inner and outer ring of samples reach, in screen pixels, and how strong.
uniform float glow_near = 3.0;
uniform float glow_far = 10.0;
uniform float glow_strength = 0.8;
// Only what is brighter than this glows, so the dark background stays dark.
uniform float glow_floor = 0.12;
// Scanlines: one darker line every this many screen pixels.
uniform float scanline_period = 3.0;
uniform float scanline_darkness = 0.28;
// The band: seconds for one sweep, its height as a share of the TV, and how bright it is.
uniform float band_time = 5.5;
uniform float band_height = 0.18;
uniform float band_strength = 0.09;
// Flicker: one cycle in seconds; the picture dims briefly twice in each cycle.
uniform float flicker_time = 6.0;

const int GLOW_SAMPLES = 8;

void fragment() {
	vec3 base = texture(screen_texture, SCREEN_UV).rgb;
	vec3 glow = vec3(0.0);
	for (int i = 0; i < GLOW_SAMPLES; i++) {
		float angle = TAU * float(i) / float(GLOW_SAMPLES);
		vec2 direction = vec2(cos(angle), sin(angle)) * SCREEN_PIXEL_SIZE;
		glow += max(texture(screen_texture, SCREEN_UV + direction * glow_near).rgb - glow_floor, 0.0);
		glow += 0.5 * max(texture(screen_texture, SCREEN_UV + direction * glow_far).rgb - glow_floor, 0.0);
	}
	vec3 color = base + glow / (1.5 * float(GLOW_SAMPLES)) * glow_strength;

	float band_at = fract(TIME / band_time) * (1.0 + 2.0 * band_height) - band_height;
	float band = max(0.0, 1.0 - abs(UV.y - band_at) / (0.5 * band_height));
	color += phosphor.rgb * band_strength * band;

	if (mod(FRAGCOORD.y, scanline_period) < 1.0) {
		color *= 1.0 - scanline_darkness;
	}

	float cycle = fract(TIME / flicker_time);
	if (cycle > 0.48 && cycle < 0.49) {
		color *= 0.86;
	} else if (cycle > 0.72 && cycle < 0.73) {
		color *= 0.95;
	}
	COLOR = vec4(color, 1.0);
}
