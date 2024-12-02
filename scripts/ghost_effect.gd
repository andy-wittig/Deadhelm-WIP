extends Node2D

var duration := 0.2
var sprite_path := ""

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = load(sprite_path)
	
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(self, "modulate:a", 0.0, duration)
	await get_tree().create_timer(duration).timeout
	queue_free()
