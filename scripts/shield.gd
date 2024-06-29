extends Area2D

var direction : Vector2
var player : CharacterBody2D

@onready var shield_sprite = $ShieldSprite

func get_sprite_path():
	return $ShieldSprite.texture.resource_path
	
func _ready():
	shield_sprite.rotation = direction.angle()

func _process(delta):
	pass

func _on_destroy_timer_timeout():
	queue_free()

func _on_body_entered(body):
	print ("shield collided!")
	if (body.is_in_group("enemy_projectile")):
		#if (multiplayer.is_server()):
		body.rpc("destroy_self")
