extends Control

@onready var item_rect = $Item
@onready var quantity = $Quantity
var visible_quantity : int = 0

@export var res : Item

func _ready() -> void:
	global_position = get_global_mouse_position() - Vector2(27,27)

func _process(_delta) -> void:
	global_position = get_global_mouse_position() - Vector2(27,27)

func update_quantity() -> void:
	quantity.text = str(res.quantity)
	
func set_visible_quantity(value : int) -> void:
	visible_quantity = value
	quantity.text = str(value)
	
func set_quantity_to_visible_quantity() -> void:
	res.quantity = visible_quantity
	update_quantity()

func set_info(item : Item) -> void:
	if item == null:
		item_rect.texture = null
		quantity.text = ""
		res = null
		return
		
	res = item
	quantity.text = str(res.quantity) if res.max_quantity > 1 else ""
	item_rect.texture = res.texture
	
