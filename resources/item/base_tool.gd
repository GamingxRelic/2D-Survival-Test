extends "res://resources/item/base_item.gd"
class_name ToolItem

@export var mining_level : int = 1
@export var mining_speed : float = 1
@export var cooldown : float = 0.25  # This may need to be clamped in the future if problems arise. We shall see.

func primary_action():
	if !UIManager.mouse_over_ui:
		var tile_damage : float = mining_level
		GameManager.damage_tile.emit(GameManager.mouse_pos, tile_damage)

func secondary_action():
	pass
