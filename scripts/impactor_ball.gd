extends RigidBody2D

const FORCE_AMOUNT := 18
var dir : int

@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

func _ready():
	add_constant_central_force(Vector2(FORCE_AMOUNT * dir, 0))

func _on_destroy_timer_timeout():
	animation_player.play("fade_out")
	collision_shape.disabled = true

func _on_animation_player_animation_finished(anim_name):
	queue_free()
