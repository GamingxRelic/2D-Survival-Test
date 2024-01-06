extends HBoxContainer

var hotbar_slots
var hotbar_items :
	set(value):
		hotbar_items = value
	get:
		return UIManager.hotbar_items
var slots
var selected_slot : int = 0:
	set(value):
		if value != selected_slot:
			slots[selected_slot].deselect()
			selected_slot = value
			slots[selected_slot].select()

func _ready():
	UIManager.update_hotbar.connect(_update_hotbar)
	UIManager.update_hotbar_slot.connect(_update_hotbar_slot)
	await UIManager.hotbar_items != null
	create_hotbar()
	

func create_hotbar():
	for i in hotbar_items.size():
		var hotbar_slot = preload("res://scenes/ui/hotbar_slot.tscn").instantiate()
		hotbar_slot.res = hotbar_items[i]
		add_child(hotbar_slot)
		hotbar_slot.action_event.connect(_on_action_event)
	slots = get_children()
	slots[0].select()
	#selected_slot = UIManager.selected_hotbar_slot
		
func _update_hotbar():
	for i in hotbar_items.size():
		slots[i].set_info(hotbar_items[i])
		
func _update_hotbar_slot(index : int):
	slots[index].set_info(hotbar_items[index])

func _on_action_event(event : String, slot):
	var index = slots.find(slot)
	selected_slot = index
	#print(event + " at slot " +str(index))
