extends Area2D

var player: CharacterBody2D

@onready var lightning_animated_sprite = $LightningAnimatedSprite
@onready var lightning_orb_sprite = $LightningOrbSprite

func get_sprite_path():
	return $LightningOrbSprite.texture.resource_path
	
func _ready():
	if (multiplayer.get_unique_id() == player.player_id):
		set_spell_position()
	
func _process(_delta):
	if (multiplayer.get_unique_id() == player.player_id):
		set_spell_position()

func set_spell_position():
	global_position = Vector2(player.spell_spawn.global_position.x, player.spell_spawn.global_position.y - 16)
	lightning_animated_sprite.rotation = player.spell_direction.angle()
	lightning_orb_sprite.rotation = player.spell_direction.angle()

func _on_destroy_timer_timeout():
	queue_free()
