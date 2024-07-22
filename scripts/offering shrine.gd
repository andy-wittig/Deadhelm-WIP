extends Node2D

var player = null
var can_interact = false
var souls_input = 0
@export var soul_cost = 10
@export var spell_type = "meteor"
@onready var soul_label = $SoulLabel
@onready var shrine_chime_audio = $ShrineChimeAudio

@rpc("any_peer", "call_local")
func spawn_tome():
	$ShrineSprite.material.set_shader_parameter("enabled", false)
	soul_label.visible = false
	can_interact = false
		
	var tome = load("res://scenes/player/spells/tome.tscn").instantiate()
	tome.spell_type = spell_type
	tome.position = Vector2(position.x, position.y - 16)
	get_parent().add_child(tome)
	
func _ready():
	soul_label.visible = false
	
func _process(delta):
	soul_label.text = str(souls_input) + "/" + str(soul_cost) + " souls"
	
	if (souls_input >= soul_cost):
		if (can_interact):
			if Input.is_action_just_pressed("pickup"):
				souls_input = 0
				if (multiplayer.is_server()):
					rpc("spawn_tome")
				elif (!GameManager.multiplayer_mode_enabled):
					spawn_tome()
	
	if (can_interact):
		if Input.is_action_just_pressed("pickup"):
			can_interact = false
			collect_soul()

func _on_input_event(viewport, event, shape_idx):
	if (Input.is_action_just_pressed("left_click")):
		if (can_interact):
			can_interact = false
			collect_soul()

func _on_detect_player_body_entered(body):
	if (body.get_parent().get_name() == "players"):
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			player = body
			$ShrineSprite.material.set_shader_parameter("enabled", true)
			soul_label.visible = true
			can_interact = true

func _on_detect_player_body_exited(body):
	if (body == player):
		player = null
		$ShrineSprite.material.set_shader_parameter("enabled", false)
		soul_label.visible = false
		can_interact = false
		
func collect_soul():
	if (player.souls_collected > 0):
		player.souls_collected -= 1
		souls_input += 1
		shrine_chime_audio.play()
