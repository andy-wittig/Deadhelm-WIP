extends Area2D

@export var soul_cost: int

var souls_input := 0
var portal_activated := false

@onready var portal_active = $PortalActive
@onready var soul_label = $SoulLabel
@onready var shrine_chime_audio = $ShrineChimeAudio
@onready var gate_sprite = $GateSprite

func _ready():
	portal_active.visible = false
	
func _process(delta):
	if (souls_input >= soul_cost):
		portal_active.visible = true
		soul_label.text = "delve deeper"
	else:
		soul_label.text = str(souls_input) + "/" + str(soul_cost) + " souls"
	
	gate_sprite.material.set_shader_parameter("enabled", false)
	soul_label.visible = false
	for body in get_overlapping_bodies():
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			gate_sprite.material.set_shader_parameter("enabled", true)
			soul_label.visible = true
			if Input.is_action_just_pressed("pickup"):
				if (not portal_activated && souls_input < soul_cost):
					collect_soul(body)

func _on_input_event(viewport, event, shape_idx):
	for body in get_overlapping_bodies():
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			if (Input.is_action_just_pressed("left_click")):
				if (not portal_activated && souls_input < soul_cost):
					collect_soul(body)
	
func collect_soul(player):
	if (player.souls_collected > 0):
		player.souls_collected -= 1
		souls_input += 1
		shrine_chime_audio.play()
