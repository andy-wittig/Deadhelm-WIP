extends Area2D

@export var coin_amount: int

@onready var chest_closed_sprite = $ChestClosedSprite
@onready var chest_open_sprite = $ChestOpenSprite

var chest_open := false

func _process(delta):
	chest_closed_sprite.material.set_shader_parameter("enabled", false)
	for body in get_overlapping_bodies():
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			chest_closed_sprite.material.set_shader_parameter("enabled", true)
			if Input.is_action_just_pressed("pickup") && not chest_open:
				rpc("open_chest")

func _on_input_event(viewport, event, shape_idx):
	for body in get_overlapping_bodies():
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			if (Input.is_action_just_pressed("left_click") && not chest_open):
				rpc("open_chest")
				
@rpc("any_peer", "call_local")
func open_chest():
	chest_closed_sprite.visible = false
	chest_open_sprite.visible = true
	chest_open = true
	for i in range(coin_amount):
		var coin = load("res://scenes/level_objects/coin.tscn").instantiate()
		coin.position = position
		get_tree().get_root().get_node("game/Level").add_child(coin)
