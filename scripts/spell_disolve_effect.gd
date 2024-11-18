extends Node2D

var spell_texture : Texture
var spell_offset : Vector2
var spell_rotation : float
var spell_scale := Vector2(1, 1)
var player : CharacterBody2D

@onready var sprite = $Sprite2D

func _ready():
	sprite.offset = spell_offset
	sprite.texture = spell_texture
	sprite.rotation = spell_rotation
	sprite.scale = spell_scale
	
func _process(_delta):
	if (player != null):
		global_position = player.spell_spawn.global_position
		sprite.rotation = player.spell_direction.angle()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
