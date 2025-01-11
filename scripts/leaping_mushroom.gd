extends Area2D

@export var bounce_force := -350.0
@onready var animated_sprite_2d = $AnimatedSprite2D

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.frame = 0

func _on_body_entered(body):
	if (body.is_in_group("players")):
			body.velocity.y = bounce_force
			animated_sprite_2d.play("bounce")
			$AudioStreamPlayer2D.play()
