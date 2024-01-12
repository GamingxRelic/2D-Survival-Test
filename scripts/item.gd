extends RigidBody2D

## TODO:
# Add an Area2D that checks surrounding area to see if there are dropped items of the same type
# If there are, they should combine stack sizes and one of them should queue_free().

@export var res : Item

var following_player := false
var max_speed : float
var max_follow_speed := 150.0
var max_normal_speed := 250.0
var follow_player_speed := Vector2(-30,-50)
var inside_tile := false

var stall_pickup_time : float = 1.5
var stalling_pickup := false

var central_impulse_amount : Vector2

@onready var texture_rect = $TextureRect

func _ready() -> void:
	texture_rect.texture = res.texture
	#await get_tree().create_timer(0.1).timeout
	
	#set_collision_mask_value(4, true)
	
func _physics_process(_delta):
	if central_impulse_amount != Vector2.ZERO:
		apply_central_impulse(central_impulse_amount)
		central_impulse_amount = Vector2.ZERO
	
	if following_player:
		if !stalling_pickup:
			set_collision_mask_value(1, false)
			max_speed = max_follow_speed
			var x = (global_position.x - GameManager.player_pos.x)
			var y = (global_position.y - GameManager.player_pos.y + 12)
			apply_central_force(follow_player_speed * Vector2(x, y))
	if !following_player:
		max_speed = max_normal_speed
		if GameManager.tilemap.get_cell_tile_data(0, GameManager.tilemap.local_to_map(global_position)) != null:
			inside_tile = true
			set_collision_mask_value(1, false)
			#apply_central_force(Vector2(0, -250-980))
		else:
			inside_tile = false
			set_collision_mask_value(1, true)
			
			#if linear_velocity.normalized() > Vector2.ZERO:
				#texture_rect.material.set_shader_parameter("hovering", false)
			#else:
				#texture_rect.material.set_shader_parameter("hovering", true)

func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
	
	if inside_tile:
		state.linear_velocity.x = 0.0
		state.linear_velocity.y = -150

func follow_player():
	following_player = true
	
	
func stop_following_player():
	following_player = false
	set_collision_mask_value(1, true)

func stall_pickup():
	stalling_pickup = true
	await get_tree().create_timer(stall_pickup_time).timeout
	stalling_pickup = false
	
func is_stalling() -> bool:
	return stalling_pickup
