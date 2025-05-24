extends Node2D

@export var AMOUNT_TO_KILL := 3
@export var quest_item : PackedScene

var killed := 0
var quest_item_given := false

func _process(_delta):
	if (quest_item != null):
		if (get_parent().quest_unlocked && !quest_item_given):
			var item = quest_item.instantiate()
			item.position = position
			item.spell_type = "lightning"
			get_parent().add_child(item)
			quest_item_given = true
		
	if (killed >= AMOUNT_TO_KILL && get_parent().quest_unlocked):
		get_parent().complete_quest()
		queue_free()

func enemy_killed():
	if (get_parent().quest_unlocked):
		killed += 1
