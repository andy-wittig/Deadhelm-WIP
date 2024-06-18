extends RigidBody2D

var player = null
var can_interact = false

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _process(delta):
	if (can_interact):
		if Input.is_action_just_pressed("pickup"):
			player.collect_soul()
			can_interact = false
			rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	if (Input.is_action_just_pressed("left_click")):
		if (can_interact):
			player.collect_soul()
			can_interact = false
			rpc("destroy_self")

func _on_detect_player_body_entered(body):
	if (body.get_parent().get_name() == "players"):
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			player = body
			$Sprite2D.material.set_shader_parameter("enabled", true)
			can_interact = true

func _on_detect_player_body_exited(body):
	if (body == player):
		player = null
		$Sprite2D.material.set_shader_parameter("enabled", false)
		can_interact = false
