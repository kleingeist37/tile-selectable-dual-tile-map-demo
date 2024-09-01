class_name SelectedTileData extends Resource


@export var overlay_source_id: int = -1;
@export var overlay_variants: Array[int] = [];
@export var ground_tile_source_id: int = -1;
@export var ground_tile_atlas_coord : Vector2i = Vector2i.ZERO;
@export var data_layer_coord: Vector2i = Vector2i.ZERO; #for demo
@export var tile_type : Enums.TileType = Enums.TileType.VOID;
