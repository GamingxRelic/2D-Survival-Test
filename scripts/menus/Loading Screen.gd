extends Control

@onready var progress_label = $HBoxContainer/Progress_Label
var progress = []
var scene_load_status = 0

func _ready():
	ResourceLoader.load_threaded_request(GameManager.requested_scene)
	
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(GameManager.requested_scene, progress)
	progress_label.text = "Loading " + str(floor(progress[0]*100)) + "%"
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(GameManager.requested_scene)
		get_tree().change_scene_to_packed(new_scene) 
