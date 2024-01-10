extends CanvasLayer

@onready var ghost_item = $GhostItem
@onready var tooltip = $Tooltip
@onready var hotbar_panel_container : PanelContainer = $HotbarPanelContainer

func _ready() -> void:
	UIManager.GUI = self
	InventoryManager.open_player_inventory.connect(hide_hotbar)
	InventoryManager.close_inventory.connect(show_hotbar)

func add_ghost_item(value):
	ghost_item.add_child(value)
	
func delete_ghost_item():
	ghost_item.get_child(0).queue_free()

func add_tooltip(value):
	tooltip.add_child(value)

func delete_tooltip():
	if tooltip.get_child_count() > 0:
		tooltip.get_child(0).queue_free()

func show_hotbar():
	hotbar_panel_container.show()

func hide_hotbar():
	hotbar_panel_container.hide()
