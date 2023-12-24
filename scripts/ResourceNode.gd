extends StaticBody2D

var broken := false
@export var item_id : String

@export var hp : int

var item_spawn_range_x
var item_spawn_range_y

var drop_handler

func _ready(): 
	$HealthComponent.health = hp
	drop_handler = $DropHandler
	item_spawn_range_x = $CollisionShape2D.shape.size.x / 2
	item_spawn_range_y = $CollisionShape2D.shape.size.y 
	
	add_to_group("resource")
	add_to_group("can_damage")

func damage(value):
	if !broken:
		var sound = load(SoundList.resource_hit[randi_range(1, SoundList.resource_hit.size())])
		$Audio.stream = sound
		$Audio.play()
		$HealthComponent.damage(value)

func _on_health_component_death():
	if !broken:
		broken = true
		var sound = load(SoundList.resource_break[randi_range(1, SoundList.resource_break.size())])
		$Audio.stream = sound
		$Audio.play()
		
		drop_handler.set_ranges(item_spawn_range_x, item_spawn_range_y)
		
		drop_handler.drop_items()
		#var item_amount = randi_range(min_item_drops,max_item_drops)
		#for i in item_amount:
			#randomize()
			
			## Create item scene
			#var item = preload("res://scenes/item.tscn").instantiate()
			#item.global_position = global_position
			#
			## Spawn items anywhere horizontally within the resource node
			#item.global_position.x += randf_range(-item_spawn_range_x, item_spawn_range_x) 
			#
			## Spawn items anywhere vertically within the resource node
			#item.global_position.y -= randf_range(0, item_spawn_range_y) 
			#
			#item.res = load(ItemIDs.id[item_id]).duplicate()
			#
			## Make items shoot out in a random direction from where they spawn
			#var radius_x = randf_range(-250, 250)
			#var radius_y = randf_range(-500, 0)
			#item.apply_central_impulse(Vector2(radius_x, radius_y))
			#
			#GameManager.entities.call_deferred("add_child", item)
		hide()
		await $Audio.finished
		queue_free()


