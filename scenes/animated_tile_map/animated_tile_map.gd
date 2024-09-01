class_name AnimatedTileMapDemo extends Node2D

@onready var ground_layer: TileMapLayer = %ground_layer;
@onready var animated_layer: TileMapLayer = %animated_layer;
@onready var data_layer: TileMapLayer = %data_layer;


const LOCAL_NEIGHBOUR_CELLS := [
	Vector2i(0, 0),
	Vector2i(1, 0), 
	Vector2i(0, 1), 
	Vector2i(1, 1),
];

var _atlas_neighbour_dict := {
	[false, false, true, false]: Vector2i(0, 0), # OUTER CORNER BL				#TILE ID 0
	[false, true, false, true]: Vector2i(0, 1), # BORDER RIGHT SIDE				#TILE ID 1
	[true, false, true, true]: Vector2i(0, 2), # INNER CORNER BL				#TILE ID 2
	[false, false, true, true]: Vector2i(0, 3), # BORDER BOTTOM SIDE			#TILE ID 3
	
	[true, false, false, true]: Vector2i(0,4), # EDGE CONNECTOR TL BR			#TILE ID 4
	[false, true, true, true]: Vector2i(0,5), # INNER CORNER BR				#TILE ID 5
	[true, true, true, true]: Vector2i(0,6), # FILL OVERLAY					#TILE ID 6
	[true, true, true, false]: Vector2i(0,7), # INNER CORNER TL				#TILE ID 7
	
	[false, true, false, false]: Vector2i(3,0), # OUTER CORNER TR				#TILE ID 8
	[true, true, false, false]: Vector2i(3,1), # BORDER TOP SIDE				#TILE ID 9
	[true, true, false, true]: Vector2i(3, 2), # INNER CORNER TR				#TILE ID 10
	[true, false, true, false]: Vector2i(3, 3), # BORDER LEFT SIDE				#TILE ID 11
	
	[false, false, false, false]: Vector2i(3, 7), #!!!!! # FILL UNDERLAY				#TILE ID 12
	[false, false, false, true]: Vector2i(3, 4), # OUTER CORNER RB				#TILE ID 13
	[false, true, true, false]: Vector2i(3, 5), # EDGE CONNECTOR TR BL			#TILE ID 14
	[true, false, false, false]: Vector2i(3, 6), # OUTER CORNER TL				#TILE ID 15	
}


var _expected_type:= Vector2i.ZERO;
var _last_pos: Vector2i;
const TILE_SIZE := 128;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MapManager.map_manager = self;
	MapManager.is_in_animated_scene = true;
	MapManager.set_selected_tile(2)
	pass # Replace with function body.


func mouse_to_map() -> Vector2i:
	return data_layer.local_to_map(get_global_mouse_position());


func set_tile() -> void:
	var map_pos = mouse_to_map();
	
	if map_pos == _last_pos:
		return;
		
	_last_pos = map_pos;

	_expected_type = MapManager.selected_tile.ground_type;
	data_layer.set_cell(map_pos, 0, MapManager.selected_tile.ground_tile_atlas_coord); #data layer only uses one source id
	
	_set_visual_layer(map_pos, MapManager.selected_tile.ground_tile_atlas_coord, MapManager.selected_tile.ground_tile_source_id, MapManager.selected_tile.overlay_source_id);
	pass;


func _set_visual_layer(map_pos: Vector2i, ground_atlas_coords: Vector2i, ground_source_id: int, overlay_source_id: int = -1) -> void:
	for cell_neighbour: Vector2i in LOCAL_NEIGHBOUR_CELLS:
		var cell_pos := map_pos + cell_neighbour;
		ground_layer.set_cell(cell_pos, ground_source_id, ground_atlas_coords);
		
		#simulating that the user perhaps just want to set a ground tilex
		if overlay_source_id != -1 and MapManager.selected_tile.overlay_variants.size() > 0:
			animated_layer.set_cell(cell_pos, overlay_source_id, _calculate_overlay_tile(cell_pos))


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
