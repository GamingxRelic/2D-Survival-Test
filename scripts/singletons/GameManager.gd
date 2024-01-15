extends Node

var debug := false

var requested_scene = "res://scenes/levels/TestLevel.tscn"

var level
var entities
var resource_nodes
var item_entities
var damaged_tiles_data
var sounds
var max_resource_nodes := 100

# Tilemap 
var tilemap : TileMap 
var world_spawn : Vector2
var tile_data : Array[Array] 
signal damage_tile
signal place_tile

var player_pos : Vector2
var player_facing : int = 1
var player_data : PlayerData 
var mouse_pos : Vector2

var luck : float = 0.0

var colors : Dictionary = {
	"BROKEN" : Color("939393"),
	"COMMON" : Color("f7f7f7"),
	"UNCOMMON" : Color("3bcc3f"),
	"RARE" : Color("0c27d3"),
	"MYTHICAL" : Color("5419ea"),
	"LEGENDARY" : Color("f0f736"),
	"DEBUG" : Color.BLUE_VIOLET
}

signal spawn_resources

func play_sound_at_pos(stream : String, pos : Vector2):
	var sound_player = AudioStreamPlayer2D.new()
	sound_player.stream = load(stream)
	sound_player.global_position = pos
	sound_player.max_distance = 512
	sounds.add_child(sound_player)
	sound_player.play()
	#await get_tree().process_frame
	await sound_player.finished
	sound_player.queue_free()
