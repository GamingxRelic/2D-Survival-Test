extends Resource
class_name Item

@export var name : String
@export var id : String
@export_enum("MATERIAL", "EQUIPABLE", "CONSUMABLE", "WEAPON", "BLOCK") var type : String
#@export_enum("BLOCK", "EDIBLE") var consumable_type : String
@export var texture : Texture
@export var quantity : int = 1 :
	set(value):
		quantity = value
		if quantity == 0:
			empty.emit()
	get:
		return quantity
@export var max_quantity : int = 999

signal empty

func use():
	quantity -= 1

func combine(add_quantity : int) -> int:
	if quantity + add_quantity <= max_quantity:
		quantity += add_quantity
		return 0
	
	var difference := max_quantity - quantity
	quantity = max_quantity
	return add_quantity - difference
	
