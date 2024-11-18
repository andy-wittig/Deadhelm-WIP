extends Area2D

const SPEED := 50.0
const HAND_FORCE := 50.0

var player: CharacterBody2D
var direction: Vector2
var ghost_effect = preload("res://scenes/vfx/ghost_effect.tscn")

@onready var hand_sprite = $HandSprite

func get_sprite_path():
	return $HandSprite.texture.resource_path
	
func _ready():
	direction = player.spell_direction
	hand_sprite.rotation = direction.angle()
	hand_sprite.scale.y = player.mouse_facing
	position = player.spell_spawn.global_position

func _process(delta):
	position += direction * SPEED * delta
	
	for body in get_overlapping_bodies():
		if (body.is_in_group("enemies")):
			body.apply_knockback(direction, HAND_FORCE)
	
@rpc("any_peer", "call_local")
func destroy_self():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = hand_sprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.spell_rotation = hand_sprite.rotation
	disolve_effect.spell_scale = hand_sprite.scale
	get_parent().add_child(disolve_effect)
	queue_free()
	
func _on_destroy_timer_timeout():
	destroy_self()	

func _on_ghost_timer_timeout():
	var ghost = ghost_effect.instantiate()
	ghost.sprite_path = "res://assets/sprites/level_objects/spells/phantasmal_push.png"
	ghost.sprite_offset = Vector2(0, 0)
	ghost.sprite_rotation = hand_sprite.rotation
	ghost.sprite_scale = hand_sprite.scale
	ghost.position = position
	get_parent().add_child(ghost)
