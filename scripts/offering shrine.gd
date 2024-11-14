extends Node2D

var player = null
var souls_input := 0
var uses := 0
var can_interact := true

@export var soul_cost := 10
@export var use_limit := 1
@export var spell_type: String
@export var random_drop_enabled := false
@export var drop_list: Array[String]

@onready var soul_label = $SoulLabel
@onready var shrine_chime_audio = $ShrineChimeAudio
@onready var detect_player = $DetectPlayer
@onready var sprite = $ShrineSprite

@rpc("any_peer", "call_local")
func spawn_tome():
	if (random_drop_enabled):
		spell_type = drop_list[randi_range(0, drop_list.size() - 1)]
	
	var tome = load("res://scenes/player/spells/tome.tscn").instantiate()
	tome.spell_type = spell_type
	tome.position = Vector2(position.x, position.y - 16)
	get_parent().add_child(tome)
	
func _ready():
	soul_label.visible = false
	$DiceSprite.visible = random_drop_enabled
	
func _process(delta):
	if (uses >= use_limit):
		$ShrineSprite.texture = load("res://assets/sprites/level_objects/offering shrine disabled.png")
		$CPUParticles2D.emitting = false
		$CPUParticles2D2.emitting = false
		$PointLight2D.visible = false
		$PointLight2D2.visible = false
		set_process(false)
		
	if (random_drop_enabled):
		soul_label.text = str(souls_input) + "/" + str(soul_cost) + " souls\n" + "unkown"
	else:
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
						$ShrineSprite.texture = load("res://assets/sprites/level_objects/offering shrine disabled.png")
						$BuyTimer.start()
						souls_input = 0
						uses += 1
						spawn_tome()
					else:
						collect_soul(body)

func collect_soul(body):
	if (body.souls_collected > 0):
		body.souls_collected -= 1
		souls_input += 1
		shrine_chime_audio.play()

func _on_buy_timer_timeout():
	if (uses < use_limit):
		$ShrineSprite.texture = load("res://assets/sprites/level_objects/offering shrine.png")
		can_interact = true
