extends AnimatedSprite2D

@onready var tile_map_manager: TileMapManager = $"..";

var selected_ground_overlay_source := 0;
var selected_ground_tile_source := 0;
var selected_ground_tile = Vector2i.ZERO;


var tile_1: SelectedTileData;
var tile_2: SelectedTileData;
var tile_3: SelectedTileData;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_1 = _init_tile_data(0,  [0, 1, 2], 0, Vector2i.ZERO, Vector2i.ZERO);
	tile_2 =  _init_tile_data(1,  [3, 4, 5], 1, Vector2i(1,0), Vector2i(1,0));
	tile_3 = _init_tile_data(0,  [0, 1, 2], 0, Vector2i.ZERO, Vector2i.ZERO, true, [0,1,2]);
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	tile_map_manager.selected_tile_data = tile_1
	pass # Replace with function body.

func _init_tile_data(overlay_source_id: int, overlay_variants: Array[int], ground_tile_source: int, 
				ground_tile_atlas_coord: Vector2i, ground_type: Vector2i,
				is_animated_tile: bool = false,
				animated_tile_frames: Array[int] = [] ) -> SelectedTileData:
	var data := SelectedTileData.new();
	data.overlay_source_id = overlay_source_id;
	data.overlay_variants = overlay_variants;
	data.ground_tile_source_id = ground_tile_source;
	data.ground_tile_atlas_coord = ground_tile_atlas_coord;
	data.ground_type = ground_type;
	data.is_animated_tile = is_animated_tile;
	data.animated_tile_frames = animated_tile_frames;
	return data;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("left_click"):
		tile_map_manager.set_tile(tile_map_manager.mouse_to_map());
	

	
	_pseudo_ui_selection();


func _physics_process(_delta: float) -> void:
	global_position = _get_world_pos_tile() + Vector2(tile_map_manager.TILE_SIZE / 2, tile_map_manager.TILE_SIZE / 2);

#let's assume this is the user selecting a button in the builder menu
func _pseudo_ui_selection():
	#this is for switching between tile sources of ground
	if Input.is_action_just_released("change_ground_type"): #KEY_X
		tile_map_manager.set_selected_tile(tile_1);
		#selected_ground_tile_source = 0 if selected_ground_tile_source == 1 else 1;
		print("selected_ground_source: %s" % selected_ground_tile_source)
	
	#ground_overlay
	if Input.is_action_just_released("change_ground_overlay_type"): #KEY C
		tile_map_manager.set_selected_tile(tile_2);
		#selected_ground_overlay_source = 0 if selected_ground_overlay_source == 1 else 1;
		print("selected_overlay_source: %s" % selected_ground_overlay_source)
	
	#switching between tiles in ground set. the overlay is only distinguished between sources. 
	if Input.is_action_just_released("change_ground_tile"): #KEY V
		tile_map_manager.set_selected_tile(tile_3);
		#selected_ground_tile = Vector2i.ZERO if selected_ground_tile == Vector2i(1,0) else Vector2i(1,0);
		print("selected_ground_tile: %s" % selected_ground_tile)
		


func _get_world_pos_tile()-> Vector2:
	var mouse_pos := get_global_mouse_position()
	return Vector2(_adjust_dimension_to_world_offset(mouse_pos.x), _adjust_dimension_to_world_offset(mouse_pos.y));

func _adjust_dimension_to_world_offset(value: int) -> int:
	return floori(value / tile_map_manager.TILE_SIZE) * tile_map_manager.TILE_SIZE;
