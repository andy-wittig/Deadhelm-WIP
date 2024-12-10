extends RigidBody2D

const FORCE_AMOUNT := 20
var dir : int
var lifetime := 6

@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D
@onready var destroy_timer = $DestroyTimer

func _ready():
	destroy_timer.start(lifetime)
	apply_central_impulse(Vector2(FORCE_AMOUNT * 2 * dir, 0))
	add_constant_central_force(Vector2(FORCE_AMOUNT * dir, 0))

func _on_destroy_timer_timeout():
	animation_player.play("fade_out")
	collision_shape.disabled = true

func _on_animation_player_animation_finished(anim_name):
	queue_free()
