extends TextureRect

var dragging = false
var current_item = null

@onready var item_texture_dict = {
	"lock" : preload("res://assets/sprites/placeholder_lock.png"),
	"meteor" : preload("res://assets/sprites/placeholder_meteor.png")
}

@onready var items = item_texture_dict.keys()

func _ready():
	current_item = items.find("meteor")
	self.texture = item_texture_dict[items[current_item]]

func _get_drag_data(_pos):
	if (current_item != null): #there is item to drag
		var data = {}
		data["original_texture"] = texture
		
		var drag_texture = TextureRect.new()
		#drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.size = Vector2(get_global_transform().get_scale().x * texture.get_width(), get_global_transform().get_scale().y * texture.get_height())
		set_drag_preview(drag_texture)
	
		return data
	
func _can_drop_data(_pos, data):
	return true
	
func _drop_data(_pos, data):
	texture = data["original_texture"]
	
func _process(delta):
	#if (dragging):
	#	self.visible = false
		#var mouse_pos = get_global_mouse_position()
		#placeholder_item.global_position.x = mouse_pos.x - placeholder_item.texture.get_width() / 2
		#placeholder_item.global_position.y = mouse_pos.y - placeholder_item.texture.get_height() / 2
	#else:
	#	self.visible = true
	pass

func _on_slot_base_gui_input(event):
	#if (not dragging && event.is_action_pressed("left_click")):
	#	dragging = true
		
	#if (dragging && event.is_action_released("left_click")):
	#	dragging = false
	pass
