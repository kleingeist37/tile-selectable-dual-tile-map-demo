extends AnimatedSprite2D

@onready var wang_poc: WangPoc = $"..";

var selected_ground_overlay := 0;
var selected_ground_tile := 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	
	if Input.is_action_pressed("left_click"):
		wang_poc.set_tile(wang_poc.mouse_to_local(), Vector2i(0,0), selected_ground_tile, selected_ground_overlay);
	

	if Input.is_action_pressed("right_click"):
		wang_poc.set_tile(wang_poc.mouse_to_local(), Vector2i(1,0), selected_ground_tile, selected_ground_overlay);
	
	#let's assume this is the user selecting a button in the builder menu
	if Input.is_action_just_released("change_ground_type"):
		selected_ground_tile = 0 if selected_ground_tile == 1 else 1;
		print("selected_ground: %s" % selected_ground_overlay)
	
	if Input.is_action_just_released("change_ground_overlay_type"):
		selected_ground_overlay = 0 if selected_ground_overlay == 1 else 1;
		print("selected_overlay: %s" % selected_ground_overlay)



func _physics_process(_delta: float) -> void:
	global_position = get_world_pos_tile() + Vector2(WangPoc.TILE_SIZE / 2, WangPoc.TILE_SIZE / 2);

func get_world_pos_tile()-> Vector2:
	var mouse_pos := get_global_mouse_position()
	return Vector2(get_floor_dimension_value(mouse_pos.x), get_floor_dimension_value(mouse_pos.y));

func get_floor_dimension_value(value: int) -> int:
	return floori(value / WangPoc.TILE_SIZE) * WangPoc.TILE_SIZE;
