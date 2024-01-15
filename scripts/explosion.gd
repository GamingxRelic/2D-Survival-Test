extends Area2D

@export var radius : int
@export var damage : int
var offset : Vector2 = Vector2(unit/2.0, unit/2.0)
# Tile size in px
var unit : int :
	set(value):
		GameManager.tilemap.unit = value
	get:
		return GameManager.tilemap.unit 

@onready var collision_shape = $CollisionShape2D 

func _ready():
	global_position.x = (int(global_position.x / unit) * unit ) #+ (unit/4) # Round x to the nearest multiple of unit
	global_position.y = (int(global_position.y / unit) * unit ) #+ (unit/4)  # Round y to the nearest multiple of unit
	
	collision_shape.shape.radius = radius * unit
	spawn_circles( generate_circle_points() )
	
	# If debugging is on, wait 2 seconds before deleting because visualizer is showing
	if GameManager.debug:
		await get_tree().create_timer(2).timeout
		
	# Otherwise, activate the collision shape
	#else:
	collision_shape.set_deferred("disabled", false)
	await get_tree().create_timer(0.1).timeout
	collision_shape.set_deferred("disabled", true)
		
	queue_free()

func generate_circle_points():
	var min_x = -radius
	var max_x = radius
	var min_y = -radius
	var max_y = radius
	
	var circle_points = []

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			# Check if the current point is inside the circle
			if sqrt(x**2 + y**2) <= radius:
				circle_points.push_back((Vector2(x, y) * unit) + offset)

	return circle_points

func spawn_circles(points):
	for point in points:
		if GameManager.debug:
			spawn_node2d(point)
			#GameManager.break_block(to_global(point))
		
		GameManager.damage_tile.emit(to_global(point), damage)
			

# For visualizing circle 
func spawn_node2d(pos_offset : Vector2):
	var node = CollisionShape2D.new()
	node.shape = CircleShape2D.new()
	node.shape.radius = 2
	node.position = pos_offset
	call_deferred("add_child", node)

func _on_body_entered(body):
	if body.is_in_group("resource"):
		body.damage(damage)
