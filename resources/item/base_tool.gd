extends "res://resources/item/base_item.gd"
class_name ToolItem

@export var mining_level : int = 1
@export var mining_speed : float = 1
@export var cooldown : float = 0.25

func use():
	if !UIManager.mouse_over_ui:
		var tile_damage : float = mining_level * mining_speed
		GameManager.damage_tile(GameManager.mouse_pos, tile_damage)
		print("swing!")
