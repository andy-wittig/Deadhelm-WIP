extends RigidBody2D

var can_collect := true

@onready var sprite = $Sprite2D
@onready var detect_player = $DetectPlayer

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _process(delta):
	sprite.material.set_shader_parameter("enabled", false)
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup") && can_collect):
					body.collect_soul()
					can_collect = false
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("left_click") && can_collect):
					body.collect_soul()
					can_collect = false
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")
