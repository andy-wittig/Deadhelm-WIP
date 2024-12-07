extends RigidBody2D

var can_collect := true
const y_force := -250
var rand_x_force := randf_range(-100, 100)

@onready var detect_player = $DetectPlayer
@onready var animated_sprite = $AnimatedSprite2D

func destroy_self():
	var pickup_effect = load("res://scenes/vfx/item_pickup.tscn").instantiate()
	pickup_effect.global_position = global_position
	get_parent().add_child(pickup_effect)
	queue_free()
	
func _on_timer_timeout():
	queue_free()

func _ready():
	apply_central_impulse(Vector2(rand_x_force, y_force))

func _process(delta):
	animated_sprite.material.set_shader_parameter("enabled", false)
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			animated_sprite.material.set_shader_parameter("enabled", true)
			if (Input.is_action_just_pressed("pickup") && can_collect):
				body.collect_coin()
				can_collect = false
				destroy_self()
