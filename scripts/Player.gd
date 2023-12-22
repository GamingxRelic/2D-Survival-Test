extends CharacterBody2D

# Movement Speed
@export var speed := 150.0
@export var sprint_speed := 250.0
var sprinting := false

# Attack 
var attack_damage := 1.0

# More predictable jumps
@export var jump_height : float = 100
@export var jump_time_to_peak : float = 0.5
@export var jump_time_to_descent : float = 0.4
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0 
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# For variable jump height
@export var cut_height : float = 0.75

# Max y velocity
@export var max_fall_velocity : float = 550.0

# Jumping variables
var can_jump := false
var jump_was_pressed := false
var is_jumping := false

# Audio variables
@onready var pickup_audio := $Audio/Pickup

# Corner Correction variables
@onready var cc_outer_left := $Raycasts/CornerCorrection/OuterLeft
@onready var cc_inner_left := $Raycasts/CornerCorrection/InnerLeft
@onready var cc_outer_right := $Raycasts/CornerCorrection/OuterRight
@onready var cc_inner_right := $Raycasts/CornerCorrection/InnerRight
@export var cc_push_amount := 3.0

# Stair Check variables
@onready var sc_head_left := $Raycasts/StairCheck/LeftHead
@onready var sc_ground_left := $Raycasts/StairCheck/LeftFoot
@onready var sc_head_right := $Raycasts/StairCheck/RightHead
@onready var sc_ground_right := $Raycasts/StairCheck/RightFoot
@export var sc_push_amount := 160.0

func _physics_process(delta) -> void:
	GameManager.player_pos = global_position

	# Handle Jump
	handle_jump(delta)
		
	# Horizontal Movement
	horizontal_movement()
	
	# Stair Check
	#stair_check()
	
	# Corner Correction
	#corner_correction()
	
	move_and_slide()
	
	if Input.is_action_pressed("left_click"):
		var cell_coords := GameManager.tilemap.local_to_map(get_global_mouse_position())
		GameManager.tilemap.set_cell(0, cell_coords)
		
		$DamageBox/Mouse_Collision.global_position = get_global_mouse_position()
		$DamageBox/Mouse_Collision.disabled = false
		await get_tree().create_timer(0.1).timeout
		$DamageBox/Mouse_Collision.disabled = true
		#$DamageBox/CollisionShape2D.disabled = false
		#$DamageBox/CollisionShape2D2.disabled = false
		#await get_tree().create_timer(0.1).timeout
		#$DamageBox/CollisionShape2D.disabled = true
		#$DamageBox/CollisionShape2D2.disabled = true
	
	if Input.is_action_pressed("right_click"):
		var cell_coords := GameManager.tilemap.local_to_map(get_global_mouse_position())
		if GameManager.tilemap.get_cell_tile_data(0, cell_coords) == null:
			GameManager.tilemap.set_cell(0, cell_coords, 0, Vector2i(2, 0))

func horizontal_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_pressed("sprint") and is_on_floor():
		sprinting = true
	if !Input.is_action_pressed("sprint") and is_on_floor():
		sprinting = false
	
	if direction:
		if sprinting:
			velocity.x = direction * sprint_speed
			#anim_tree.set("parameters/running_timescale/scale", 1.5)
		else:
			velocity.x = direction * speed
			#anim_tree.set("parameters/running_timescale/scale", 1)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func handle_jump(delta) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("down"):
			global_position.y += 1
		
		is_jumping = false
		can_jump = true
		if jump_was_pressed:
			jump()
	
	# Add the gravity.
	if not is_on_floor():
		coyote_time()
		velocity.y += get_gravity() * delta
		velocity.y = clampf(velocity.y, -max_fall_velocity, max_fall_velocity)
	
	if Input.is_action_just_pressed("jump"):
		jump_was_pressed = true
		remember_jump_time()
		if can_jump:
			jump()

	if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
		velocity.y *= cut_height

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump() -> void:
	is_jumping = true
	velocity.y = jump_velocity
	
func coyote_time() -> void:
	await get_tree().create_timer(0.1).timeout
	can_jump = false

func remember_jump_time() -> void:
	await get_tree().create_timer(0.1).timeout
	jump_was_pressed = false

func stair_check():
	if velocity.x != 0:
		if velocity.x < 0 and velocity.y == 0 and sc_ground_left.get_collider() != null and sc_head_left.get_collider() == null:
			velocity.x -= sc_push_amount
			velocity.y -= sc_push_amount
		if velocity.x > 0 and velocity.y == 0 and sc_ground_right.get_collider() != null and sc_head_right.get_collider() == null:
			velocity.x += sc_push_amount
			velocity.y -= sc_push_amount

func corner_correction():
	if velocity.y < 0:
		if cc_outer_left.get_collider() != null and cc_inner_left.get_collider() == null:
			position.x += cc_push_amount

		if cc_outer_right.get_collider() != null and cc_inner_right.get_collider() == null:
			position.x -= cc_push_amount

func pickup(item_id : String) -> void:
	var sound = load(SoundList.item[randi_range(1, SoundList.item.size())])
	pickup_audio.stream = sound
	pickup_audio.play()
	
	match item_id:
		"stone":
			InventoryManager.stone_count += 1
		"wood":
			InventoryManager.wood_count += 1

func _on_pickup_range_body_entered(body) -> void:
	if body.is_in_group("item"):
		pickup(body.res.id)
		body.queue_free()
		
func _on_damage_box_body_entered(body):
	if body.is_in_group("resource"):
		body.damage(attack_damage)


func _on_item_pull_range_body_entered(body):
	if body.is_in_group("item"):
		body.follow_player()


func _on_item_pull_range_body_exited(body):
	if body.is_in_group("item"):
		body.stop_following_player()
