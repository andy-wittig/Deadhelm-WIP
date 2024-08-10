extends StaticBody2D

const SPEED = 90.0

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
			if (multiplayer.is_server()):
				body.hurt_enemy.rpc(20, global_position, 200)
				rpc("destroy_self")
			elif (!GameManager.multiplayer_mode_enabled):
				body.hurt_enemy(20, global_position, 200)
				destroy_self()
	
@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _on_destroy_timer_timeout():
	destroy_self()	
