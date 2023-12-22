extends RigidBody2D

@export var res : Item
var following_player := false
var max_speed := 150.0

func _ready() -> void:
	$ColorRect.color = res.color
	
func _physics_process(_delta):
	if following_player:
		var x = (global_position.x - GameManager.player_pos.x)
		var y = (global_position.y - GameManager.player_pos.y)
		apply_central_force(Vector2(x * -100, y * -100))

func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

func follow_player():
	following_player = true
	set_collision_mask_value(1, false)
	
func stop_following_player():
	following_player = false
	set_collision_mask_value(1, true)
