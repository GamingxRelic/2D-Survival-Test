extends GPUParticles2D

func _ready():
	emitting = true
	$AudioStreamPlayer2D.play()

func _on_finished():
	queue_free()
