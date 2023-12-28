extends Node2D

@export var drops : Dictionary
@export var min_drop_count : int = 1
@export var max_drop_count : int = 1
var x_range : float
var y_range : float

func set_ranges(x, y):
	x_range = x
	y_range = y

func drop_items():
	var item_count : int = randi_range(min_drop_count, max_drop_count)
	
	for i in item_count:
		var random_number = randi() % 100 + 1
		
		for key in drops.keys():
			if random_number <= drops[key]:
				randomize()
				# Spawn items anywhere horizontally within the resource node
				var x = randf_range(-x_range, x_range)
				# Spawn items anywhere vertically within the resource node
				var y = randf_range(0, y_range) * -1
				
				var item = preload("res://scenes/item.tscn").instantiate()
				item.res = key.duplicate()
				item.global_position = global_position + Vector2(x, y)
				
				var radius_x = randf_range(-250, 250)
				var radius_y = randf_range(-500, 0)
				item.apply_central_impulse(Vector2(radius_x, radius_y))
				
				GameManager.entities.call_deferred("add_child", item)
