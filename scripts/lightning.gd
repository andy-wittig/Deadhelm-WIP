extends Area2D

const RADIUS := 22

var player: CharacterBody2D
var direction : Vector2

@onready var lightning_animated_sprite = $LightningAnimatedSprite
@onready var lightning_orb_sprite = $LightningOrbSprite

func get_sprite_path():
	return $LightningOrbSprite.texture.resource_path
	
func _ready():
	set_spell_position()
	
func _process(_delta):
	set_spell_position()

func set_spell_position():
	var mouse_pos = get_global_mouse_position()
	var mouse_dir_x = (mouse_pos.x - player.global_position.x)
	var mouse_dir_y = (mouse_pos.y - (player.global_position.y - 16))
	var mouse_dir = Vector2(mouse_dir_x, mouse_dir_y).normalized()
	global_position.x = player.global_position.x + mouse_dir.x * RADIUS
	global_position.y = player.global_position.y - 16 + mouse_dir.y * RADIUS
	
	lightning_animated_sprite.rotation = mouse_dir.angle()
	lightning_orb_sprite.rotation = mouse_dir.angle()

func _on_destroy_timer_timeout():
	queue_free()
