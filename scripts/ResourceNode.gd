extends StaticBody2D

var broken := false
@export var item_id : String

@export var hp : int

var item_spawn_range_x : float
var item_spawn_range_y : float

@export var item_push_radius_x : Vector2 = Vector2(-250, 250)
@export var item_push_radius_y : Vector2 = Vector2(-500, 0)

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
		drop_handler.set_radius(item_push_radius_x, item_push_radius_y)
		
		drop_handler.drop_items()
		
		hide()
		await $Audio.finished
		queue_free()


