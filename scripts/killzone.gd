extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if (body.name == "player" || body.get_parent().get_name() == "players") && multiplayer.is_server():
		Engine.time_scale = 0.5
		timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
