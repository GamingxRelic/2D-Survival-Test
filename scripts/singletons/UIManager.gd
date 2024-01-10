extends Node

var GUI
var mouse_over_ui : bool = false

var hotbar_items : Array[Item]
var selected_hotbar_slot : int # Maybe make the slot you had last selected stored? (here?)

signal update_hotbar
signal update_hotbar_slot
signal use_current_hotbar_item
