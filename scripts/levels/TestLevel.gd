extends Node2D

func _ready() -> void:
	GameManager.level = self
	GameManager.entities = $Entities
	GameManager.resource_nodes = $Entities/Resource_Nodes
	GameManager.spawn_resources.emit()
	#$Player.process_mode = Node.PROCESS_MODE_DISABLED
	#hide()
	#$GUI.hide()
	#await $Ground/WorldTile.resource_generation_finished
	#show()
	#$GUI.show()
	#$Player.process_mode = Node.PROCESS_MODE_INHERIT
 	
