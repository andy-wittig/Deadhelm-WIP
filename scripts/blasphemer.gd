extends Node2D

@export var attack_rate := 4

@onready var hurt_player_area = $HurtPlayerArea
@onready var fire_particles = $FireParticles
@onready var flame_light = $FlameLight
@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer

func _ready():
	attack_timer.start(attack_rate)

func _on_attack_timer_timeout():
	hurt_player_area.active = not hurt_player_area.active
	flame_light.enabled = not flame_light.enabled
	
	if (hurt_player_area.active):
		animation_player.play("flame")
		fire_particles.emitting = true
	else:
		animation_player.play("RESET")
		fire_particles.emitting = false
	
