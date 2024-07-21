extends Node2D

const FLOAT_SPEED := 100
var velocity: Vector2

func _process(delta):
	var hor_direction = Input.get_axis("move_left", "move_right")
	var ver_direction = Input.get_axis("move_up", "move_down")
	
	velocity = lerp(velocity, Vector2(hor_direction, ver_direction).normalized() * FLOAT_SPEED, 0.1)
	position += velocity * delta
