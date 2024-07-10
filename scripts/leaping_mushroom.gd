extends Area2D

@export var bounce_force = -350.0
@onready var animated_sprite_2d = $AnimatedSprite2D

func _process(delta):
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!body.grounded):
				body.velocity.y = bounce_force
				animated_sprite_2d.play("bounce")

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.frame = 0
