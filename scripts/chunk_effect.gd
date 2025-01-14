extends Node2D

@onready var chunk_particles = $ChunkParticles
@onready var blood_particles = $BloodParticles

var blood_effects := true
var particle_texture_path : String = "res://assets/sprites/vfx/soul_pieces.png"

func _ready():
	chunk_particles.texture = load(particle_texture_path)
	chunk_particles.emitting = true
	if (blood_effects):
		blood_particles.emitting = true

func _on_timer_timeout():
	queue_free()
