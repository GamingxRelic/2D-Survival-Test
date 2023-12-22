extends Node2D

@export var health := 0.0 :
	set(value):
		health = value
		health_changed.emit()
	get:
		return health
		
@export var defense := 0.0 

signal health_changed
signal damage_taken
signal death

func damage(value : float):
	health -= value
	damage_taken.emit()
	
func _on_health_changed():
	if health <= 0.0:
		death.emit()

