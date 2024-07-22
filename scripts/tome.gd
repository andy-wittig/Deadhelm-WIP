extends RigidBody2D

var player = null
var can_interact = false
var spell_type: String

@onready var spell_label = $SpellLabel

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _ready():
	spell_label.text = spell_type + " tome"
	spell_label.visible = false
	
func _process(delta):
	if (can_interact && not player.is_inventory_full()):
		if Input.is_action_just_pressed("pickup"):
			player.colllect_spell(spell_type)
			can_interact = false
			if (!GameManager.multiplayer_mode_enabled):
				destroy_self()
			elif (multiplayer.is_server()):
				rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	if (Input.is_action_just_pressed("left_click")):
		if (can_interact && not player.is_inventory_full()):
			player.colllect_spell(spell_type)
			can_interact = false
			if (!GameManager.multiplayer_mode_enabled):
				destroy_self()
			elif (multiplayer.is_server()):
				rpc("destroy_self")

func _on_detect_player_body_entered(body):
	if (body.get_parent().get_name() == "players"):
		if (body.get_name() == "player"
		|| body.player_id == multiplayer.get_unique_id()):
			player = body
			$Sprite2D.material.set_shader_parameter("enabled", true)
			spell_label.visible = true
			can_interact = true

func _on_detect_player_body_exited(body):
	if (body == player):
		player = null
		$Sprite2D.material.set_shader_parameter("enabled", false)
		spell_label.visible = false
		can_interact = false
