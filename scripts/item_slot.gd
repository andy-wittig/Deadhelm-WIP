extends TextureRect

var dragging = false
var current_item = null
var currently_selected = false

@onready var select_texture = %SelectTexture

@onready var item_texture_dict = {
	"empty" : null,
	"lock" : preload("res://assets/sprites/UI/player_information/placeholder_lock.png"),
	"meteor" : preload("res://assets/sprites/UI/player_information/placeholder_meteor.png"),
	"shield" : preload("res://assets/sprites/UI/player_information/placeholder_shield.png"),
	"lightning" : preload("res://assets/sprites/UI/player_information/placeholder_lightning.png"),
	"flame" : preload("res://assets/sprites/UI/player_information/placeholder_flame.png"),
}

@onready var item_instance_dict = {
	"meteor" : "res://scenes/player/spells/meteor.tscn",
	"shield" : "res://scenes/player/spells/shield.tscn",
	"lightning" : "res://scenes/player/spells/lightning.tscn",
	"flame" : "res://scenes/player/spells/flame.tscn",
}

@onready var items = item_texture_dict.keys()

func _ready():
	current_item = items.find("empty")
	texture = item_texture_dict[items[current_item]]

func _process(delta):
	if (currently_selected):
		select_texture.visible = true
	else:
		select_texture.visible = false
		
	if (dragging):
		if (Input.is_action_just_released("left_click")):
			dragging = false

func get_slot_item():
	return items[current_item]
	
func get_spell_instance():
	return item_instance_dict[items[current_item]]
	
func set_slot_item(item_name):
	current_item = items.find(item_name)
	texture = item_texture_dict[items[current_item]]

func _get_drag_data(_pos):
	if (items[current_item] != "empty" && items[current_item] != "lock"): #there is item to drag
		var data = {}
		data["original_slot"] = self
		data["original_texture"] = texture
		data["item_type"] = items[current_item]
		
		var drag_texture = TextureRect.new()
		drag_texture.texture = texture
		drag_texture.size = Vector2(get_global_transform().get_scale().x * texture.get_width(), get_global_transform().get_scale().y * texture.get_height())
		set_drag_preview(drag_texture)
	
		return data
	
func _can_drop_data(_pos, data):
	if (data["item_type"] == "lock"):
		return false
	return true
	
func _drop_data(_pos, data):
	data["original_slot"].set_slot_item(get_slot_item())
	set_slot_item(data["item_type"])

#var mouse_pos = get_global_mouse_position()
#placeholder_item.global_position.x = mouse_pos.x - placeholder_item.texture.get_width() / 2

func _on_slot_base_gui_input(event):
	if (event.is_action_pressed("left_click")):
		dragging = true
