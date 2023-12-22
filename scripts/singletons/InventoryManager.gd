extends Node

var stone_count := 0 :
	set(value):
		stone_count = value
		stone_count_changed.emit()
	get:
		return stone_count
	
var wood_count := 0 :
	set(value):
		wood_count = value
		wood_count_changed.emit()
	get:
		return wood_count

signal stone_count_changed
signal wood_count_changed
