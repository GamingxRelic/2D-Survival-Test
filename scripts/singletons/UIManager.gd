extends Node

var GUI
var mouse_over_ui : bool = false

var hotbar_items : Array[Item]
var selected_hotbar_slot : int # Maybe make the slot you had last selected stored? (here?)

signal update_hotbar
signal update_hotbar_slot
signal use_primary_current_hotbar_item
signal use_secondary_current_hotbar_item

func get_current_hotbar_item() -> Item:
	return hotbar_items[selected_hotbar_slot]
