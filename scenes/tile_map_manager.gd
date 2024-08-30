class_name TileMapManager extends Node2D

const LOCAL_NEIGHBOUR_CELLS := [
	Vector2i(0, 0),
	Vector2i(1, 0), 
	Vector2i(0, 1), 
	Vector2i(1, 1),
];

@export var selected_tile_data: SelectedTileData;
@export var shader_material: ShaderMaterial
var _expected_type:= Vector2i.ZERO;
var _last_pos: Vector2i;

#var _alternatives := {
	##0: [0, 1, 2],
	##1: [3, 4, 5]
	#0: [6],
	#1: [6]
#}

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

@onready var data_layer: TileMapLayer = %data_layer;
@onready var ground_layer: TileMapLayer = %ground_layer;
@onready var ground_overlay: TileMapLayer = %ground_overlay;

var current_animated_tiles := {}; #overlay_source_id: SelectedTileData
var time_passed: float = 0.0
var animation_speed: float = 1.0 # Geschwindigkeit der Animation
var frame_interval: float = 0.3 # Zeit in Sekunden zwischen den Frames (anpassbar)
var frame_timer: float = 0.0

func _ready() -> void:
	pass;

#var delta_counter +=
func _process(delta: float) -> void:
	frame_timer += delta
	
	if frame_timer >= frame_interval:
		# Setze den Timer zurück und aktualisiere time_passed
		frame_timer = 0.0
		time_passed += 1
		if time_passed >= 4: # Anpassen, falls mehr oder weniger Frames vorhanden sind
			time_passed = 0

		# Iteriere über alle Tiles und aktualisiere animierte Tiles
		for position in ground_overlay.get_used_cells():
			var tile_data: SelectedTileData = get_tile_data(position)
			if tile_data and tile_data.is_animated_tile:
				update_tile_animation(position, tile_data, time_passed)
	
	
			
func get_tile_data(position: Vector2):
	# Hier würde die Logik stehen, um die spezifischen Tile-Daten für eine Position abzurufen
	# Zum Beispiel könnte man das Tile-Daten Resource aus einer Datenbank oder einem Dictionary laden
	return current_animated_tiles.get(selected_tile_data.ground_tile_source_id, null)

func update_tile_animation(position: Vector2i, tile_data: SelectedTileData, time_passed):
	tile_data.animated_tile_counter += 1
	var frame_index = tile_data.animated_tile_counter % tile_data.animated_tile_frames.size()
	var current_frame = tile_data.animated_tile_frames[frame_index]

	# Debug-Output
	#print("Updating Tile at Position:", position, "with Frame:", current_frame)

	# Update das Tile in der TileMap
	#ground_overlay.set_cell(position, current_frame)

	# Setze die Source ID im Shader
	shader_material.set_shader_parameter("source_id", tile_data.animated_tile_frames[frame_index])
	shader_material.set_shader_parameter("time", frame_index)




func mouse_to_map() -> Vector2i:
	return data_layer.local_to_map(get_global_mouse_position());

func set_selected_tile(tile_data: SelectedTileData):
	selected_tile_data = tile_data;
	if tile_data.is_animated_tile:
		current_animated_tiles[tile_data.overlay_source_id] = tile_data;

func set_tile(map_pos: Vector2i) -> void:
	if map_pos == _last_pos:
		return;
		
	_last_pos = map_pos;
	
	#for simplicity, the expected type is handled by ground_type_atlas_coords. 
	#you should use a custom logic for this in production
	#e.g. set expected ground type in mouse controller and change the custom_data "ground_type" in data layer at pos x,y 
	_expected_type = selected_tile_data.ground_type;
	data_layer.set_cell(map_pos, 0, selected_tile_data.ground_tile_atlas_coord); #data layer only uses one source id
	
	_set_visual_layer(map_pos, selected_tile_data.ground_tile_atlas_coord, selected_tile_data.ground_tile_source_id, selected_tile_data.overlay_source_id);
	pass;


func _set_visual_layer(map_pos: Vector2i, ground_atlas_coords: Vector2i, ground_source_id: int, overlay_source_id: int = -1) -> void:
	for cell_neighbour: Vector2i in LOCAL_NEIGHBOUR_CELLS:
		var cell_pos := map_pos + cell_neighbour;
		ground_layer.set_cell(cell_pos, ground_source_id, ground_atlas_coords);
		
		#simulating that the user perhaps just want to set a ground tilex
		if overlay_source_id != -1:
			var target_source := 0
			target_source = _get_random_position(selected_tile_data.overlay_variants);

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
