extends TileMap

enum resources {
	ROCK = 1,
	TREE = 2
}

@export var world_x := 128
@export var world_y := 128

var noise = FastNoiseLite.new()
var unit := 16

signal resource_generation_finished

var tiles = TileList.tile
var tile_data : Dictionary

func _ready() -> void:
	GameManager.tilemap = self
	GameManager.spawn_resources.connect(_on_spawn_resources)
	GameManager.damage_tile.connect(damage_tile)
	GameManager.place_tile.connect(place_tile)
	
	randomize()
	noise.seed = randi()%1000
	
	for x in world_x:
		var ground = abs(noise.get_noise_2d(x, 20) * 30)
		
		for y in range(ground, 15):
			if noise.get_noise_2d(x,y) > -0.33: 
				
				# TODO:
				# Add nicer grass spawning so grass covers edges. 
				
				if get_cell_tile_data(0, Vector2i(x, y-1)) == null:
					set_cell(0, Vector2i(x,y), 0, tiles["GRASS_" + str(randi_range(1,3))], 0)
				else:
					set_cell(0, Vector2i(x,y), 0, tiles["DIRT_" + str(randi_range(1,3))], 0)

		for y in range(15, 40):
			if noise.get_noise_2d(x,y) > -0.33: 
				if get_cell_tile_data(0, Vector2i(x, y-1)) == null:
					set_cell(0, Vector2i(x,y), 0, tiles["GRASS_" + str(randi_range(1,3))], 0)
				else:
					set_cell(0, Vector2i(x,y), 0,tiles["DIRT_" + str(randi_range(1,3))], 0)

		for y in range(40, world_y):
			if noise.get_noise_2d(x,y) > -0.33: 
				set_cell(0, Vector2i(x,y), 0, tiles["STONE_" + str(randi_range(1,3))], 0)
	
	find_world_spawn_point()
	update_tile_data()
	#tile_data[1].resize(tile_data[0].size())
	
func _on_spawn_resources():
	for x in world_x:
		var ground = abs(noise.get_noise_2d(x, 20) * 30)
		
		for y in range(ground, 15):
			if GameManager.resource_nodes.get_child_count() >= GameManager.max_resource_nodes:
				return
			
			if noise.get_noise_2d(x,y) > -0.33: 
				
				# Spawn Rock
				if (randi()%100+1 <= 20 and
					get_cell_tile_data(0, Vector2i(x, y)) != null and
					!check_collision(0, Vector2i(x,y), 2, 2) #and
					#!await check_body_collision(Vector2i(x, y), 5*unit, 3*unit)
				):
					var rock = preload("res://scenes/resource_nodes/rock.tscn").instantiate()
					rock.global_position = to_global(map_to_local(Vector2i(x, y-1)))
					rock.global_position.y += 8
					GameManager.resource_nodes.add_child(rock)#call_deferred("add_child", rock)
				
				# Spawn Tree
				elif (randi()%100+1 <= 30 and 
					get_cell_tile_data(0, Vector2i(x, y)) != null and
					!check_collision(0, Vector2i(x,y), 2, 9) #and
					#!await check_body_collision(Vector2i(x, y), 5*unit, 12*unit)
				):
					var tree = preload("res://scenes/resource_nodes/tree.tscn").instantiate()
					tree.global_position = to_global(map_to_local(Vector2i(x, y-1)))
					tree.global_position.y += 8
					GameManager.resource_nodes.add_child(tree)#call_deferred("add_child", tree)

	resource_generation_finished.emit()

# Array of body collisions. If there are any values in it, that means there was a collision.
var collision_count : Array[bool] = []
func check_collision(layer : int, tile_pos : Vector2i, x_range : int, y_range : int):
	var result := false
	
	for x in range(-x_range, x_range+1):
		for y in range(1, y_range+1):
			var target_pos = tile_pos + Vector2i(x,-y)
			#check_body_collision(target_pos)
			if get_cell_tile_data(layer, target_pos) != null or collision_count.size() > 0:
				collision_count.clear()
				result = true
				break
	
	# Check the distance of new object to the most recently added resource node 
	if !result and GameManager.resource_nodes.get_child_count()>0:
			var prev_node = GameManager.resource_nodes.get_child(GameManager.resource_nodes.get_child_count()-1)
			var prev_node_pos = prev_node.global_position
			if map_to_local(tile_pos).distance_to(prev_node_pos) < (x_range+2)*unit:
				result = true
	
	return result

func find_world_spawn_point():
	var center_x : int = floori(world_x / 2.0)
	var tile_pos : Vector2i = Vector2i(center_x, -1)
	
	# This needs to check if there is enough room for the player, who is 2x3 blocks in size. 
	
	while true:
		if get_cell_tile_data(0, tile_pos) == null:
			tile_pos.y += 1
		else:
			tile_pos.y -= 1
			break
	
	GameManager.world_spawn = map_to_local(tile_pos)

func damage_tile(pos : Vector2, damage : float):
	var cell_coords : Vector2i = local_to_map(pos)
	var data = get_cell_tile_data(0, cell_coords)
	
	if data != null:
		
		if tile_data[str(cell_coords)] == null:
			var damaged_tile = preload("res://scenes/world/damaged_tile_data.tscn").instantiate()
			damaged_tile.set_data(data, cell_coords)
			GameManager.damaged_tiles_data.add_child(damaged_tile)
			damaged_tile.healed.connect(_on_tile_healed)
			damaged_tile.destroyTile.connect(_on_tile_destroy)
			damaged_tile.damage(damage)
			#tile_data[1][index] = damaged_tile
			tile_data[str(cell_coords)] = damaged_tile
		else:
			#tile_data[1][index].damage(damage)
			tile_data[str(cell_coords)].damage(damage)

func _on_tile_healed(pos : Vector2i):
	tile_data[str(pos)] = null
	

func _on_tile_destroy(pos : Vector2i):
	break_tile(pos)
	#update_tile_data()

func break_tile(pos : Vector2i):
	var data = get_cell_tile_data(0, pos)
	if data != null:
		var drop_handler = preload("res://scenes/components/drop_handler.tscn").instantiate()
		drop_handler.loot_table = data.get_custom_data("loot_table")
		drop_handler.drop_count = data.get_custom_data("drop_count")
		drop_handler.set_ranges(6, 6) 
		drop_handler.set_radius(Vector2(-50, 50), Vector2(-100, 0))
		drop_handler.global_position = map_to_local(pos)
		GameManager.item_entities.add_child(drop_handler)
		drop_handler.drop_items()
		
		GameManager.tilemap.set_cell(0, pos)
		tile_data.erase(str(pos))
		
func place_tile(pos : Vector2, tile_atlas_index : Vector2):
	var cell_coords := GameManager.tilemap.local_to_map(pos)
	if GameManager.tilemap.get_cell_tile_data(0, cell_coords) == null:
			GameManager.tilemap.set_cell(0, cell_coords, 0, tile_atlas_index)
			if !tile_data.has(str(cell_coords)):
				tile_data[str(cell_coords)] = null

func check_tile(pos : Vector2):
	var cell_coords : Vector2i = local_to_map(pos)
	var data = get_cell_tile_data(0, cell_coords)
	return data

func update_tile_data():
	#tile_data[0] = get_used_cells(0)
	#tile_data[1].resize(tile_data[0].size())
	for cell in get_used_cells(0):
		if !tile_data.has(str(cell)):
			tile_data[str(cell)] = null
			
