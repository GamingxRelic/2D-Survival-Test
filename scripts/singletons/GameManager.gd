extends Node

var debug := false

var requested_scene = "res://scenes/levels/TestLevel.tscn"

var level
var entities
var resource_nodes
var item_entities
var damaged_tiles_data
var sounds
var max_resource_nodes := 100

var tilemap : TileMap 
var world_spawn : Vector2

var player_pos : Vector2
var player_facing : int = 1
var player_data : PlayerData 
var mouse_pos : Vector2

var luck : float = 0.0

var colors : Dictionary = {
	"BROKEN" : Color("939393"),
	"COMMON" : Color("f7f7f7"),
	"UNCOMMON" : Color("3bcc3f"),
	"RARE" : Color("0c27d3"),
	"MYTHICAL" : Color("5419ea"),
	"LEGENDARY" : Color("f0f736")
}

signal spawn_resources

var damaged_tiles : Dictionary
func damage_tile(pos : Vector2, damage : float):
	var cell_coords : Vector2i = tilemap.local_to_map(pos)
	var data = tilemap.get_cell_tile_data(0, cell_coords)
	
	if data != null:
		if !damaged_tiles.has(str(cell_coords)):
			var damaged_tile = preload("res://scenes/world/damaged_tile_data.tscn").instantiate()
			damaged_tile.set_data(data, cell_coords)
			damaged_tile.damage(damage)
			damaged_tile.healed.connect(_on_tile_healed)
			damaged_tile.destroyTile.connect(_on_tile_destroy)
			damaged_tiles_data.add_child(damaged_tile)
			damaged_tiles[str(cell_coords)] = damaged_tile
		
		elif damaged_tiles.has(str(cell_coords)):
			damaged_tiles[str(cell_coords)].damage(damage)
		

func _on_tile_healed(pos : Vector2i):
	damaged_tiles.erase(str(pos))

func _on_tile_destroy(pos : Vector2i):
	break_tile(pos)
	damaged_tiles.erase(str(pos))

func break_tile(pos : Vector2i):
	#var cell_coords : Vector2i = tilemap.local_to_map(pos)
	#var data = tilemap.get_cell_tile_data(0, cell_coords)
	var data = tilemap.get_cell_tile_data(0, pos)
	if data != null:
		var drop_handler = preload("res://scenes/components/drop_handler.tscn").instantiate()
		drop_handler.loot_table = data.get_custom_data("loot_table")
		drop_handler.drop_count = data.get_custom_data("drop_count")
		drop_handler.set_ranges(6, 6) 
		drop_handler.set_radius(Vector2(-50, 50), Vector2(-100, 0))
		drop_handler.global_position = tilemap.map_to_local(pos)
		item_entities.add_child(drop_handler)
		drop_handler.drop_items()
		
		#GameManager.tilemap.set_cell(0, cell_coords)
		GameManager.tilemap.set_cell(0, pos)
		
func place_tile(pos : Vector2, tile_atlas_index : Vector2):
	var cell_coords := GameManager.tilemap.local_to_map(pos)
	if ( #InventoryManager.stone_count > 0 and
		GameManager.tilemap.get_cell_tile_data(0, cell_coords) == null ):
			GameManager.tilemap.set_cell(0, cell_coords, 0, tile_atlas_index)
			#InventoryManager.stone_count -= 1

func check_tile(pos : Vector2):
	var cell_coords : Vector2i = tilemap.local_to_map(pos)
	var data = tilemap.get_cell_tile_data(0, cell_coords)
	return data

func play_sound_at_pos(stream : String, pos : Vector2):
	var sound_player = AudioStreamPlayer2D.new()
	sound_player.stream = load(stream)
	sound_player.global_position = pos
	sound_player.max_distance = 512
	sounds.add_child(sound_player)
	sound_player.play()
	#await get_tree().process_frame
	await sound_player.finished
	sound_player.queue_free()
