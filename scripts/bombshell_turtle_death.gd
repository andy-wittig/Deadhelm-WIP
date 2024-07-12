extends Node2D

@onready var chunk_particles = $ChunkParticles

func _ready():
	chunk_particles.emitting = true

func _on_death_audio_finished():
	queue_free()
