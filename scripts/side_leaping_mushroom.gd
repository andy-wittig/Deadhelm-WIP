extends Area2D

@export var bounce_force := 350.0
@export var dir := 1

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.scale.x *= dir

func _on_animated_sprite_2d_animation_finished():
	animated_sprite.frame = 0

func _on_body_entered(body):
	if (body.is_in_group("players")):
		body.knock_back = Vector2(1.0, 0.1) * bounce_force * -dir
		animated_sprite.play("bounce")
		if (!$AudioStreamPlayer2D.playing):
				$AudioStreamPlayer2D.play()
