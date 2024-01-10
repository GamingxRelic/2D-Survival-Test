extends CanvasLayer
class_name InventoryUI

@export var width : int = 1
@export var height : int = 1

@export var ui_offset : Vector2

@export var player_inventory := false

var slot_count : int

var inv : InventoryBase
var slots : Array

var hotbar = null

var ghost_item :
	set(value):
		InventoryManager.ghost_item = value
	get:
		return InventoryManager.ghost_item

@onready var scroll_container = $InventoryPanel/Slots

#var _drag_slot_indexes : Array[int]

## TODO:
# Make it so if the mouse goes over any UI element, UIManager.mouse_over_ui is true.
# https://imgur.com/gallery/hTnZNDF   # Cool references for inventory UIs
# https://cdnb.artstation.com/p/assets/images/images/026/340/207/large/jacob-bergholtz-ui-inventory-pixel-perfect-export.jpg?1588522635 

func _ready():
	slot_count = width * height
	
	if player_inventory:
		InventoryManager.player_inventory = self
		inv = get_parent().find_child("PlayerData").inventory as InventoryBase
		get_parent().find_child("PlayerData").hotbar_size = width #as Array[Item]
		
		
	else:
		inv = InventoryBase.new()
		inv.size = slot_count
		
	offset = ui_offset
	
	InventoryManager.close_inventory.connect(close)
	
	
	
	 #Properly position the inventory to be centered 
	#scroll_container.custom_minimum_size = Vector2i( # for when I did not use container control nodes
	scroll_container.set_deferred("size", Vector2i(
		clampi((width * 50) + 16, 54, 648), 
		clampi((height * 50) + 16, 54, 540)
		))
	#scroll_container.size = Vector2i(clampi(width*54, 54, 648), clampi(width*54, 54, 540))
	#scroll_container.set_anchors_preset(Control.PRESET_CENTER, true)
	#scroll_container.position.x -= (scroll_container.size.x/2)
	#scroll_container.position.y -= (scroll_container.size.y/4)

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
			item_slot.item_empty.connect(_on_item_empty)
		
		v_box.add_child(h_box)
	
	scroll_container.add_child(v_box)

#func _input(event):
func _process(_delta):
	if visible:
		if ghost_item != null and !UIManager.mouse_over_ui and player_inventory:
			if Input.is_action_just_pressed("left_click"):
				drop_ghost_item()
			elif Input.is_action_just_pressed("right_click"):
				drop_one()
				
			
		#if Input.is_action_just_released("right_click") and _drag_slot_indexes.size() > 0:
		#	_drag_slot_indexes.clear()

func _on_item_empty(slot):
	var index = slots.find(slot)
	inv.items[index] = null
	update_slot(index)

func update_all_slots():
	for i in slots.size():
		slots[i].set_info(inv.items[i])

	if player_inventory:
		for i in width:
			get_parent().find_child("PlayerData").hotbar[i] = inv.items[i]
			UIManager.update_hotbar.emit()

func update_slot(index : int):
	slots[index].set_info(inv.items[index])
	if player_inventory and index < width:
		get_parent().find_child("PlayerData").hotbar[index] = inv.items[index]
		UIManager.update_hotbar_slot.emit(index)

func set_slot(index : int, item : Item):
	inv.items[index] = item
	slots[index].set_info(inv.items[index])
	pass

func _on_slot_clicked(event : String, slot):
	var index = slots.find(slot)
	match event:
		# Logic for left click
		"left_click":
			if !Input.is_action_pressed("right_click"):
				if slots[index].res != null and ghost_item == null:
					pickup_item(index)
				elif slots[index].res == null and ghost_item != null:
					# Place ghost item in empty slot
					inv.items[index] = ghost_item.res.duplicate()
					update_slot(index)
					delete_ghost_item()
					
					
					
				elif slots[index].res != null and ghost_item != null:
					if slots[index].res.max_quantity > 1 and slots[index].res.id == ghost_item.res.id:
						combine(index)
					else:
						swap(index)

		# Logic for right click
		"right_click":
			if !Input.is_action_pressed("left_click"):
				if slots[index].res != null and ghost_item == null:
					split(index)
				elif slots[index].res == null and ghost_item != null:
					place_one(index)
					#_drag_slot_indexes.append(index)
				elif slots[index].res != null and ghost_item != null and slots[index].res.id == ghost_item.res.id:
					add_one(index)
					#_drag_slot_indexes.append(index)

		# Logic for shift + left click
		"shift_left_click":
				# Quick Transfer items
				quick_transfer(index)
					 

