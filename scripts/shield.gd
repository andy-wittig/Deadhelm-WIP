extends Area2D

const DIAL_RADIUS = 22

var direction : Vector2
var player : CharacterBody2D

@onready var shield_sprite = $ShieldSprite

func get_sprite_path():
	return $ShieldSprite.texture.resource_path
	
func _ready():
	shield_sprite.rotation = direction.angle()

func _on_area_entered(area):
	print ("shield collided!")
	if (area.is_in_group("enemy_projectile")):
		if (multiplayer.is_server()):
			area.rpc("destroy_self")

func _on_destroy_timer_timeout():
	queue_free()
