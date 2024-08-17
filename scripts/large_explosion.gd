extends Node2D

func _ready():
	$ExplosionParticles.emitting = true
	$ImpactParticles.emitting = true
	$AudioStreamPlayer2D.play()

func _on_destroy_timer_timeout():
	queue_free()
