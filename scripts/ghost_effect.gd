extends Node2D

var duration := 0.2
var sprite_path := ""
var sprite_offset := Vector2.ZERO
var sprite_rotation := 0.0
var sprite_scale := Vector2(1, 1)

@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = load(sprite_path)
	sprite.offset = sprite_offset
	sprite.rotation = sprite_rotation
	sprite.scale = sprite_scale
	
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(self, "modulate:a", 0.0, duration)
	await get_tree().create_timer(duration).timeout
	queue_free()
