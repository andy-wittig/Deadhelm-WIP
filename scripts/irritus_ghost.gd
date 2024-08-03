extends Node2D

var duration := 0.2

func _ready():
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(self, "modulate:a", 0.0, duration)
	await get_tree().create_timer(duration).timeout
	queue_free()
