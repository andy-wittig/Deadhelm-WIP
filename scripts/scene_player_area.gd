extends Area2D

@export var scene: Node
@export var animation_name: String
@export var play_once : bool

var triggered := false

func _process(delta):
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (play_once):
				if (!triggered):
					scene.get_node("AnimationPlayer").play(animation_name)
					triggered = true
			else:
				scene.get_node("AnimationPlayer").play(animation_name)
