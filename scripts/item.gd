extends RigidBody2D

## TODO:
# Add an Area2D that checks surrounding area to see if there are dropped items of the same type
# If there are, they should combine stack sizes.

@export var res : Item
@export var count : int

var following_player := false
var max_speed := 250.0

func _ready() -> void:
	$ColorRect.color = res.color
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(4, true)
	
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
