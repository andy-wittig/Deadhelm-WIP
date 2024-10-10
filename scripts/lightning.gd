extends Area2D

var player: CharacterBody2D

@onready var lightning_animated_sprite = $LightningAnimatedSprite
@onready var lightning_orb_sprite = $LightningOrbSprite

func get_sprite_path():
	return $LightningOrbSprite.texture.resource_path
	
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
	lightning_animated_sprite.rotation = player.spell_direction.angle()
	lightning_orb_sprite.rotation = player.spell_direction.angle()

func _on_destroy_timer_timeout():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.player = player
	disolve_effect.spell_texture = $LightningAnimatedSprite.get_sprite_frames().get_frame_texture("lightning", 0)
	disolve_effect.spell_offset = $LightningAnimatedSprite.offset
	get_parent().add_child(disolve_effect)
	queue_free()
