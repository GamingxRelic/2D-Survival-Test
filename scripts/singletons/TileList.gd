extends Node

var tile : Dictionary = {
	# Order is NAME : Vector2i of Tile Atlas position
	"GRASS_TOP_LEFT" : Vector2i(0,0),
	"GRASS_LEFT" : Vector2i(0,1),
	"GRASS_TOP" : Vector2i(1,0),
	"GRASS_TOP_RIGHT" : Vector2i(2,0),
	"GRASS_RIGHT" : Vector2i(2,1),
	"DIRT" : Vector2i(1,1),
	"STONE" : Vector2i(3, 0)
}
