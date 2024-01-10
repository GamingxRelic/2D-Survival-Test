extends Node2D

@onready var cam := $Player/Camera2D as Camera2D
var zoom : float
var zoom_speed := 0.1
var min_zoom := 0.05
var max_zoom := 3.0

func _ready() -> void:
	GameManager.level = self
	GameManager.entities = $Entities
	GameManager.resource_nodes = $Entities/ResourceNodes
	GameManager.item_entities = $Entities/ItemEntities
	GameManager.spawn_resources.emit()
	$Player.global_position = GameManager.world_spawn
	zoom = cam.zoom.x

func _process(delta):
	if Input.is_action_pressed("zoom_in"):
		zoom = clampf(move_toward(zoom, zoom + zoom_speed, delta), min_zoom, max_zoom)
		zoom = move_toward(zoom, zoom + zoom_speed, 0.01)
		cam.zoom = Vector2(zoom, zoom)
		print(zoom)
		
	elif Input.is_action_pressed("zoom_out"):
		zoom = clampf(move_toward(zoom, zoom - zoom_speed, delta), min_zoom, max_zoom)
		cam.zoom = Vector2(zoom, zoom)
		print(zoom)
