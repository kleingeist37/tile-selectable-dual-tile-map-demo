class_name WangPoc extends Node2D

const NEIGHBOUR_WANGS := [
	Vector2i(0, 0), #bottom left
	Vector2i(1, 0), #bottom right
	Vector2i(0, 1), #top left
	Vector2i(1, 1), #top right
];

var true_coord := Vector2i(0,0);
var false_coord := Vector2i(1,0);
var expected_type:= Vector2i.ZERO;

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

func set_tile(map_pos: Vector2i, ground_type_atlas_coords: Vector2i, ground_type: int, ground_overlay: int) -> void:
	#for simplicity, the expected type is handled by ground_type_atlas_coords. 
	#you should use a custom logic for this in production
	#e.g. set expected ground type in mouse controller and change the custom_data "ground_type" in data coord at pos x,y 
	expected_type = ground_type_atlas_coords;
	data_layer.set_cell(map_pos, 0, ground_type_atlas_coords); #data layer only uses one source id
	
	set_visual_layer(map_pos, ground_type_atlas_coords, ground_type, ground_overlay);
	pass;


func set_visual_layer(map_pos: Vector2i, ground_atlas_coords: Vector2i, ground_type: int, ground_overlay_source: int = 0) -> void:
	for wang_neighbour: Vector2i in NEIGHBOUR_WANGS:
		var wang_pos := map_pos + wang_neighbour;
		ground_layer.set_cell(wang_pos, ground_type, ground_atlas_coords);
		
		#emulating that the user perhaps just want to set a ground tile
		if ground_overlay_source != -1:
			ground_overlay.set_cell(wang_pos, ground_overlay_source, calculate_overlay_tile(wang_pos))


func calculate_overlay_tile(coord: Vector2i) -> Vector2i:
	var bot_right := calc_type(coord - NEIGHBOUR_WANGS[0]);
	var bot_left := calc_type(coord - NEIGHBOUR_WANGS[1]);
	var top_right := calc_type(coord - NEIGHBOUR_WANGS[2]);
	var top_left := calc_type(coord - NEIGHBOUR_WANGS[3]);

	return atlas_neighbour_dict[[top_left, top_right, bot_left, bot_right]];


func calc_type(coords: Vector2i) -> bool:
	var atlas_coord := data_layer.get_cell_atlas_coords(coords);
	#usually you should check here the custom data of the tile instead of atlas coord. 
	#get it from (pseudocode= tile_source.get_tile_data(atlas_coord).get_custom_data("ground_type")
	return atlas_coord == expected_type;
