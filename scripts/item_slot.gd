extends TextureRect

var dragging := false
var current_item = null
var currently_selected := false
var attack_cooldown := false

@onready var select_texture = %SelectTexture
@onready var cooldown_timer = $"../CooldownTimer"
@onready var cooldown_progress = $"../CooldownProgress"

@onready var item_texture_dict = {
	"empty" : null,
	"meteor" : preload("res://assets/sprites/UI/player_information/placeholder_meteor.png"),
	"shield" : preload("res://assets/sprites/UI/player_information/placeholder_shield.png"),
	"lightning" : preload("res://assets/sprites/UI/player_information/placeholder_lightning.png"),
	"flame" : preload("res://assets/sprites/UI/player_information/placeholder_flame.png"),
	"poison bottle" : preload("res://assets/sprites/UI/player_information/placeholder_poison_bottle.png"),
	"bow" : preload("res://assets/sprites/UI/player_information/placeholder_bow.png"),
	"morning_star" : preload("res://assets/sprites/UI/player_information/placeholder_morning_star.png"),
}
@onready var items = item_texture_dict.keys()

@onready var item_instance_dict = {
	"meteor" : "res://scenes/player/spells/meteor.tscn",
	"shield" : "res://scenes/player/spells/shield.tscn",
	"lightning" : "res://scenes/player/spells/lightning.tscn",
	"flame" : "res://scenes/player/spells/flame.tscn",
	"poison bottle" : "res://scenes/player/spells/poison_bottle.tscn",
	"bow" : "res://scenes/player/spells/arrow.tscn",
	"morning_star" : "res://scenes/player/spells/morning_star.tscn",
}

@onready var item_cooldown = {
	"meteor" : 4,
	"shield" : 7,
	"lightning" : 2.8,
	"flame" : 3,
	"poison bottle" : 10,
	"bow" : 2,
	"morning_star" : 5,
}

enum class_type {SHORT_RANGE, LONG_RANGE, DEFENSE, THROWING}
@onready var item_class = {
	"meteor" : class_type.LONG_RANGE,
	"shield" : class_type.DEFENSE,
	"lightning" : class_type.SHORT_RANGE,
	"flame" : class_type.SHORT_RANGE,
	"poison bottle" : class_type.THROWING,
	"bow" : class_type.LONG_RANGE,
	"morning_star" : class_type.THROWING,
}

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
			
	cooldown_progress.value = cooldown_timer.time_left
			
func start_cooldown(item: String):
	attack_cooldown = true
	cooldown_progress.max_value = item_cooldown[item]
	cooldown_timer.start(item_cooldown[item])

func _on_cooldown_timer_timeout():
	attack_cooldown = false
	
func get_can_drop():
	if (items[current_item] != "empty" && items[current_item] != "lock" && cooldown_timer.time_left <= 0 && !dragging):
		return true
	else:
		return false
		
func is_dragging():
	return dragging

func get_slot_item_class():
	return item_class[get_slot_item()]

func get_slot_item():
	return items[current_item]
	
func get_spell_instance():
	return item_instance_dict[items[current_item]]
	
func set_slot_item(item_name):
	current_item = items.find(item_name)
	texture = item_texture_dict[items[current_item]]

#DRAGGING FUNCTIONS
func _get_drag_data(_pos):
	if (items[current_item] != "empty" && items[current_item] != "lock" && cooldown_timer.time_left <= 0): #there is item to drag
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
