class_name SelectedTileData extends Resource


@export var overlay_source_id: int = -1;
@export var overlay_variants: Array[int] = [];
@export var ground_tile_source_id: int = -1;
@export var ground_tile_id: int = -1;
@export var ground_tile_atlas_coord : Vector2i= Vector2i.ZERO
@export var ground_type : Vector2i = Vector2i.ZERO
@export var is_animated_tile: bool = false;
@export var animated_tile_counter := 0;
@export var animated_tile_frames: Array[int] = [];
