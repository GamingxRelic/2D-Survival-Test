extends Resource
class_name Item

@export var name : String
@export var id : String
@export_enum("MATERIAL", "EQUIPABLE", "CONSUMABLE") var type : String
@export_enum("BLOCK", "EDIBLE") var consumable_type : String
@export var texture : Texture
@export var quantity : int = 1
@export var max_quantity : int = 999

func combine(add_quantity : int) -> int:
	if quantity + add_quantity < max_quantity:
		quantity += add_quantity
		return 0
	
	var difference := max_quantity - quantity
	quantity = max_quantity
	add_quantity -= difference
	return add_quantity
	
