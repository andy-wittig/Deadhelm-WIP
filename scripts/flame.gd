extends Area2D

const PLAYER_KNOCK_BACK := 6

var player: CharacterBody2D

@onready var flame_orb_sprite = $FlameOrbSprite
@onready var flame_animated_sprite = $FlameAnimatedSprite

func get_sprite_path():
	return $FlameOrbSprite.texture.resource_path
	
func _ready():
	if (GameManager.multiplayer_mode_enabled):
		if (multiplayer.get_unique_id() == player.player_id): 
			set_spell_position()
	else:
		set_spell_position()
	
func _process(_delta):
	if (GameManager.multiplayer_mode_enabled):
		if (multiplayer.get_unique_id() == player.player_id):
			set_spell_position()
	else:
		set_spell_position()

func set_spell_position():
	global_position = player.spell_spawn.global_position
	flame_animated_sprite.rotation = player.spell_direction.angle()
	flame_orb_sprite.rotation = player.spell_direction.angle()
	
	if (player.velocity.y < 0):
		player.apply_knockback(global_position, PLAYER_KNOCK_BACK)

func _on_destroy_timer_timeout():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.player = player
	disolve_effect.spell_texture = $FlameAnimatedSprite.get_sprite_frames().get_frame_texture("flame", 0)
	disolve_effect.spell_offset = $FlameAnimatedSprite.offset
	get_parent().add_child(disolve_effect)
	queue_free()
