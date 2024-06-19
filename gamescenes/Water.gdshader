shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(-0.05,-0.05);
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float distortion_strength : hint_range(-1, 1) = 0.2;
uniform vec4 tone_color : source_color;
uniform vec4 top_color : source_color;
uniform float light_start : hint_range(0.0, 1.0) = 0.275;
uniform float light_end : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 timeScroll1 = scroll1 * TIME;
	vec2 timeScroll2 = scroll2 * TIME;
	float depth1 = texture(noise1, UV + timeScroll1).r;
	float depth2 = texture(noise2, UV + timeScroll2).r;
	float depth = depth1 * depth2;
	vec4 screen_col = texture(screen_texture,
		SCREEN_UV + distortion_strength * vec2(depth));
	vec4 top_light = smoothstep(light_start, light_end, depth) * top_color;
	COLOR = screen_col * tone_color + top_light;
	COLOR.a = 1.0; //cap alpha yeag
}