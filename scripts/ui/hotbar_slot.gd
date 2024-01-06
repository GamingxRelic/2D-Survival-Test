extends Control

@onready var item_rect = $Item
@onready var quantity = $Quantity

@export var res : Item

@onready var background : TextureRect = $Background

signal action_event 

func set_info(item : Item):
	
	if item == null:
		item_rect.texture = null
		quantity.text = ""
		res = null
		return
		
	res = item
	quantity.text = str(res.quantity) if res.max_quantity > 1 else ""
	item_rect.texture = res.texture

func select():
	background.self_modulate = Color("ffff8f")

func deselect():
	background.self_modulate = Color("ffffff")

func _on_gui_input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("left_click"):
			action_event.emit("left_click", self)
		elif Input.is_action_just_pressed("right_click"):
			action_event.emit("right_click", self)
