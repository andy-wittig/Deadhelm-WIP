extends RigidBody2D

const FLICK_FORCE := 22

var player: CharacterBody2D

func get_sprite_path():
	return $SpellSprite.texture.resource_path

func _ready():
	$SpellSprite.rotation = player.spell_direction.angle()
	global_position = player.spell_spawn.global_position
	apply_central_impulse(player.spell_direction * FLICK_FORCE)

func _physics_process(delta):
	apply_central_impulse(-(global_position - get_global_mouse_position()).normalized() * FLICK_FORCE)

func on_destroy_timer_timeout():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = $SpellSprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.rotation = rotation
	get_parent().add_child(disolve_effect)
	disolve_effect.reset_physics_interpolation()
	
	var explosion = load("res://scenes/player/spells/morning_star_explosion.tscn").instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	player.set_screen_shake(0.8)
	
	queue_free()
