extends Node

var debug := false

var level
var entities
var tilemap : TileMap 
var player_pos : Vector2

var luck : float = 0.0

signal spawn_resources

func break_block(pos : Vector2):
	var cell_coords := GameManager.tilemap.local_to_map(pos)
	var data = GameManager.tilemap.get_cell_tile_data(0, cell_coords)
	if data != null:
		var item = preload("res://scenes/item.tscn").instantiate()
		item.global_position = GameManager.tilemap.map_to_local(cell_coords)
		item.global_position += Vector2(randf_range(-8,8), randf_range(-8,8))
		item.res = data.get_custom_data("material")
		
		# Give the item an impulse when it spawns to make it look like it shot out the block
		var radius_x = randf_range(-50, 50)
		var radius_y = randf_range(-100, 0)
		item.apply_central_impulse(Vector2(radius_x, radius_y))
		
		GameManager.entities.call_deferred("add_child", item)
		GameManager.tilemap.set_cell(0, cell_coords)
