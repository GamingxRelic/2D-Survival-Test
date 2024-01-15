extends Node
class_name PlayerData

@export var health : float = 100.0 :
	set(value):
		health = clampf(value, 0, max_health)
	get:
		return health
@export var max_health : float = 100.0

@export var speed : float = 200.0
@export var sprint_speed : float = 350.0

@export var reach : float = 128.0
@export var attack_damage := 1.0
var weapon_cooldown : float

@export var inventory : InventoryBase
@export var hotbar : Array[Item]
#@export var selected_hotbar_slot : int = 0 
@export var hotbar_size : int :
	set(value):
		hotbar.resize(value)
	get:
		return hotbar.size()

func _ready():
	UIManager.hotbar_items = hotbar
	GameManager.player_data = self as PlayerData
	
