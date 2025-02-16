extends RigidBody2D

@export var spell_type: String

var can_collect := true
var player = null

@onready var spell_label = $SpellLabel
@onready var detect_player = $DetectPlayer
@onready var sprite = $Sprite2D
	
func _ready():
	spell_label.text = spell_type.replace("_", " ")
	spell_label.visible = false
	
func _process(delta):
	sprite.material.set_shader_parameter("enabled", false)
	spell_label.visible = false
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			sprite.material.set_shader_parameter("enabled", true)
			spell_label.visible = true
			if (Input.is_action_just_pressed("pickup")
			&& not body.is_inventory_full() && can_collect):
				body.colllect_spell(spell_type)
				can_collect = false
				call_deferred("queue_free")
