extends RigidBody2D

const y_force = -250
var rand_x_force = randf_range(-100, 100)

@onready var detect_player = $DetectPlayer
@onready var animated_sprite = $AnimatedSprite2D

@rpc("any_peer", "call_local", "reliable")
func destroy_self():
	queue_free()
	
func _on_timer_timeout():
	queue_free()

func _ready():
	if (multiplayer.is_server()):
		apply_central_impulse(Vector2(rand_x_force, y_force))

func _process(delta):
	animated_sprite.material.set_shader_parameter("enabled", false)
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				animated_sprite.material.set_shader_parameter("enabled", true)
				if Input.is_action_just_pressed("pickup"):
					body.collect_coin()
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("left_click")):
					body.collect_coin()
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")
