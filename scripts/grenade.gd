extends RigidBody2D

@export var radius : float = 1.0
@export var fuse_time : float = 0.05
@export var damage : float = 1.0

func _ready():
	$Timer.wait_time = fuse_time
	$Timer.start()


func _on_timer_timeout():
	# Explosion
	var explosion = preload("res://scenes/misc/explosion.tscn").instantiate()
	explosion.radius = radius
	explosion.damage = damage
	explosion.global_position = global_position
	GameManager.entities.call_deferred("add_child", explosion)
	
	# Particles
	var particles = preload("res://scenes/test_explosion_particles.tscn").instantiate()
	particles.global_position = global_position
	GameManager.entities.call_deferred("add_child", particles)
	
	await particles.ready
	queue_free()

