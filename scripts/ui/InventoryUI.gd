extends CanvasLayer

@export var width : int = 1
@export var height : int = 1

var slot_count : int

var inv : InventoryBase = InventoryBase.new()
var slots : Array

var ghost_item 

@onready var scroll_container = $ScrollContainer

var mouse_down_slots_entered : Array = []

var _drag_split_amount : int
var _drag_remainder : int

func _ready():
	InventoryManager.open_player_inventory.connect(open)
	InventoryManager.close_inventory.connect(close)
	
	slot_count = width * height
	inv.size = slot_count
	
	# Properly position the inventory to be centered 
	scroll_container.size = Vector2i(clampi(width*54, 54, 648), clampi(width*54, 54, 540))
	scroll_container.set_anchors_preset(Control.PRESET_CENTER, true)
	scroll_container.position.x -= (scroll_container.size.x/2)
	scroll_container.position.y -= (scroll_container.size.y/4)
	
	var v_box = VBoxContainer.new()
	v_box.add_theme_constant_override("separation", -4)
	#h_box.alignment = h_box.ALIGNMENT_CENTER 
	
	for y in height:
		var h_box = HBoxContainer.new()
		h_box.add_theme_constant_override("separation", -4)
		
		for x in width:
			var item_slot = preload("res://scenes/ui/inventory/inventory_slot.tscn").instantiate()
			h_box.add_child(item_slot)
			slots.append(item_slot)
			item_slot.action_event.connect(_on_slot_clicked)
			item_slot.mouse_entered_slot.connect(_on_mouse_entered_slot)
		
		v_box.add_child(h_box)
	
	scroll_container.add_child(v_box)

func _process(_delta):
	if visible and ghost_item != null and !GameManager.mouse_over_ui:
		if Input.is_action_just_pressed("left_click"):
			drop_ghost_item()
		elif Input.is_action_just_pressed("right_click"):
			drop_one()
	
	if Input.is_action_just_pressed("down"):
		inv.sort()
		update_all_slots()
		
	if !mouse_down_slots_entered.is_empty():
		
		if Input.is_action_just_released("left_click"):
			if mouse_down_slots_entered.size() == 1:
				var index = mouse_down_slots_entered[0]
				var slot_item = ghost_item.res.duplicate()
				inv.items[index] = slot_item
				update_slot(index)
			else:
				for i in mouse_down_slots_entered:
					var slot_item = ghost_item.res.duplicate()
					slot_item.quantity = _drag_split_amount
					inv.items[i] = slot_item
					update_slot(i)
			
			mouse_down_slots_entered.clear()
			_drag_remainder = 0
			_drag_split_amount = 0
			
			if ghost_item != null:
				ghost_item.set_quantity_to_visible_quantity()
				if ghost_item.res.quantity == 0:
					ghost_item.queue_free()
					ghost_item = null
		
		elif Input.is_action_just_released("right_click"):
			mouse_down_slots_entered.clear()
	
	if Input.is_action_just_pressed("inventory"):
		if InventoryManager.inventory_opened:
			InventoryManager.close_inventory.emit()
		else:
			InventoryManager.open_player_inventory.emit()

func update_all_slots():
	for i in slots.size():
		slots[i].set_info(inv.items[i])
		
func update_slot(index : int):
	slots[index].set_info(inv.items[index])

func set_slot(index : int, item : Item):
	inv.items[index] = item
	slots[index].set_info(inv.items[index])
	pass

func _on_slot_clicked(event : String, slot):
	var index = slots.find(slot)
	if mouse_down_slots_entered.is_empty():
		match event:
			# Logic for left click
			"left_click":
				if slots[index].res != null and ghost_item == null:
					# Pickup item and make a ghost item
					ghost_item = preload("res://scenes/ui/inventory/ghost_item.tscn").instantiate()
					add_child(ghost_item)
					ghost_item.set_info(inv.items[index])
					inv.items[index] = null
					update_slot(index)
				elif slots[index].res == null and ghost_item != null:
					# Place ghost item in empty slot
					mouse_down_slots_entered.append(index)
					inv.items[index] = ghost_item.res.duplicate()
					update_slot(index)
					#ghost_item.queue_free()
					#ghost_item = null
					
					
				elif slots[index].res != null and ghost_item != null:
					if slots[index].res.max_quantity > 1 and slots[index].res.id == ghost_item.res.id:
						combine(index)
					else:
						swap(index)
					
			# Logic for right click
			"right_click":
				if slots[index].res != null and ghost_item == null:
					split(index)
				elif slots[index].res == null and ghost_item != null:
					place_one(index)
					mouse_down_slots_entered.append(index)
				elif slots[index].res != null and ghost_item != null and slots[index].res.id == ghost_item.res.id:
					add_one(index)
					mouse_down_slots_entered.append(index)

