extends Node #MapManager

var selected_tile: SelectedTileData;
const TILE_SIZE := 128;
var _tile_dict := {} #[id: int]: SelectedTileData;


var active_map;
var is_in_animated_scene: bool;

func _init():
	_tile_dict[0] = _init_tile_data(0,  [0, 1, 2], 0, Vector2i.ZERO, Enums.TileType.DIRT, Vector2i.ZERO);
	_tile_dict[1] = _init_tile_data(3,  [3], 1, Vector2i(1,0), Enums.TileType.GRASS, Vector2i(1,0));	
	 #this will only draw ground since the data at Vector2i.ZERO in DataLayer are not of type VOID.
	_tile_dict[2] = _init_tile_data(0,  [0, 1, 2], 0, Vector2i.ZERO, Enums.TileType.VOID, Vector2i.ZERO);
	 # wild mix between all overlays
	_tile_dict[3] = _init_tile_data(3,  [0, 3, 2, 1, 5, 4], 0, Vector2i.ZERO, Enums.TileType.DIRT, Vector2i.ZERO);
	 #animated map
	_tile_dict[9] = _init_tile_data(0,  [0], 0, Vector2i.ZERO, Enums.TileType.DIRT, Vector2i.ZERO);


func set_tile():
	active_map.set_tile();

func set_selected_tile(id: int):
	selected_tile = _tile_dict.get(id, 0);

func toggle_ground_layer_source():
	selected_tile.ground_tile_source_id = 1 if selected_tile.ground_tile_source_id == 0 else 1;

func toggle_ground_tile_id():
	selected_tile.ground_tile_atlas_coord = Vector2i.ZERO if selected_tile.ground_tile_atlas_coord == Vector2i(1,0) else Vector2i(1,0);



func _init_tile_data(overlay_source_id: int, overlay_variants: Array[int], ground_tile_source: int, 
				ground_tile_atlas_coord: Vector2i, tile_type: Enums.TileType, data_layer_coord: Vector2i) -> SelectedTileData:
	var data := SelectedTileData.new();
	data.overlay_source_id = overlay_source_id;
	data.overlay_variants = overlay_variants;
	data.ground_tile_source_id = ground_tile_source;
	data.ground_tile_atlas_coord = ground_tile_atlas_coord;
	data.tile_type = tile_type;
	data.data_layer_coord = data_layer_coord;
	return data;
