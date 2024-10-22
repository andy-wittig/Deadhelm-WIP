extends Node2D

const duration := 0.8

var damage_amount: int
var damage_indicator_color: String

@onready var damage_label = $DamageLabel

func _ready():
	damage_label.text = str(damage_amount)
	damage_label.position -= Vector2(0, 16)
	damage_label.add_theme_font_size_override("font_size", 8)
	damage_label.add_theme_color_override("font_color", Color(damage_indicator_color, 1.0))
	create_position_tween()
	
func create_position_tween():
	var position_tween = get_tree().create_tween()
	var alpha_tween = get_tree().create_tween()
	position_tween.tween_property(damage_label, "position", damage_label.position - Vector2(0, 24), duration)
	alpha_tween.tween_property(damage_label, "modulate", Color(damage_indicator_color, .2), duration)
	await get_tree().create_timer(duration).timeout
	queue_free()
