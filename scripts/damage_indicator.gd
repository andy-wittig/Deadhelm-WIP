extends Node2D

const duration := 0.8

var damage_amount: int

@onready var damage_label = $DamageLabel

func _ready():
	damage_label.text = str("-", damage_amount)
	damage_label.position -= Vector2(0, 32)
	damage_label.add_theme_font_size_override("font_size", 8)
	create_position_tween()
	
func create_position_tween():
	var position_tween = get_tree().create_tween()
	var alpha_tween = get_tree().create_tween()
	position_tween.tween_property(damage_label, "position", damage_label.position - Vector2(0, 24), duration)
	alpha_tween.tween_property(damage_label, "modulate", Color(1, 1, 1, .2), duration)
	await get_tree().create_timer(duration).timeout
	queue_free()
