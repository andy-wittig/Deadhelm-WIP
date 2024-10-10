extends Node2D

var spell_texture : Texture
var spell_offset : Vector2
var spell_rotation : float
var player : CharacterBody2D

func _ready():
	$Sprite2D.offset = spell_offset
	$Sprite2D.texture = spell_texture
	$Sprite2D.rotation = spell_rotation
	
func _process(_delta):
	if (player != null):
		global_position = player.spell_spawn.global_position
		$Sprite2D.rotation = player.spell_direction.angle()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
