extends Area2D

@export var required_item: String
@export var totem_list: Array[Node]
@export var totem_control := false
@export var scene: Node
@onready var spell_sprite = $SpellSprite

var active := false
var all_totems_unlocked := false

@onready var item_texture_dict = {
	"empty" : null,
	"meteor" : preload("res://assets/sprites/UI/player_information/placeholder_meteor.png"),
	"shield" : preload("res://assets/sprites/UI/player_information/placeholder_shield.png"),
	"lightning" : preload("res://assets/sprites/UI/player_information/placeholder_lightning.png"),
	"flame" : preload("res://assets/sprites/UI/player_information/placeholder_flame.png"),
	"poison bottle" : preload("res://assets/sprites/UI/player_information/placeholder_poison_bottle.png"),
	"bow" : preload("res://assets/sprites/UI/player_information/placeholder_bow.png"),
}

@onready var totem_sprite = $TotemSprite
@onready var activated_totem_sprite = $ActivatedTotemSprite
@onready var totem_light = $TotemLight

func _ready():
	spell_sprite.texture = item_texture_dict[required_item]

func _process(delta):
	if (totem_control && !all_totems_unlocked):
		all_totems_unlocked = true
		for totem in totem_list:
			if (totem.active == false):
				all_totems_unlocked = false
		if (all_totems_unlocked):
			scene.get_node("AnimationPlayer").play("move")
			
	$SpellSprite.visible = false
	if (!active):
		for body in self.get_overlapping_bodies():
			if (body.is_in_group("players")):
				$SpellSprite.visible = true
			
			if (body.is_in_group("tomes")):
				if (body.spell_type == required_item):
					totem_light.enabled = true
					activated_totem_sprite.visible = true
					totem_sprite.visible = false
					active = true
