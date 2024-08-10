extends Area2D

const LIFE_TIME := 8

@onready var hurt_enemy_area = $hurt_enemy_area
@onready var destroy_timer = $DestroyTimer

func _ready():
	await get_tree().create_timer(LIFE_TIME / 2).timeout
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(self, "modulate:a", 0.1, LIFE_TIME / 2)
	await get_tree().create_timer(LIFE_TIME / 2).timeout
	queue_free()
