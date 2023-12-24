extends CanvasLayer

var stone_count_label : Label
var wood_count_label : Label
var dirt_count_label : Label

func _ready() -> void:
	# Labels
	stone_count_label = $ResourceCouners/Stone/Label
	wood_count_label = $ResourceCouners/Wood/Label
	dirt_count_label = $ResourceCouners/Dirt/Label
	
	# Signals
	InventoryManager.stone_count_changed.connect(_on_stone_count_changed)
	InventoryManager.wood_count_changed.connect(_on_wood_count_changed)
	InventoryManager.dirt_count_changed.connect(_on_dirt_count_changed)

func _on_stone_count_changed():
	stone_count_label.text = str(InventoryManager.stone_count) + " Stone"
	
func _on_wood_count_changed():
	wood_count_label.text = str(InventoryManager.wood_count) + " Wood"
	
func _on_dirt_count_changed():
	dirt_count_label.text = str(InventoryManager.dirt_count) + " Dirt"
