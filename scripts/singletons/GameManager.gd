extends Node

var debug := false

var requested_scene = "res://scenes/levels/TestLevel.tscn"

var level
var entities
var resource_nodes
var item_entities
var max_resource_nodes := 100
var tilemap : TileMap 

var player_pos : Vector2
var player_facing : int = 1
var player_data : PlayerData 
var mouse_over_ui := false

var luck : float = 0.0

signal spawn_resources

func break_block(pos : Vector2):
	var cell_coords : Vector2i = GameManager.tilemap.local_to_map(pos)
	var data = GameManager.tilemap.get_cell_tile_data(0, cell_coords)
	if data != null:
		var item = preload("res://scenes/item.tscn").instantiate()
		item.global_position = GameManager.tilemap.map_to_local(cell_coords)
		item.global_position += Vector2(randf_range(-8,8), randf_range(-8,8))
		item.res = data.get_custom_data("material").duplicate()
		item.res.quantity = 10
		
		# Give the item an impulse when it spawns to make it look like it shot out the block
		var radius_x = randf_range(-50, 50)
		var radius_y = randf_range(-100, 0)
		item.apply_central_impulse(Vector2(radius_x, radius_y))
		
		GameManager.item_entities.call_deferred("add_child", item)
		GameManager.tilemap.set_cell(0, cell_coords)
		
func place_block(pos : Vector2, tile_atlas_index : Vector2):
	var cell_coords := GameManager.tilemap.local_to_map(pos)
	if ( #InventoryManager.stone_count > 0 and
		GameManager.tilemap.get_cell_tile_data(0, cell_coords) == null ):
			GameManager.tilemap.set_cell(0, cell_coords, 0, tile_atlas_index)
			#InventoryManager.stone_count -= 1
