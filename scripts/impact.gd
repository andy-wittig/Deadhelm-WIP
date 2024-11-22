extends Node2D

@onready var destory_audio = $DestoryAudio

func _ready():
	const PITCH_RANGE := 0.3
	var pitch_shift := randf_range(-PITCH_RANGE, PITCH_RANGE)
	destory_audio.pitch_scale = 1 + pitch_shift
	destory_audio.play()

func _on_timer_timeout():
	queue_free()
