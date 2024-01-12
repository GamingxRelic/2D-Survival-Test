extends Node2D

func _process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("left_click") and !$"../AnimationPlayer".is_playing():
		$"../AnimationPlayer".play("swing")
