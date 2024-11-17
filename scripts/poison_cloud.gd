extends Node2D

const LIFE_TIME := 8

func _ready():
	await get_tree().create_timer(LIFE_TIME / 2).timeout
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(self, "modulate:a", 0.1, LIFE_TIME / 2)
	await get_tree().create_timer(LIFE_TIME / 2).timeout
	queue_free()
