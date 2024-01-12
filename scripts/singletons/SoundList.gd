extends Node

# Dictionary of item pickup and related sounds
var item : Dictionary = {
	1 : "res://assets/audio/item/pop1.wav",
	2 : "res://assets/audio/item/pop2.wav",
	3 : "res://assets/audio/item/pop3.wav"
}

var resource_hit : Dictionary = {
	1 : "res://assets/audio/damage/damage1.wav",
	2 : "res://assets/audio/damage/damage2.wav",
	3 : "res://assets/audio/damage/damage3.wav"
}

var resource_break : Dictionary = {
	1 : "res://assets/audio/damage/break.wav"
}

var tile_damage : Dictionary = {
	"stone_1" : "res://assets/audio/damage/damage1.wav" # TEMP
}

var tile_break : Dictionary = {
	"stone" : "res://assets/audio/damage/break.wav" # TEMP
}
