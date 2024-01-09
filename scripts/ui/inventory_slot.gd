extends Control

@onready var item_rect = $Item
@onready var quantity = $Quantity

@export var res : Item

signal action_event 
signal mouse_entered_slot
signal mouse_exited_slot
signal item_empty

func set_info(item : Item):
	
	if item == null:
		item_rect.texture = null
		quantity.text = ""
		res = null
		return
		
	res = item
	if !res.empty.is_connected(_on_item_empty):
	#res.empty.disconnect(_on_item_empty)
		res.empty.connect(_on_item_empty)
	quantity.text = str(res.quantity) if res.max_quantity > 1 else ""
	item_rect.texture = res.texture

#func update_slot():
	#quantity.text = str(res.quantity)
	##item_rect.texture = res.texture

func _on_item_empty():
	item_empty.emit(self)

func _on_gui_input(event):
	if event is InputEvent:
		if Input.is_action_pressed("quick_transfer") and Input.is_action_just_pressed("left_click"):
			action_event.emit("shift_left_click", self)
		elif Input.is_action_just_pressed("left_click"):
			action_event.emit("left_click", self)
		elif Input.is_action_just_pressed("right_click"):
			action_event.emit("right_click", self)

func _on_mouse_entered():
	UIManager.mouse_over_ui = true
	mouse_entered_slot.emit(self)

func _on_mouse_exited():
	UIManager.mouse_over_ui = false
	mouse_exited_slot.emit(self)
