extends Node2D

var player = null
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
	placeholder_spell.modulate.a = 0.8
	add_child(placeholder_spell)
	
func _process(_delta):
	#update dials position
	global_position.x = player.global_position.x
	global_position.y = player.global_position.y
	
	#update spells position
	placeholder_spell.global_position = player.spell_spawn.global_position
	placeholder_spell.rotation = player.spell_direction.angle()

