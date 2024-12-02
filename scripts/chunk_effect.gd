extends Node2D

@onready var chunk_particles = $ChunkParticles
var particle_texture_path : String

func _ready():
	chunk_particles.texture = load(particle_texture_path)
	chunk_particles.emitting = true

func _on_timer_timeout():
	queue_free()
