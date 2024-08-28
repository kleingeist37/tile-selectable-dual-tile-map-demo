extends AnimatedSprite2D

@onready var tile_map_manager: TileMapManager = $"..";

var selected_ground_overlay_source := 0;
var selected_ground_tile_source := 0;
var selected_ground_tile = Vector2i.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("left_click"):
		tile_map_manager.set_tile(tile_map_manager.mouse_to_map(), selected_ground_tile, selected_ground_tile_source, selected_ground_overlay_source);
	

	
	_pseudo_ui_selection();


func _physics_process(_delta: float) -> void:
	global_position = _get_world_pos_tile() + Vector2(tile_map_manager.TILE_SIZE / 2, tile_map_manager.TILE_SIZE / 2);

#let's assume this is the user selecting a button in the builder menu
func _pseudo_ui_selection():
	#this is for switching between tile sources of ground
	if Input.is_action_just_released("change_ground_type"): #KEY_X
		selected_ground_tile_source = 0 if selected_ground_tile_source == 1 else 1;
		print("selected_ground_source: %s" % selected_ground_tile_source)
	
	#ground_overlay
	if Input.is_action_just_released("change_ground_overlay_type"): #KEY C
		selected_ground_overlay_source = 0 if selected_ground_overlay_source == 1 else 1;
		print("selected_overlay_source: %s" % selected_ground_overlay_source)
	
	#switching between tiles in ground set. the overlay is only distinguished between sources. 
	if Input.is_action_just_released("change_ground_tile"): #KEY V
		selected_ground_tile = Vector2i.ZERO if selected_ground_tile == Vector2i(1,0) else Vector2i(1,0);
		print("selected_ground_tile: %s" % selected_ground_tile)
		


func _get_world_pos_tile()-> Vector2:
	var mouse_pos := get_global_mouse_position()
	return Vector2(_adjust_dimension_to_world_offset(mouse_pos.x), _adjust_dimension_to_world_offset(mouse_pos.y));

func _adjust_dimension_to_world_offset(value: int) -> int:
	return floori(value / tile_map_manager.TILE_SIZE) * tile_map_manager.TILE_SIZE;
