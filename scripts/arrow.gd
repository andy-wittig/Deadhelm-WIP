extends StaticBody2D

const SPEED := 100.0
const DAMAGE := 20
const KNOCK_BACK := 200

var player: CharacterBody2D
var direction: Vector2

@onready var arrow_sprite = $ArrowSprite
@onready var ray_cast = $RayCast2D

func get_sprite_path():
	return $BowSprite.texture.resource_path
	
func _ready():
	direction = player.spell_direction
	rotation = direction.angle()
	position = player.spell_spawn.global_position

func _process(delta):
	if (!ray_cast.is_colliding()):
		position += direction * SPEED * delta
	
	for body in $Area2D.get_overlapping_bodies():
		if (body.is_in_group("enemies")):
			body.hurt_enemy(DAMAGE, direction, KNOCK_BACK)
			destroy_self()

func destroy_self():
	queue_free()
	
func _on_destroy_timer_timeout():
	var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect.spell_texture = $ArrowSprite.texture
	disolve_effect.global_position = global_position
	disolve_effect.rotation = rotation
	get_parent().add_child(disolve_effect)
	disolve_effect.reset_physics_interpolation()
	destroy_self()	
