extends StaticBody2D

var broken := false
@export var item_spawn_range_x : int
@export var item_spawn_range_y : int
@export var item_id : String
@export var min_item_drops : int
@export var max_item_drops : int

@export var hp : int

func _ready(): 
	$HealthComponent.health = hp

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
		var item_amount = randi_range(min_item_drops,max_item_drops)
		for i in item_amount:
			randomize()
			var item = preload("res://scenes/item.tscn").instantiate()
			var spawn_range_x = randi_range(-item_spawn_range_x, item_spawn_range_x)
			var spawn_range_y = randi_range(-item_spawn_range_y, item_spawn_range_y)
			item.global_position = global_position
			item.global_position.x += spawn_range_x
			item.global_position.y += spawn_range_y
			item.res = load(ItemIDs.id[item_id]).duplicate()
			GameManager.entities.call_deferred("add_child", item)
		hide()
		await $Audio.finished
		queue_free()
