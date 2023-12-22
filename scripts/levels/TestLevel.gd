extends Node2D

func _ready() -> void:
	GameManager.level = self
	GameManager.entities = $Entities
	GameManager.spawn_resources.emit()
