extends Area2D

class_name BaseNPC

@export var NPC_sprite : AnimatedSprite2D
@export var NPC_collider : Area2D
@export var npc_text_path : String
@export var headshot_texture : Texture2D

func _process(delta):
	NPC_sprite.material.set_shader_parameter("enabled", false)
	for body in NPC_collider.get_overlapping_bodies():
		if (body.is_in_group("players")):
			NPC_sprite.material.set_shader_parameter("enabled", true)
			if (Input.is_action_just_pressed("pickup")):
				get_tree().call_group("textbox", "open_textbox", npc_text_path, headshot_texture)
