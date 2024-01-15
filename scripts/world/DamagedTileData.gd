class_name DamagedTileData
extends Node

@export var pos : Vector2i
var damage_sound : String
var break_sound : String
var max_health : float :
	set(value):
		max_health = value
		health = value
	get:
		return max_health
var health : float :
	set(value):
		health = value
		if health <= 0:
			destroyTile.emit(pos)
			GameManager.play_sound_at_pos(SoundList.tile_break[break_sound], GameManager.tilemap.map_to_local(pos)) # TEMP
			queue_free()
var heal_time : float
var heal_amount : float
@onready var heal_timer : Timer = $HealTimer
signal destroyTile
signal healed

func set_data(data : TileData, position : Vector2i):
	pos = position
	name = str(pos)
	max_health = data.get_custom_data("health")
	
	# This will only set the heal time to the tile's heal time if it is not 0.0, otherwise it will default to 1.0.
	# This makes it so the same heal time doesn't have to be set for every single tile, just for cases where the heal time is changed.
	var data_heal_time : float = data.get_custom_data("heal_time")
	heal_time = data_heal_time if data_heal_time > 0 else 5.0
	
	# Same thing but for heal amount
	var data_heal_amount : float = data.get_custom_data("heal_amount")
	heal_amount = data_heal_amount if data_heal_amount > 0 else 1.0
	
	damage_sound = data.get_custom_data("damage_sound") if data.get_custom_data("damage_sound") != "" else "stone_1"
	break_sound = data.get_custom_data("break_sound") if data.get_custom_data("break_sound") != "" else "stone"
	
	#await ready
	#heal_timer.wait_time = heal_time
	
func damage(value : float):
	if heal_timer == null:
		await ready
	if !heal_timer.is_stopped():
		heal_timer.stop()
	health -= value
	GameManager.play_sound_at_pos(SoundList.tile_damage[damage_sound], GameManager.tilemap.map_to_local(pos)) # TEMP
	heal_timer.start(heal_time)

func heal(value : float):
	health += value
	if health >= max_health:
		heal_timer.stop()
		healed.emit(pos)
		queue_free()

func _on_heal_timer_timeout():
	heal(heal_amount)
	
	
