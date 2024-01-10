extends Resource
class_name Item

@export var name : String
@export var id : String
@export_multiline var description : String

@export_group("Types", "tag_")
@export var tag_material : bool
@export var tag_equipable : bool
@export var tag_consumable : bool
@export var tag_placeable : bool
@export var tag_throwable : bool

@export_enum("BROKEN", "COMMON", "UNCOMMON", "RARE", "MYTHICAL", "LEGENDARY") var rarity : String = "COMMON"
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

func use() : pass; # This will be overridden in classes that inherit this.

func combine(add_quantity : int) -> int:
	if quantity + add_quantity <= max_quantity:
		quantity += add_quantity
		return 0
	
	var difference := max_quantity - quantity
	quantity = max_quantity
	return add_quantity - difference
	
