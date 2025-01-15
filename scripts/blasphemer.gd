extends Node2D

@export var attack_rate := 4

@onready var hurt_player_area = $HurtPlayerArea
@onready var fire_particles = $FireParticles
@onready var flame_light = $FlameLight
@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer
@onready var fire_audio = $FireAudio

var attacking := false

func _ready():
	get_tree().call_group("unlock_enemy", "unlock_page", 0)
	attack_timer.start(attack_rate)

func _process(_delta):
	if (attacking):
		hurt_player_area.active = true
		flame_light.enabled = true
		fire_particles.emitting = true
		animation_player.play("flame")
		if (!fire_audio.playing):
			$FireAudio/AnimationPlayer.play("audio_start")
	else:
		hurt_player_area.active = false
		flame_light.enabled = false
		fire_particles.emitting = false
		animation_player.play("RESET")
		$FireAudio/AnimationPlayer.play("audio_fade")

func _on_attack_timer_timeout():
	attacking = !attacking
	
