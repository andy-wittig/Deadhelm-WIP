extends Area2D

const SPEED := 80.0
const DAMAGE := 15
const KNOCK_BACK := 200

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
			body.hurt_enemy(DAMAGE, direction, KNOCK_BACK)
			destroy_self()

func destroy_self():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	var chunk_effect = load("res://scenes/vfx/chunk_effect.tscn").instantiate()
	chunk_effect.particle_texture_path = "res://assets/sprites/vfx/meteor_pieces.png"
	chunk_effect.blood_effects = false
	chunk_effect.global_position = global_position
	disolve_effect.spell_texture = $MeteorSprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.rotation = rotation
	get_parent().add_child(disolve_effect)
	get_parent().add_child(chunk_effect)
	disolve_effect.reset_physics_interpolation()
	queue_free()
	
func _on_destroy_timer_timeout():
	destroy_self()	
