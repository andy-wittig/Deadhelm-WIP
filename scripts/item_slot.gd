extends TextureRect

var dragging := false
var current_item := "empty"
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
	"poison_bottle" : preload("res://assets/sprites/UI/player_information/placeholder_poison_bottle.png"),
	"bow" : preload("res://assets/sprites/UI/player_information/placeholder_bow.png"),
	"morning_star" : preload("res://assets/sprites/UI/player_information/placeholder_morning_star.png"),
	"phantasmal_push" : preload("res://assets/sprites/UI/player_information/placeholder_phantasmal_push.png"),
}

@onready var item_instance_dict = {
	"empty" : null,
	"meteor" : "res://scenes/player/spells/meteor.tscn",
	"shield" : "res://scenes/player/spells/shield.tscn",
	"lightning" : "res://scenes/player/spells/lightning.tscn",
	"flame" : "res://scenes/player/spells/flame.tscn",
	"poison_bottle" : "res://scenes/player/spells/poison_bottle.tscn",
	"bow" : "res://scenes/player/spells/arrow.tscn",
	"morning_star" : "res://scenes/player/spells/morning_star.tscn",
	"phantasmal_push" : "res://scenes/player/spells/phantasmal_push.tscn",
}

@onready var item_cooldown = {
	"empty" : null,
	"meteor" : 2,
	"shield" : 7,
	"lightning" : 3,
	"flame" : 3,
	"poison_bottle" : 10,
	"bow" : 2,
	"morning_star" : 5,
	"phantasmal_push" : 5,
}

enum class_type {SHORT_RANGE, LONG_RANGE, DEFENSE, THROWING}
@onready var item_class = {
	"empty" : null,
	"meteor" : class_type.LONG_RANGE,
	"shield" : class_type.DEFENSE,
	"lightning" : class_type.SHORT_RANGE,
	"flame" : class_type.SHORT_RANGE,
	"poison_bottle" : class_type.THROWING,
	"bow" : class_type.LONG_RANGE,
	"morning_star" : class_type.THROWING,
	"phantasmal_push" : class_type.DEFENSE,
}

func _ready():
	texture = item_texture_dict[current_item]

func _process(delta):
	if (currently_selected):
		select_texture.visible = true
	else:
		select_texture.visible = false
			
	cooldown_progress.value = cooldown_timer.time_left
	
	if (Input.is_action_just_released("select")):
		dragging = false
			
func start_cooldown(item: String):
	attack_cooldown = true
	cooldown_progress.max_value = item_cooldown[item]
	cooldown_timer.start(item_cooldown[item])

func _on_cooldown_timer_timeout():
	attack_cooldown = false
	
func get_can_drop():
	if (current_item != "empty" && current_item != "lock" && cooldown_timer.time_left <= 0 && !dragging):
		return true
	else:
		return false
		
func is_dragging():
	return dragging

func get_slot_item_class():
	return item_class[get_slot_item()]

func get_slot_item():
	return current_item
	
func get_spell_instance():
	return item_instance_dict[current_item]
	
func set_slot_item(item_name):
	current_item = item_name
	texture = item_texture_dict[current_item]

#DRAGGING FUNCTIONS
func _get_drag_data(_pos):
	if (current_item != "empty" && current_item != "lock" && cooldown_timer.time_left <= 0): #there is item to drag
		var data = {}
		data["original_slot"] = self
		data["original_texture"] = texture
		data["item_type"] = current_item
		
		var drag_texture = TextureRect.new()
		drag_texture.texture = texture
		drag_texture.size = Vector2(get_global_transform().get_scale().x * texture.get_width(), get_global_transform().get_scale().y * texture.get_height())
		set_drag_preview(drag_texture)
		dragging = true
		return data

func _can_drop_data(_pos, data):
	if (data["item_type"] == "lock" || data["original_slot"].cooldown_timer.time_left > 0 || cooldown_timer.time_left > 0):
		return false
	return true
	
func _drop_data(_pos, data):
	data["original_slot"].set_slot_item(get_slot_item())
	data["original_slot"].dragging = false
	set_slot_item(data["item_type"])
	dragging = false

#var mouse_pos = get_global_mouse_position()
#placeholder_item.global_position.x = mouse_pos.x - placeholder_item.texture.get_width() / 2
