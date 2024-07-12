extends Node2D

const DIAL_RADIUS = 22

var player = null
var mouse_dir : Vector2
var placeholder_spell : Sprite2D

@onready var animation_player = $AnimationPlayer

func destroy():
	placeholder_spell.visible = not placeholder_spell.visible
	animation_player.play("fade_out")
	$DestroyTimer.start()
	
func _on_destroy_timer_timeout():
	queue_free()
	
func set_placeholder_sprite(sprite_path):
	placeholder_spell.set_texture(load(sprite_path))
	
func _ready():
	placeholder_spell = Sprite2D.new()
	placeholder_spell.modulate.a = 0.75
	add_child(placeholder_spell)
	
func _process(_delta):
	#update dials position
	global_position.x = player.global_position.x
	global_position.y = player.global_position.y - 16
	
	#update spells position
	var mouse_pos = get_global_mouse_position()
	mouse_dir = (mouse_pos - global_position).normalized()
	placeholder_spell.position = mouse_dir * DIAL_RADIUS
	placeholder_spell.rotation = mouse_dir.angle()

