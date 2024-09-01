class_name DualTileMap extends Node2D

const LOCAL_NEIGHBOUR_CELLS := [
	Vector2i(0, 0),
	Vector2i(1, 0), 
	Vector2i(0, 1), 
	Vector2i(1, 1),
];

var _expected_type: Enums.TileType = Enums.TileType.VOID;
var _last_pos: Vector2i;


#Marking the Tiles Clockwise beginning at T.
#   T
#L     R
#   B
var _atlas_neighbour_dict := {
	[false, false, true, false]: Vector2i(0, 0), 	#OUTER CORNER BL
	[false, true, false, true]: Vector2i(1, 0), 	#BORDER RIGHT SIDE
	[true, false, true, true]: Vector2i(2, 0), 		#INNER CORNER BL
	[false, false, true, true]: Vector2i(3, 0), 	#BORDER BOTTOM SIDE
	
	[true, false, false, true]: Vector2i(0, 1), 	#EDGE CONNECTOR TL BR
	[false, true, true, true]: Vector2i(1, 1), 		#INNER CORNER BR
	[true, true, true, true]: Vector2i(2, 1), 		#FILL OVERLAY
	[true, true, true, false]: Vector2i(3, 1), 		#INNER CORNER TL
	
	[false, true, false, false]: Vector2i(0, 2), 	#OUTER CORNER TR
	[true, true, false, false]: Vector2i(1, 2), 	#BORDER TOP SIDE
	[true, true, false, true]: Vector2i(2, 2), 		#INNER CORNER TR
	[true, false, true, false]: Vector2i(3, 2), 	#BORDER LEFT SIDE
	
	[false, false, false, false]: Vector2i(0, 3), 	#FILL UNDERLAY
	[false, false, false, true]: Vector2i(1, 3), 	#OUTER CORNER RB
	[false, true, true, false]: Vector2i(2, 3), 	#EDGE CONNECTOR TR BL
	[true, false, false, false]: Vector2i(3, 3), 	#OUTER CORNER TL
}

@onready var data_layer: TileMapLayer = %data_layer;
@onready var ground_layer: TileMapLayer = %ground_layer;
@onready var ground_overlay: TileMapLayer = %ground_overlay;


func _ready() -> void:
	MapManager.map_manager = self;
	MapManager.is_in_animated_scene = false;
	MapManager.set_selected_tile(0);


func mouse_to_map() -> Vector2i:
	return data_layer.local_to_map(get_global_mouse_position());


func set_tile() -> void:
	var map_pos := mouse_to_map();
	
	if map_pos == _last_pos:
		return;
		
	_last_pos = map_pos;
	
	#In this solution we implement our own logic so we don't need to care for getting the right source id etc.
	_expected_type = MapManager.selected_tile.tile_type;
	print("expected type:" + str(_expected_type))
	data_layer.set_cell(map_pos, 0, MapManager.selected_tile.data_layer_coord); #data layer only uses one source id
	
	_set_visual_layer(map_pos, 
		MapManager.selected_tile.ground_tile_atlas_coord,
	 	MapManager.selected_tile.ground_tile_source_id, 
		MapManager.selected_tile.overlay_source_id
	);
	pass;


func _set_visual_layer(map_pos: Vector2i, ground_atlas_coords: Vector2i, ground_source_id: int, overlay_source_id: int = -1) -> void:
	for cell_neighbour: Vector2i in LOCAL_NEIGHBOUR_CELLS:
		var cell_pos := map_pos + cell_neighbour;
		ground_layer.set_cell(cell_pos, ground_source_id, ground_atlas_coords);
		
		#simulating that the user perhaps just want to set a ground tilex
		if overlay_source_id != -1:
			var target_source := overlay_source_id;			
			target_source = overlay_source_id if MapManager.selected_tile.overlay_variants.size() == 1 \
							else _get_random_position(MapManager.selected_tile.overlay_variants);

			ground_overlay.set_cell(cell_pos, target_source, _calculate_overlay_tile(cell_pos))


func _calculate_overlay_tile(coord: Vector2i) -> Vector2i:	
	var bot_right := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[0]);
	var bot_left := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[1]);
	var top_right := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[2]);
	var top_left := _calc_type(coord - LOCAL_NEIGHBOUR_CELLS[3]);

	return _atlas_neighbour_dict[[top_left, top_right, bot_left, bot_right]];


func _calc_type(coords: Vector2i) -> bool:
	var td := data_layer.get_cell_tile_data(coords);
	if !td:
		return false;
	print("[%s] found  tile type: %s - expected: %s" % [coords, td.get_custom_data("tile_type"), _expected_type])
	return td.get_custom_data("tile_type") == _expected_type;
	

func _get_random_position(target_array: Array) -> int:
	return target_array[randi() % target_array.size()]
