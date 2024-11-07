extends StaticBody2D

var breaking := false

func _process(_delta):
	for body in $Area2D.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!breaking):
				$AnimationPlayer.play("break")
				breaking = true
		
func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "break"):
		$ResetTimer.start()
	
	if (anim_name == "fade_in"):
		breaking = false

func _on_reset_timer_timeout():
	$AnimationPlayer.play("fade_in")
