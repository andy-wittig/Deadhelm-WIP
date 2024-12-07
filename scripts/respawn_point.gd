extends Area2D

@export var spawn_point : Node
@export var soul_cost := 2

@onready var respawn_sprite = $RespawnSprite
@onready var soul_label = $SoulLabel
@onready var shrine_chime_audio = $ShrineChimeAudio

var souls_input := 0
var respawn_activated := false

func _process(delta):
	if (souls_input >= soul_cost):
		$OrbSprite.texture = load("res://assets/sprites/level_objects/spawner orb.png")
		spawn_point.global_position = global_position
		respawn_activated = true
	else:
		$SoulLabel.text = str(souls_input) + "/" + str(soul_cost) + " souls"	
	
	respawn_sprite.material.set_shader_parameter("enabled", false)
	soul_label.visible = false
	if (!respawn_activated):
		for body in get_overlapping_bodies():
			if (body.is_in_group("players")):
				respawn_sprite.material.set_shader_parameter("enabled", true)
				soul_label.visible = true
				if (Input.is_action_just_pressed("pickup")):
					use_soul(body)

func use_soul(player):
	if (player.souls_collected > 0):
		player.souls_collected -= 1
		add_soul()
		shrine_chime_audio.play()
		
func add_soul():
	souls_input += 1
