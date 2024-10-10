extends Area2D

var player: CharacterBody2D

@onready var shield_sprite = $ShieldSprite
@onready var shield_sound = $ShieldSound

func get_sprite_path():
	return $ShieldSprite.texture.resource_path
	
func _ready():
	shield_sprite.rotation = player.spell_direction.angle()
	global_position = player.spell_spawn.global_position

func _on_area_entered(area):
	if (area.is_in_group("enemy_projectile")):
		if (!GameManager.multiplayer_mode_enabled):
			area.destroy_self()
		elif (multiplayer.is_server()):
			area.rpc("destroy_self")

func _on_destroy_timer_timeout():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = $ShieldSprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.spell_rotation = $ShieldSprite.rotation
	get_parent().add_child(disolve_effect)
	queue_free()
