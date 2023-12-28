extends Resource
class_name Item

@export var name : String
@export var id : String
@export_enum("MATERIAL", "EQUIPABLE", "CONSUMABLE") var type : String
@export_enum("BLOCK", "EDIBLE") var consumable_type : String
@export var color : Color
@export var quantity : int = 1
@export var max_quantity : int = 999

