extends AnimatedSprite2D



var selected_ground_overlay_source := 0;
var selected_ground_tile_source := 0;
var selected_ground_tile = Vector2i.ZERO;





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("left_click"):
		MapManager.set_tile();
	
		
	#let's assume this is the user selecting a button in the builder menu
	if MapManager.is_in_animated_scene:
		_check_anim_map_input();
	else:
		_check_default_map_input();



func _physics_process(_delta: float) -> void:
	global_position = _get_world_pos_tile() + Vector2(MapManager.TILE_SIZE / 2, MapManager.TILE_SIZE / 2);



func _check_default_map_input():
	if Input.is_action_just_released("toggle_ground_tile_id"): #KEY_C
		MapManager.toggle_ground_tile_id();

	if Input.is_action_just_released("toggle_ground_source_id"): #KEY_C
		MapManager.toggle_ground_layer_source();
		
	if Input.is_action_just_released("TS_0"): #KEY_1
		MapManager.set_selected_tile(0);
		
	if Input.is_action_just_released("TS_1"): #KEY_2
		MapManager.set_selected_tile(1);

func _check_anim_map_input():
	if Input.is_action_just_released("TS_2"): #KEY_3 
		MapManager.set_selected_tile(2);
		


func _get_world_pos_tile()-> Vector2:
	var mouse_pos := get_global_mouse_position()
	return Vector2(_adjust_dimension_to_world_offset(mouse_pos.x), _adjust_dimension_to_world_offset(mouse_pos.y));

func _adjust_dimension_to_world_offset(value: int) -> int:
	return floori(value / MapManager.TILE_SIZE) * MapManager.TILE_SIZE;
