extends Control

@onready var item_rect = $Item
@onready var quantity = $Quantity

@export var res : Item

func _ready():
	global_position = get_global_mouse_position() - Vector2(27,27)

func _process(_delta):
	global_position = get_global_mouse_position() - Vector2(27,27)

func update_quantity():
	quantity.text = str(res.quantity)

func set_info(item : Item):
	if item == null:
		item_rect.texture = null
		quantity.text = ""
		res = null
		return
		
	res = item
	quantity.text = str(res.quantity) if res.max_quantity > 1 else ""
	item_rect.texture = res.texture
	
