extends Node2D

@onready var hurt_player_area = $HurtPlayerArea
@onready var fire_particles = $FireParticles
@onready var animation_player = $AnimationPlayer

func _on_attack_timer_timeout():
	hurt_player_area.active = not hurt_player_area.active
	
	if (hurt_player_area.active):
		animation_player.play("flame")
		fire_particles.emitting = true
	else:
		animation_player.play("RESET")
		fire_particles.emitting = false
	
