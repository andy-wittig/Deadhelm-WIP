extends Node2D

@onready var audio_stream_player = $AudioStreamPlayer2D

func _on_timer_timeout():
	queue_free()
