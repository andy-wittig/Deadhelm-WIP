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
	rotation = direction.angle()
	scale.y = player.mouse_facing
	global_position = player.spell_spawn.global_position

func _process(delta):
	position += direction * SPEED * delta
	
	for body in get_overlapping_bodies():
		if (body.is_in_group("enemies") && !body.is_in_group("breakable")):
			body.apply_knockback(direction, HAND_FORCE)

func destroy_self():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = hand_sprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.rotation = rotation
	disolve_effect.scale = scale
	get_parent().add_child(disolve_effect)
	disolve_effect.reset_physics_interpolation()
	queue_free()
	
func _on_destroy_timer_timeout():
	destroy_self()	

func _on_ghost_timer_timeout():
	var ghost = ghost_effect.instantiate()
	ghost.sprite_path = "res://assets/sprites/level_objects/spells/phantasmal_push.png"
	ghost.rotation = rotation
	ghost.scale = scale
	ghost.position = position
	get_parent().add_child(ghost)
