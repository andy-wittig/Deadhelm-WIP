extends RigidBody2D

const FLICK_FORCE := .8

var player: CharacterBody2D

func get_sprite_path():
	return $SpellSprite.texture.resource_path

func _ready():
	$SpellSprite.rotation = player.spell_direction.angle()
	global_position = player.spell_spawn.global_position
	apply_central_impulse(player.spell_direction * FLICK_FORCE)

func _process(delta):
	apply_central_impulse(-(player.player_center.global_position - get_global_mouse_position()).normalized() * FLICK_FORCE)

func on_destroy_timer_timeout():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = $SpellSprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.spell_rotation = $SpellSprite.rotation
	get_parent().add_child(disolve_effect)
	queue_free()
