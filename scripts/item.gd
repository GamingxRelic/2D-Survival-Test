extends RigidBody2D

@export var res : Item

func _ready() -> void:
	$ColorRect.color = res.color
