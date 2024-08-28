extends AnimatedSprite2D

@onready var wang_poc: WangPoc = $"..";

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
		wang_poc.set_tile(wang_poc.mouse_to_local(), selected_ground_tile, selected_ground_tile_source, selected_ground_overlay_source);
	

	#let's assume this is the user selecting a button in the builder menu
	
	#this is for switching between tile sources
	if Input.is_action_just_released("change_ground_type"): #KEY_X
		selected_ground_tile_source = 0 if selected_ground_tile_source == 1 else 1;
		print("selected_ground_source: %s" % selected_ground_tile_source)
		
	if Input.is_action_just_released("change_ground_overlay_type"): #KEY C
		selected_ground_overlay_source = 0 if selected_ground_overlay_source == 1 else 1;
		print("selected_overlay_source: %s" % selected_ground_overlay_source)
	
	
	if Input.is_action_just_released("change_ground_tile"): #KEY V
		selected_ground_tile = Vector2i.ZERO if selected_ground_tile == Vector2i(1,0) else Vector2i(1,0);
		print("selected_ground_tile: %s" % selected_ground_tile)
	




func _physics_process(_delta: float) -> void:
	global_position = get_world_pos_tile() + Vector2(WangPoc.TILE_SIZE / 2, WangPoc.TILE_SIZE / 2);

func get_world_pos_tile()-> Vector2:
	var mouse_pos := get_global_mouse_position()
	return Vector2(get_floor_dimension_value(mouse_pos.x), get_floor_dimension_value(mouse_pos.y));

func get_floor_dimension_value(value: int) -> int:
	return floori(value / WangPoc.TILE_SIZE) * WangPoc.TILE_SIZE;
