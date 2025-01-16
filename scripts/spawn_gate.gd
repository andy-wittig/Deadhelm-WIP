extends Area2D

@export var next_level: PackedScene
@export var soul_cost: int

var souls_input := 0
var portal_activated := false

@onready var portal_active = $PortalActive
@onready var soul_label = $SoulLabel
@onready var shrine_chime_audio = $ShrineChimeAudio
@onready var gate_sprite = $GateSprite
@onready var portal_audio = $PortalAudio

func _process(delta):
	if (souls_input >= soul_cost):
		$PortalActive/PortalWarpTexture.visible = true
		$PortalActive/PortalGlowLight.visible = true
		$PortalActive/PortalActiveParticle.emitting = true
		$PortalActive/PortalActiveParticle2.emitting = true
		if (!portal_audio.playing):
			portal_audio.play()
		
		soul_label.text = "delve beyond"
		portal_activated = true
	else:
		soul_label.text = str(souls_input) + "/" + str(soul_cost) + " souls"
	
	gate_sprite.material.set_shader_parameter("enabled", false)
	soul_label.visible = false
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			gate_sprite.material.set_shader_parameter("enabled", true)
			soul_label.visible = true
			if Input.is_action_just_pressed("pickup"):
				if (not portal_activated && souls_input < soul_cost):
					use_soul(body)
				elif (portal_activated):
					enter_portal(body)
		
func use_soul(player):
	if (player.souls_collected > 0):
		$BlueFlameParticle.emitting = true
		shrine_chime_audio.play()
		
		player.souls_collected -= 1
		add_soul()
		
func enter_portal(body):
	body.save_player_info()
	get_tree().get_root().get_node("game").change_level(next_level)
		
func add_soul():
	souls_input += 1