func _on_mouse_entered_slot(slot):
	var index = slots.find(slot)
	if Input.is_action_pressed("left_click"):
		if ghost_item != null and slots[index].res == null:
			for i in mouse_down_slots_entered:
				if i == index:
					return
			mouse_down_slots_entered.append(index)
			
			var quantity : int = ghost_item.res.quantity
			
			if mouse_down_slots_entered.size() <= quantity:
				
				_drag_split_amount = floori(quantity / mouse_down_slots_entered.size())
				_drag_remainder = quantity - (_drag_split_amount * mouse_down_slots_entered.size())
				
				ghost_item.set_visible_quantity(_drag_remainder)
				
			#for i in mouse_down_slots_entered:
				##if inv.items[i] == null:
				#var slot_item = ghost_item.res.duplicate()
				#slot_item.quantity = _drag_split_amount
				#inv.items[index] = slot_item
				#update_slot(i)
				#if inv.items[i].id == ghost_item.res.id:
					
			
	
	elif Input.is_action_pressed("right_click"):
		if ghost_item != null and slots[index].res == null:
			for i in mouse_down_slots_entered:
				if i == index:
					return
			place_one(index)
			mouse_down_slots_entered.append(index)
		elif slots[index].res != null and ghost_item != null and slots[index].res.id == ghost_item.res.id:
			for i in mouse_down_slots_entered:
				if i == index:
					return
			add_one(index)
			mouse_down_slots_entered.append(index)

func place_one(index : int):
	var slot_item = ghost_item.res.duplicate()
	slot_item.quantity = 1
	
	inv.items[index] = slot_item
	update_slot(index)
	
	ghost_item.res.quantity -= 1
	ghost_item.update_quantity()
	update_slot(index)
	
	if ghost_item.res.quantity == 0:
		ghost_item.queue_free()
		ghost_item = null

func add_one(index : int):
	slots[index].res.quantity += 1
	ghost_item.res.quantity -= 1
	ghost_item.update_quantity()
	update_slot(index)
	
	if ghost_item.res.quantity == 0:
		ghost_item.queue_free()
		ghost_item = null

func swap(index : int):
	var item : Item = inv.items[index].duplicate() as Item
	inv.items[index] = ghost_item.res
	ghost_item.set_info(item)
	
	update_slot(index)

func combine(index : int):
	# Combines the ghost item with the item at the slot
	var remainder = inv.items[index].combine(ghost_item.res.quantity)
	
	if remainder > 0:
		ghost_item.res.quantity = remainder
		ghost_item.update_quantity()
	else:
		ghost_item.queue_free()
		ghost_item = null
		
	update_slot(index)
	
func split(index : int):
	var half
	if inv.items[index].quantity == 1:
		half = 1.0
	else:
		half = ceili(inv.items[index].quantity/2.0)
	
	inv.items[index].quantity -= half
	
	var ghost_res : Item = inv.items[index].duplicate() as Item
	ghost_res.quantity = half
	
	ghost_item = preload("res://scenes/ui/inventory/ghost_item.tscn").instantiate()
	add_child(ghost_item)
	ghost_item.set_info(ghost_res)
	
	if inv.items[index].quantity == 0:
		inv.items[index] = null
	
	update_slot(index)
	
	
func add_item(item : Item) -> bool:
	if inv.add_item(item):
		update_all_slots()
		return true
	return false
	
func drop_ghost_item():
	if ghost_item != null:
		var item = preload("res://scenes/item.tscn").instantiate()
		item.res = ghost_item.res
		item.global_position = GameManager.player_pos
		item.apply_central_impulse(Vector2(250 * GameManager.player_facing, -80))
		GameManager.item_entities.add_child(item)
		item.stall_pickup()
		ghost_item.queue_free()
		ghost_item = null

func drop_one():
	if ghost_item != null:
		var item = preload("res://scenes/item.tscn").instantiate()
		item.res = ghost_item.res.duplicate()
		item.res.quantity = 1
		ghost_item.res.quantity -= 1
		item.global_position = GameManager.player_pos
		item.apply_central_impulse(Vector2(250 * GameManager.player_facing, -80))
		GameManager.item_entities.add_child(item)
		item.stall_pickup()
		if ghost_item.res.quantity == 0:
			ghost_item.queue_free()
			ghost_item = null

func open():
	await update_all_slots()
	InventoryManager.inventory_opened = true
	show()
	
func close():
	if !mouse_down_slots_entered.is_empty() and Input.is_action_pressed("left_click"):
			ghost_item.set_quantity_to_visible_quantity()
			_drag_remainder = 0
			_drag_split_amount = 0
			if ghost_item.res.quantity == 0:
				ghost_item.queue_free()
				ghost_item = null
				
	if ghost_item != null:
		drop_ghost_item()
	
	InventoryManager.inventory_opened = false
	hide()


