extends Area2D

@export var coin_amount: int

@onready var chest_closed_sprite = $ChestClosedSprite
@onready var chest_open_sprite = $ChestOpenSprite
@onready var chest_open_audio = $ChestOpenAudio

var chest_open := false

func _process(delta):
	chest_closed_sprite.material.set_shader_parameter("enabled", false)
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			chest_closed_sprite.material.set_shader_parameter("enabled", true)
			if Input.is_action_just_pressed("pickup") && not chest_open:
				open_chest()

func open_chest():
	chest_open_audio.play()
	chest_closed_sprite.visible = false
	chest_open_sprite.visible = true
	chest_open = true
	
	for i in range(coin_amount):
		var coin = load("res://scenes/level_objects/coin.tscn").instantiate()
		coin.global_position = $Marker2D.global_position
		get_tree().get_root().get_node("game/Level").add_child(coin)
