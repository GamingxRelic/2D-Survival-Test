extends Control

@onready var item_rect = $Item
@onready var quantity = $Quantity

@export var res : Item

@onready var background : TextureRect = $Background
var selected := false

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
	
	if res != null and selected and res.tag_tool:
		GameManager.player_data.weapon_cooldown = res.cooldown / res.mining_speed

func select():
	selected = true
	background.self_modulate = Color("ffff8f")
	if res != null and res.tag_tool:
		GameManager.player_data.weapon_cooldown = res.cooldown

func deselect():
	selected = false
	background.self_modulate = Color("ffffff")

func _on_gui_input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("left_click"):
			action_event.emit("left_click", self)
		elif Input.is_action_just_pressed("right_click"):
			action_event.emit("right_click", self)

func _on_mouse_entered():
	UIManager.mouse_over_ui = true

func _on_mouse_exited():
	UIManager.mouse_over_ui = false
