extends RigidBody2D

@export var spell_type: String

var can_collect := true
var player = null

@onready var spell_label = $SpellLabel
@onready var detect_player = $DetectPlayer
@onready var sprite = $Sprite2D

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func _ready():
	spell_label.text = spell_type + " tome"
	spell_label.visible = false
	
func _process(delta):
	sprite.material.set_shader_parameter("enabled", false)
	spell_label.visible = false
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				sprite.material.set_shader_parameter("enabled", true)
				spell_label.visible = true
				if (Input.is_action_just_pressed("pickup")
				&& not body.is_inventory_full() && can_collect):
					body.colllect_spell(spell_type)
					can_collect = false
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("left_click")
				&& not body.is_inventory_full() && can_collect):
					body.colllect_spell(spell_type)
					can_collect = false
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")
