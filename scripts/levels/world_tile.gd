extends TileMap

enum tiles {
	DIRT = 0,
	GRASS = 1,
	STONE = 2
}

enum resources {
	ROCK = 1,
	TREE = 2
}

@export var world_x := 128
@export var world_y := 128

var noise
var unit := 16

signal resource_generation_finished

func _ready() -> void:
	
	GameManager.tilemap = self
	GameManager.spawn_resources.connect(_on_spawn_resources)
	$Noise.texture.width = world_x
	$Noise.texture.height = world_y
	
	noise = $Noise.texture.noise
	randomize()
	noise.seed = randi()%1000
	
	for x in world_x:
		var ground = abs(noise.get_noise_2d(x, 20) * 30)
		
		for y in range(ground, 15):
			if noise.get_noise_2d(x,y) > -0.33: 
				if get_cell_tile_data(0, Vector2i(x, y-1)) == null:
					set_cell(0, Vector2i(x,y), 0, Vector2i(tiles.GRASS, 0))
				else:
					set_cell(0, Vector2i(x,y), 0, Vector2i(tiles.DIRT, 0))

		for y in range(15, 40):
			if noise.get_noise_2d(x,y) > -0.33: 
				set_cell(0, Vector2i(x,y), 0, Vector2i(tiles.DIRT, 0))

		for y in range(40, world_y):
			if noise.get_noise_2d(x,y) > -0.33: 
				set_cell(0, Vector2i(x,y), 0, Vector2i(tiles.STONE, 0))
	
			
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


