extends Resource
class_name Item

@export var name : String
@export var id : String
@export_enum("MATERIAL", "EQUIPABLE", "CONSUMABLE") var type : String
@export var color : Color
@export var max_count : int

