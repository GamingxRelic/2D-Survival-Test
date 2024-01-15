extends Node2D
class_name DropHandler

# TODO: This should include a quantity value as well, not just what the drop is. 
@export var loot_table : Dictionary 

@export var drop_count : Vector2i = Vector2i(1,1) # Values are Min, Max drop count.
var item_spawn_range : Vector2
var x_radius : Vector2 # Min x, max x
var y_radius : Vector2 # Min y, max y


func set_ranges(x, y):
	item_spawn_range = Vector2(x,y)
	
func set_radius(x : Vector2, y : Vector2):
	x_radius = x
	y_radius = y

func drop_items():
	var item_count : int = randi_range(drop_count.x, drop_count.y)
	
	for i in item_count:
		var random_number = randi() % 100 + 1
		
		for key in loot_table.keys():
			if random_number <= loot_table[key]:
				randomize()
				# Spawn items anywhere horizontally within the resource node
				var x = randf_range(-item_spawn_range.x, item_spawn_range.x)
				# Spawn items anywhere vertically within the resource node
				var y = randf_range(0, item_spawn_range.y) * -1
				
				var item = preload("res://scenes/item.tscn").instantiate()
				item.res = key.duplicate()
				item.global_position = global_position + Vector2(x, y)
				
				
				var rad_x = randf_range(x_radius.x, x_radius.y)
				var rad_y = randf_range(y_radius.x, y_radius.y)
				item.central_impulse_amount = Vector2(rad_x, rad_y)
				
				GameManager.entities.call_deferred("add_child", item)
#queue_free()
