extends Area2D

@export var offset := 0
@export var cooldown := 4

var attack_started := false
var timer_started := false

func _process(delta):
	if (offset > 0):
		offset -= delta
	elif (!timer_started):
		$AttackTimer.start(cooldown)
		$AttackTimer.wait_time = cooldown
		timer_started = true
		
	if ($AnimatedSprite2D.animation == "attack"):
		if ($AnimatedSprite2D.frame == 1):
			$HurtPlayerArea.active = true
		elif ($AnimatedSprite2D.frame == 4):
			$HurtPlayerArea.active = false
	
func _on_attack_timer_timeout():
	$AnimatedSprite2D.play("attack")
	attack_started = true
	
func _on_animated_sprite_2d_animation_finished():
	if (attack_started):
		$AnimatedSprite2D.play("idle")
		attack_started = false
