extends CanvasLayer

@onready var ghost_item = $GhostItem

func _ready() -> void:
	UIManager.GUI = self

func add_ghost_item(value):
	ghost_item.add_child(value)
	
func delete_ghost_item():
	ghost_item.get_child(0).queue_free()
