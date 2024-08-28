class_name WangPoc extends Node2D

const NEIGHBOUR_WANGS := [
	Vector2i(0, 0), #bottom left
	Vector2i(1, 0), #bottom right
	Vector2i(0, 1), #top left
	Vector2i(1, 1), #top right
];

var gras_coord := Vector2i(0,0)
var dirt_coord := Vector2i(1,0)
const TILE_SIZE = 128;

var atlas_neighbour_dict := {
	[true, true, true, true]: Vector2i(2, 1), # All corners
	[false, false, false, true]: Vector2i(1, 3), # Outer bottom-right corner
	[false, false, true, false]: Vector2i(0, 0), # Outer bottom-left corner
	[false, true, false, false]: Vector2i(0, 2), # Outer top-right corner
	[true, false, false, false]: Vector2i(3, 3), # Outer top-left corner
	[false, true, false, true]: Vector2i(1, 0), # Right edge
	[true, false, true, false]: Vector2i(3, 2), # Left edge
	[false, false, true, true]: Vector2i(3, 0), # Bottom edge
	[true, true, false, false]: Vector2i(1, 2), # Top edge
	[false, true, true, true]: Vector2i(1, 1), # Inner bottom-right corner
	[true, false, true, true]: Vector2i(2, 0), # Inner bottom-left corner
	[true, true, false, true]: Vector2i(2, 2), # Inner top-right corner
	[true, true, true, false]: Vector2i(3, 1), # Inner top-left corner
	[false, true, true, false]: Vector2i(2, 3), # Bottom-left top-right corners
	[true, false, false, true]: Vector2i(0, 1), # Top-left down-right corners
	[false, false, false, false]: Vector2i(0, 3), # No corners
}

@onready var data_layer: TileMapLayer = %data_layer
@onready var ground_layer: TileMapLayer = %ground_layer
@onready var ground_overlay: TileMapLayer = %ground_overlay

func mouse_to_local() -> Vector2i:
	return data_layer.local_to_map(get_global_mouse_position());

func set_tile(map_pos: Vector2i, atlas_coords: Vector2i, ground_type: int, ground_overlay: int) -> void:
	data_layer.set_cell(map_pos, 0, atlas_coords); #data layer only uses one source id - 
	
	set_visual_layer(map_pos,atlas_coords, ground_type, ground_overlay);
	pass;


func set_visual_layer(map_pos: Vector2i, atlas_coords: Vector2i, ground_type: int, ground_overlay_type: int = -1) -> void:
	for wang_neighbour: Vector2i in NEIGHBOUR_WANGS:
		var wang_pos := map_pos + wang_neighbour;
		ground_layer.set_cell(wang_pos, ground_type, atlas_coords);
		if ground_overlay_type > -1:
			ground_overlay.set_cell(wang_pos, ground_overlay_type, calculate_ground_tile(wang_pos, ground_overlay_type))


func calculate_ground_tile(coord: Vector2i, ground_type: int) -> Vector2i:
	var bot_right := calc_type(coord - NEIGHBOUR_WANGS[0]);
	var bot_left := calc_type(coord - NEIGHBOUR_WANGS[1]);
	var top_right := calc_type(coord - NEIGHBOUR_WANGS[2]);
	var top_left := calc_type(coord - NEIGHBOUR_WANGS[3]);

	return atlas_neighbour_dict[[top_left == 1, top_right == 1, bot_left == 1, bot_right == 1]];


func calc_type(coords: Vector2i) -> int:
	var atlas_coord := data_layer.get_cell_atlas_coords(coords);
	if atlas_coord == gras_coord:
		return 1;
	
	return 0;