func _on_mouse_entered_slot(slot):
	var index = slots.find(slot)
	if Input.is_action_pressed("right_click") and !Input.is_action_pressed("left_click"):
		if ghost_item != null and slots[index].res == null:
			place_one(index)
		elif slots[index].res != null and ghost_item != null and slots[index].res.id == ghost_item.res.id:
			add_one(index)

func quick_transfer(index : int) -> void:
	if player_inventory:
		if inv.items[index] != null and InventoryManager.other_inventory != null:
			if InventoryManager.other_inventory.add_item(inv.items[index]):
				inv.items[index] = null
			InventoryManager.other_inventory.update_all_slots()
			update_slot(index)
	else:
		if inv.items[index] != null:
			if InventoryManager.player_inventory.add_item(inv.items[index]):
				inv.items[index] = null
			InventoryManager.player_inventory.update_all_slots()
			update_slot(index)
		
func pickup_item(index : int):
	# Pickup item and make a ghost item
	ghost_item = preload("res://scenes/ui/inventory/ghost_item.tscn").instantiate()
	add_ghost_item()
	ghost_item.set_info(inv.items[index].duplicate())
	inv.items[index] = null
	update_slot(index)
		
func place_one(index : int):
	var slot_item = ghost_item.res.duplicate()
	slot_item.quantity = 1
	inv.items[index] = slot_item
	update_slot(index)
	
	ghost_item.res.quantity -= 1
	ghost_item.update_quantity()
	#update_slot(index)
	
	if ghost_item.res.quantity == 0:
		delete_ghost_item()
		
func add_one(index : int):
	if slots[index].res.quantity < slots[index].res.max_quantity:
		slots[index].res.quantity += 1 
		ghost_item.res.quantity -= 1
		ghost_item.update_quantity()
		update_slot(index)
	
		if ghost_item.res.quantity == 0:
			delete_ghost_item()
		
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
		delete_ghost_item()
		
		
	update_slot(index)
	
func split(index : int):
	if inv.items[index].quantity == 1:
		pickup_item(index)
		return
	
	var half
	half = ceili(inv.items[index].quantity/2.0)
	
	var ghost_res : Item = inv.items[index].duplicate() as Item
	ghost_res.quantity = half
	
	inv.items[index].quantity -= half
	
	ghost_item = preload("res://scenes/ui/inventory/ghost_item.tscn").instantiate()
	add_ghost_item()
	ghost_item.set_info(ghost_res)
	
	if inv.items[index].quantity == 0:
		inv.items[index] = null
	
	update_slot(index)
	
func add_item(item : Item) -> bool:
	var added = inv.add_item(item)
	update_all_slots()
	return added
	
func drop_ghost_item():
	if ghost_item != null:
		var item = preload("res://scenes/item.tscn").instantiate()
		item.res = ghost_item.res
		item.global_position = GameManager.player_pos
		item.apply_central_impulse(Vector2(250 * GameManager.player_facing, -80))
		GameManager.item_entities.add_child(item)
		item.stall_pickup()
		delete_ghost_item()
	
func drop_one():
	if ghost_item != null:
		var item = preload("res://scenes/item.tscn").instantiate()
		item.res = ghost_item.res.duplicate()
		item.res.quantity = 1
		ghost_item.res.quantity -= 1
		ghost_item.update_quantity()
		item.global_position = GameManager.player_pos
		item.apply_central_impulse(Vector2(250 * GameManager.player_facing, -80)) # Impulse of -80 away from player
		GameManager.item_entities.add_child(item) 
		item.stall_pickup()
		if ghost_item.res.quantity == 0:
			delete_ghost_item()
			
func open():
	await update_all_slots()
	InventoryManager.inventory_opened = true
	if !player_inventory:
		if InventoryManager.other_inventory != null:
			InventoryManager.other_inventory.close()
		InventoryManager.other_inventory = self
	show()
	
func close():
	if ghost_item != null and player_inventory:
		if add_item(ghost_item.res):
			delete_ghost_item()
		else:
			drop_ghost_item()
		
	InventoryManager.inventory_opened = false

	if !player_inventory:
		InventoryManager.other_inventory = null
	hide()

func add_ghost_item():
	UIManager.GUI.add_ghost_item(ghost_item)
	
func delete_ghost_item():
	ghost_item.queue_free()
	ghost_item = null

func _on_sort_button_pressed():
	inv.sort()
	update_all_slots()


func _on_sort_button_mouse_entered():
	UIManager.mouse_over_ui = true

func _on_sort_button_mouse_exited():
	UIManager.mouse_over_ui = false
