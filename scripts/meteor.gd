extends Area2D

const SPEED := 70.0

var player: CharacterBody2D
var direction: Vector2

@onready var meteor_sprite = $MeteorSprite

func get_sprite_path():
	return $MeteorSprite.texture.resource_path
	
func _ready():
	direction = player.spell_direction
	position = player.spell_spawn.global_position

func _process(delta):
	meteor_sprite.rotation = direction.angle()
	position += direction * SPEED * delta
	
	for body in get_overlapping_bodies():
		if (body.is_in_group("enemies")):
			body.hurt_enemy(15, direction, 200)
			destroy_self()
	
@rpc("any_peer", "call_local")
func destroy_self():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = $MeteorSprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.spell_rotation = $MeteorSprite.rotation
	get_parent().add_child(disolve_effect)
	queue_free()
	
func _on_destroy_timer_timeout():
	destroy_self()	
