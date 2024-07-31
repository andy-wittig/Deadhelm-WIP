extends Area2D

@onready var bulb_light = $BulbLight
@onready var bulb_timer = $BulbTimer
	
@rpc("any_peer", "call_local")
func set_bulb_light():
	bulb_light.enabled = true
	bulb_timer.start()
					
func _on_body_entered(body):
	if (body.is_in_group("players")):
		if (!GameManager.multiplayer_mode_enabled):
			set_bulb_light()
		elif (multiplayer.is_server()):
			rpc("set_bulb_light")

func _on_bulb_timer_timeout():
	bulb_light.enabled = false
