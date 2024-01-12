extends PanelContainer
class_name Tooltip

var offset : Vector2 = Vector2(18,0)

@onready var title_label : Label = $VBoxContainer/TitleContainer/Title
@onready var rarity_label : Label = $VBoxContainer/RarityContainer/Rarity
@onready var desc_label : Label = $VBoxContainer/DescriptionContainer/Description

func _ready():
	offset.y = (size.y/2 - 8) * -1
	global_position = get_global_mouse_position() + offset

func _process(_delta):
	global_position = get_global_mouse_position() + offset
	
#func set_info(title : String, rarity : String, desc : String):
func set_info(res : Item):
	await ready
	title_label.text = res.name
	rarity_label.text = res.rarity
	rarity_label.add_theme_color_override("font_color", GameManager.colors[res.rarity]) 
	desc_label.text = res.description
	
	# Add tags to description text.
	if res.tag_material:
		desc_label.text += "\nMaterial"
	if res.tag_equipable:
		desc_label.text += "\nEquipable"
	if res.tag_throwable:
		desc_label.text += "\nCan be thrown"
	if res.tag_consumable:
		desc_label.text += "\nConsumable"
	if res.tag_placeable:
		desc_label.text += "\nCan be placed"
	
