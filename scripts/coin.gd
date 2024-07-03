extends RigidBody2D

const y_force = -250
var rand_x_force = randf_range(-100, 100)

var player = null
var can_interact = false

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _on_timer_timeout():
	queue_free()

func _ready():
	apply_central_impulse(Vector2(rand_x_force, y_force))

func _process(delta):
	if (can_interact):
		if Input.is_action_just_pressed("pickup"):
			player.collect_coin()
			can_interact = false
			rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	if (Input.is_action_just_pressed("left_click")):
		if (can_interact):
			player.collect_coin()
			can_interact = false
			rpc("destroy_self")

func _on_detect_player_body_entered(body):
	if (body.is_in_group("players")):
			$AnimatedSprite2D.material.set_shader_parameter("enabled", true)
			player = body
			can_interact = true

func _on_detect_player_body_exited(body):
	if (body == player):
		$AnimatedSprite2D.material.set_shader_parameter("enabled", false)
		player = null
		can_interact = false
