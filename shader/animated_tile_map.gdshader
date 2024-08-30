shader_type canvas_item;

uniform sampler2D tileset_texture_0;
uniform sampler2D tileset_texture_1;
uniform sampler2D tileset_texture_2;

uniform int frame_count = 1;
uniform float time;
uniform int source_id = 0;



void fragment() {
	vec2 uv = FRAGCOORD.xy / TEXTURE_PIXEL_SIZE;

	int current_frame = int(mod(time * float(frame_count), float(frame_count)));
	vec2 frame_uv = UV;

	vec4 color;
	if (source_id == 0) {
		color = texture(tileset_texture_0, frame_uv);
	} else if (source_id == 1) {
		color = texture(tileset_texture_1, frame_uv);
	} else if (source_id == 2) {
		color = texture(tileset_texture_2, frame_uv);
	} else {
		color = vec4(1.0, 0.0, 0.0, 1.0);
	}

	COLOR = color;
}