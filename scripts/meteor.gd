extends Area2D

const SPEED = 70.0

var player: CharacterBody2D
var direction: Vector2

@onready var meteor_sprite = $MeteorSprite

func get_sprite_path():
	return $MeteorSprite.texture.resource_path

func _process(delta):
	meteor_sprite.rotation = direction.angle()
	position += direction * SPEED * delta
	
	for body in get_overlapping_bodies():
		if (body.is_in_group("enemies")
		&& multiplayer.is_server()):
			body.hurt_enemy.rpc(15, global_position.x)
			rpc("destroy_self")
	
@rpc("any_peer", "call_local")
func destroy_self():
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_tree().get_root().add_child(impact)
	impact.position = position
	queue_free()
	
func _on_destroy_timer_timeout():
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_tree().get_root().add_child(impact)
	impact.position = position
	queue_free()
	
		
