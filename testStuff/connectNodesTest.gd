extends Node2D

var nodes : Array[ConnectNodeTest]
var selected_node : ConnectNodeTest


func _process(delta):
	if Input.is_action_just_pressed("jump"):
		var new_node = preload("res://testStuff/connect_node_test.tscn").instantiate()
		new_node.global_position = get_global_mouse_position() + Vector2(-20,-20)
		new_node.color = Color.BLUE
		new_node.action_event.connect(_on_action_event)
		nodes.append(new_node)
		add_child(new_node)
		
		selected_node = new_node
		
	if Input.is_action_just_pressed("right_click"):
		var new_node = preload("res://testStuff/connect_node_test.tscn").instantiate()
		var pos = get_global_mouse_position() - selected_node.global_position
		new_node.color = Color.RED
		new_node.action_event.connect(_on_action_event)
		selected_node.add_next(new_node, pos)
		nodes.append(new_node)

func _on_action_event(node):
	var index = nodes.find(node)
	selected_node = nodes[index]
