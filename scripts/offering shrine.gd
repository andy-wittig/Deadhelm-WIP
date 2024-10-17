extends Node2D

var player = null
var souls_input := 0
var can_interact := true

@export var soul_cost := 10
@export var spell_type: String
@export var random := false

@onready var soul_label = $SoulLabel
@onready var shrine_chime_audio = $ShrineChimeAudio
@onready var detect_player = $DetectPlayer
@onready var sprite = $ShrineSprite

@rpc("any_peer", "call_local")
func spawn_tome():
	var tome = load("res://scenes/player/spells/tome.tscn").instantiate()
	tome.spell_type = spell_type
	tome.position = Vector2(position.x, position.y - 16)
	get_parent().add_child(tome)
	
func _ready():
	soul_label.visible = false
	
func _process(delta):
	soul_label.text = str(souls_input) + "/" + str(soul_cost) + " souls\n" + spell_type + " spell"
	sprite.material.set_shader_parameter("enabled", false)
	soul_label.visible = false
	
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players") && can_interact):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				sprite.material.set_shader_parameter("enabled", true)
				soul_label.visible = true
				if (Input.is_action_just_pressed("pickup")):
					if (souls_input >= soul_cost):
						can_interact = false
						$BuyTimer.start()
						souls_input = 0
						if (multiplayer.is_server()):
							rpc("spawn_tome")
						elif (!GameManager.multiplayer_mode_enabled):
							spawn_tome()
					else:
						collect_soul(body)

func collect_soul(body):
	if (body.souls_collected > 0):
		body.souls_collected -= 1
		souls_input += 1
		shrine_chime_audio.play()

func _on_buy_timer_timeout():
	can_interact = true
