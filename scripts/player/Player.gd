extends CharacterBody2D

@onready var data : PlayerData = $PlayerData

# Movement
var sprinting := false

enum facing {
	LEFT = -1,
	RIGHT = 1
}

# More predictable jumps
const jump_height : float = 100
const jump_time_to_peak : float = 0.5
const jump_time_to_descent : float = 0.4
const jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0 
const jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
const fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# For variable jump height
const cut_height : float = 0.75

# Max y velocity
const max_fall_velocity : float = 550.0

# Jumping variables
var can_jump := false
var jump_was_pressed := false
var is_jumping := false

# Audio variables
@onready var pickup_audio := $Audio/Pickup

# Corner Correction variables
@onready var cc_raycasts : Array = $Raycasts/CornerCorrection.get_children()
@export var cc_push_amount := 3.0

# Stair Check variables
@onready var sc_raycasts : Array = $Raycasts/StairCheck.get_children()
const sc_x_push_amount := 2.0
const sc_y_push_amount := 8.0

# Inventory
@onready var inv := $InventoryUI

func _ready() -> void:
	InventoryManager.open_player_inventory.connect(_on_open_player_inventory)

func _physics_process(delta) -> void:
	#print(Engine.get_frames_per_second())
	
	GameManager.player_pos = global_position

	# Handle Jump
	handle_jump(delta)
		
	# Horizontal Movement
	horizontal_movement()
	
	# Stair Check
	stair_check()
	
	# Corner Correction
	corner_correction()
	
	#input()
	# Change all inputs to be in the _input(event) function
	
	move_and_slide()
	

func horizontal_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction < 0:
		GameManager.player_facing = facing.LEFT # Left
	elif direction > 0:
		GameManager.player_facing = facing.RIGHT # Right
	
	if direction:
		if sprinting:
			velocity.x = direction * data.sprint_speed
			#anim_tree.set("parameters/running_timescale/scale", 1.5)
		else:
			velocity.x = direction * data.speed
			#anim_tree.set("parameters/running_timescale/scale", 1)
	else:
		velocity.x = move_toward(velocity.x, 0, data.speed)

func handle_jump(delta) -> void:
	if is_on_floor():
		#if Input.is_action_just_pressed("down"):
			#global_position.y += 1
		
		is_jumping = false
		can_jump = true
		if jump_was_pressed:
			jump()
	
	# Add the gravity.
	if not is_on_floor():
		coyote_time()
		velocity.y += get_gravity() * delta
		velocity.y = clampf(velocity.y, -max_fall_velocity, max_fall_velocity)
	
	#if Input.is_action_just_pressed("jump"):
		#jump_was_pressed = true
		#remember_jump_time()
		#if can_jump:
			#jump()
#
	#if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
		#velocity.y *= cut_height

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
		if velocity.x < 0 and velocity.y == 0 and sc_raycasts[0].get_collider() != null and sc_raycasts[1].get_collider() == null:
			position.x -= sc_x_push_amount
			position.y -= sc_y_push_amount
		if velocity.x > 0 and velocity.y == 0 and sc_raycasts[2].get_collider() != null and sc_raycasts[3].get_collider() == null:
			position.x += sc_x_push_amount
			position.y -= sc_y_push_amount

func corner_correction():
	if velocity.y < 0:
		if cc_raycasts[0].get_collider() != null and cc_raycasts[1].get_collider() == null:
			position.x += cc_push_amount

		if cc_raycasts[2].get_collider() != null and cc_raycasts[3].get_collider() == null:
			position.x -= cc_push_amount

func _input(event):
	if event is InputEvent:
		 # Jumping things
		if is_on_floor():
			if Input.is_action_just_pressed("down"):
				global_position.y += 1
			
		if Input.is_action_just_pressed("jump"):
			jump_was_pressed = true
			remember_jump_time()
			if can_jump:
				jump()

		if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
			velocity.y *= cut_height
		
		
		# Horizontal movement
		
		if Input.is_action_pressed("sprint") and is_on_floor():
			sprinting = true
		if !Input.is_action_pressed("sprint") and is_on_floor():
			sprinting = false
		
		# Other
		
		#if Input.is_action_just_pressed("left_click"):
		if Input.is_action_pressed("left_click") and !UIManager.mouse_over_ui:
			# Make this a use_item function
			if global_position.distance_to(get_global_mouse_position()) <= data.reach:
				var mouse_col = $Area2Ds/DamageBox/Mouse_Collision
				GameManager.break_block(get_global_mouse_position())
				mouse_col.global_position = get_global_mouse_position()
				mouse_col.set_deferred("disabled", false)
				await get_tree().create_timer(0.1).timeout
				mouse_col.set_deferred("disabled", true)
		
		#elif Input.is_action_just_pressed("right_click"):
		if Input.is_action_pressed("right_click") and !UIManager.mouse_over_ui:
			# Do something with right click. 
			if global_position.distance_to(get_global_mouse_position()) <= data.reach:
				GameManager.place_block(get_global_mouse_position(), TileList.tile["STONE"])
				
		#if Input.is_action_just_pressed("middle_click") and !UIManager.mouse_over_ui:
			#var item = preload("res://scenes/item.tscn").instantiate()
			#item.global_position = get_global_mouse_position()
			#item.res = load("res://resources/item/apple.tres").duplicate()
			#GameManager.item_entities.call_deferred("add_child", item)
			
		if Input.is_action_pressed("ui_text_submit"):
			GameManager.spawn_resources.emit()
		
		if Input.is_action_just_pressed("grenade"):
			var grenade = preload("res://scenes/misc/grenade.tscn").instantiate()
			grenade.global_position = global_position
			var grenade_direction := (get_global_mouse_position() - global_position).normalized()
			var grenade_speed := 500
			grenade.apply_central_impulse(grenade_direction * grenade_speed)
			GameManager.entities.call_deferred("add_child", grenade)
			
		if Input.is_action_just_pressed("inventory"):
			if InventoryManager.inventory_opened:
				InventoryManager.close_inventory.emit()
			else:
				InventoryManager.open_player_inventory.emit()
				inv.open()
				#$InventoryUI2.open()

func pickup(item : Item) -> bool:
	if inv.add_item(item):
		var sound = load(SoundList.item[randi_range(1, SoundList.item.size())])
		pickup_audio.stream = sound
		pickup_audio.play()
		return true
	return false
	
func _on_pickup_range_body_entered(body) -> void:
	if body.is_in_group("item") and !body.is_stalling():
		if pickup(body.res):
			body.queue_free()
		
func _on_damage_box_body_entered(body):
	if body.is_in_group("resource"):
		body.damage(data.attack_damage)


func _on_item_pull_range_body_entered(body):
	if body.is_in_group("item"):
		body.follow_player()


func _on_item_pull_range_body_exited(body):
	if body.is_in_group("item"):
		body.stop_following_player()

func _on_open_player_inventory() -> void:
	inv.open()
