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
			if (multiplayer.is_server()):
				body.hurt_enemy.rpc(15, global_position, 200)
				rpc("destroy_self")
			elif (!GameManager.multiplayer_mode_enabled):
				body.hurt_enemy(15, global_position, 200)
				destroy_self()
	
@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _on_destroy_timer_timeout():
	destroy_self()	
