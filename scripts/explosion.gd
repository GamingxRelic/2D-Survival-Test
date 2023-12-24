extends Area2D

@export var radius : int
@export var damage : int
var unit = 16

@onready var collision_shape = $CollisionShape2D 

func _ready():
	collision_shape.shape.radius = radius * unit
	spawn_circles( generate_circle_points() )
	
	# If debugging is on, wait 2 seconds before deleting because visualizer is showing
	if GameManager.debug:
		await get_tree().create_timer(2).timeout
		
	# Otherwise, activate the collision shape
	else:
		collision_shape.disabled = false
		await get_tree().create_timer(0.1).timeout
		collision_shape.disabled = true
		
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
				circle_points.push_back(Vector2(x, y) * unit)

	return circle_points

func spawn_circles(points):
	for point in points:
		if GameManager.debug:
			spawn_node2d(point)
		else:
			GameManager.break_block(to_global(point))

# For visualizing circle 
func spawn_node2d(offset : Vector2):
	var node = CollisionShape2D.new()
	node.shape = CircleShape2D.new()
	node.shape.radius = 4
	node.position = offset
	call_deferred("add_child", node)

func _on_body_entered(body):
	if body.is_in_group("resource"):
		body.damage(damage)
