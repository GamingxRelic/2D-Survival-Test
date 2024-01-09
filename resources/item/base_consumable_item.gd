extends "res://resources/item/base_item.gd"
class_name ConsumableItem

@export var health_restored : int
#@export var effect

func use():
	var player_data = GameManager.player_data as PlayerData 
	player_data.health += 1
	quantity -= 1
