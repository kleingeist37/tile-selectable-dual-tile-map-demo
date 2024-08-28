class_name TileMapManager extends Node2D

const LOCAL_NEIGHBOUR_CELLS := [
	Vector2i(0, 0),
	Vector2i(1, 0), 
	Vector2i(0, 1), 
	Vector2i(1, 1),
];

var _expected_type:= Vector2i.ZERO;
var _last_pos: Vector2i;

var _alternatives := {
	0: [0, 1, 2],
	1: [3, 4, 5]
}

const TILE_SIZE := 128;

var _atlas_neighbour_dict := {
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



func mouse_to_map() -> Vector2i:
	return data_layer.local_to_map(get_global_mouse_position());

func set_tile(map_pos: Vector2i, ground_type_atlas_coords: Vector2i, ground_type: int, ground_overlay: int) -> void:
	if map_pos == _last_pos:
		return;
		
	_last_pos = map_pos;
	
	#for simplicity, the expected type is handled by ground_type_atlas_coords. 
	#you should use a custom logic for this in production
	#e.g. set expected ground type in mouse controller and change the custom_data "ground_type" in data layer at pos x,y 
	_expected_type = ground_type_atlas_coords;
	data_layer.set_cell(map_pos, 0, ground_type_atlas_coords); #data layer only uses one source id
	
	_set_visual_layer(map_pos, ground_type_atlas_coords, ground_type, ground_overlay);
	pass;


func _set_visual_layer(map_pos: Vector2i, ground_atlas_coords: Vector2i, ground_type: int, ground_source_type: int = -1) -> void:
	for cell_neighbour: Vector2i in LOCAL_NEIGHBOUR_CELLS:
		var cell_pos := map_pos + cell_neighbour;
		ground_layer.set_cell(cell_pos, ground_type, ground_atlas_coords);
		
		#simulating that the user perhaps just want to set a ground tilex
		if ground_source_type != -1:
			var target_source := 0
			if _alternatives.has(ground_source_type):
				target_source = _get_random_position(_alternatives[ground_source_type]);

			ground_overlay.set_cell(cell_pos, target_source, _calculate_overlay_tile(cell_pos))


func _calculate_overlay_tile(coord: Vector2i) -> Vector2i:
	
	var bot_right := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[0]);
	var bot_left := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[1]);
	var top_right := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[2]);
	var top_left := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[3]);

	return _atlas_neighbour_dict[[top_left, top_right, bot_left, bot_right]];


func _calc_type(coords: Vector2i) -> bool:
	var atlas_coord := data_layer.get_cell_atlas_coords(coords);
	#usually you should check here the custom data of the tile instead of atlas coord. 
	#get it from (pseudocode= tile_source.get_tile_data(atlas_coord).get_custom_data("ground_type")
	return atlas_coord == _expected_type;
	

func _get_random_position(target_array: Array) -> int:
	return target_array[randi() % target_array.size()]
