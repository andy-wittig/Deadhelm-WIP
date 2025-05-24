extends Area2D

class_name BaseNPC

@export var NPC_sprite : AnimatedSprite2D
@export var NPC_collider : Area2D
@export var quest_start_text_path : String
@export var quest_end_text_path : String
@export var headshot_texture : Texture2D

@onready var quest_icon = $QuestIcon

var quest_unlocked := false
var quest_finished := false

func _process(delta):
	NPC_sprite.material.set_shader_parameter("enabled", false)
	for body in NPC_collider.get_overlapping_bodies():
		if (body.is_in_group("players")):
			NPC_sprite.material.set_shader_parameter("enabled", true)
			if (Input.is_action_just_pressed("pickup")):
				if (!quest_finished):
					get_tree().call_group("textbox", "open_textbox", quest_start_text_path, headshot_texture)
				else:
					get_tree().call_group("textbox", "open_textbox", quest_end_text_path, headshot_texture)
				
func unlock_quest():
	if (!quest_unlocked):
		quest_unlocked = true
		quest_icon.texture = preload("res://assets/sprites/npcs/quest_start_icon.png")
		quest_icon.visible = true

func complete_quest():
	quest_icon.texture = preload("res://assets/sprites/npcs/quest_accepted_icon.png")
	quest_finished = true
