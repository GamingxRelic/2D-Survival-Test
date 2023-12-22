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
				set_cell(0, Vector2i(x,y), 0, Vector2i(tiles.GRASS, 0))

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
			if noise.get_noise_2d(x,y) > -0.33: 
				if randi()%20 == 0 and get_cell_tile_data(0, Vector2i(x, y-1)) == null:
					var rock = preload("res://scenes/resource_nodes/rock.tscn").instantiate()
					rock.global_position = to_global(map_to_local(Vector2i(x, y-1)))
					GameManager.entities.call_deferred("add_child", rock)
				elif randi()%20 == 2 and get_cell_tile_data(0, Vector2i(x, y-1)) == null:
					var tree = preload("res://scenes/resource_nodes/tree.tscn").instantiate()
					tree.global_position = to_global(map_to_local(Vector2i(x, y-1)))
					GameManager.entities.call_deferred("add_child", tree)
