extends Control

@onready var item_rect = $Item
@onready var quantity = $Quantity

@export var res : Item

signal action_event 
signal mouse_entered_slot
signal mouse_exited_slot

func set_info(item : Item):
	
	if item == null:
		item_rect.texture = null
		quantity.text = ""
		res = null
		return
		
	res = item
	quantity.text = str(res.quantity) if res.max_quantity > 1 else ""
	item_rect.texture = res.texture

#func update_slot():
	#quantity.text = str(res.quantity)
	##item_rect.texture = res.texture


func _on_gui_input(event):
	if event is InputEvent:
		if Input.is_key_label_pressed(KEY_SHIFT) and Input.is_action_just_pressed("left_click"):
			action_event.emit("shift_left_click", self)
		elif Input.is_action_just_pressed("left_click"):
			action_event.emit("left_click", self)
		elif Input.is_action_just_pressed("right_click"):
			action_event.emit("right_click", self)

func _on_mouse_entered():
	GameManager.mouse_over_ui = true
	mouse_entered_slot.emit(self)

func _on_mouse_exited():
	GameManager.mouse_over_ui = false
	mouse_exited_slot.emit(self)
