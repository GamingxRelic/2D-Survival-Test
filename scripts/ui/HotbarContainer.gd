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
	UIManager.use_primary_current_hotbar_item.connect(_on_selected_item_primary_action)
	UIManager.use_secondary_current_hotbar_item.connect(_on_selected_item_secondary_action)
	
	#await UIManager.hotbar_items != null
	create_hotbar()


func _input(event):
	if event is InputEvent and !InventoryManager.inventory_opened:
		#if Input.is_action_pressed("left_click"):
			#use_selected_item()
		
		# For navigating the hotbar
		if Input.is_action_pressed("scroll_down"):
			select_next()
		if Input.is_action_pressed("scroll_up"):
			select_previous()
			
		# For 1-9 hotbar slot inputs
		if Input.is_action_pressed("hotbar_1"):
			selected_slot = 0
		if Input.is_action_pressed("hotbar_2"):
			selected_slot = 1
		if Input.is_action_pressed("hotbar_3"):
			selected_slot = 2
		if Input.is_action_pressed("hotbar_4"):
			selected_slot = 3
		if Input.is_action_pressed("hotbar_5"):
			selected_slot = 4
		if Input.is_action_pressed("hotbar_6"):
			selected_slot = 5
		if Input.is_action_pressed("hotbar_7"):
			selected_slot = 6
		if Input.is_action_pressed("hotbar_8"):
			selected_slot = 7
		if Input.is_action_pressed("hotbar_9"):
			selected_slot = 8

func  _on_selected_item_primary_action():
	if slots[selected_slot].res != null:
		slots[selected_slot].res.primary_action()
		_update_hotbar_slot(selected_slot)
		
func _on_selected_item_secondary_action():
	if slots[selected_slot].res != null:
		slots[selected_slot].res.secondary_action()
		_update_hotbar_slot(selected_slot)

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

func _on_action_event(_event : String, slot):
	var index = slots.find(slot)
	selected_slot = index

func select_next():
	if selected_slot == hotbar_items.size()-1:
		selected_slot = 0
	else:
		selected_slot += 1
	
func select_previous():
	if selected_slot == 0:
		selected_slot = hotbar_items.size()-1
	else:
		selected_slot -= 1
