extends StaticBody2D

func _on_sprite_2d_gui_input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("left_click"):
			$InventoryUI.open()
			InventoryManager.open_player_inventory.emit()
