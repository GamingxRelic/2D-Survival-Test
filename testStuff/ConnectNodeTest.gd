class_name ConnectNodeTest
extends ColorRect

@export var offset : Vector2 = Vector2(-20,-20)

var next : Array[ConnectNodeTest]
var lines : Array[Line2D]

#func _init(pos : Vector2 = Vector2.ZERO):
	#global_position = pos

func add_next(node : ConnectNodeTest, pos : Vector2):
	if next.find(node) == -1:
		node.global_position = pos + offset
		next.append(node)
		add_child(node)
		update_lines()
		
func update_lines():
	for i in next:
		var line = Line2D.new()
		line.z_index = -1
		line.add_point(Vector2.ZERO - offset)
		line.add_point(i.position - offset)
		lines.append(line)
		add_child(line)

signal action_event
func _on_gui_input(event):
	if event is InputEvent:
		if Input.is_action_just_pressed("left_click"):
			action_event.emit(self)
