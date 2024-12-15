extends Node2D

var player = null
var placeholder_spell : Sprite2D
var path_started := false
var starting_path_pos : Vector2

@onready var animation_player = $AnimationPlayer
@onready var mystic_particles = $MysticParticles
@onready var path_particle_1 = $ParticleOrigin/PathParticle1
@onready var path_particle_2 = $ParticleOrigin/PathParticle2
@onready var particle_origin = $ParticleOrigin
@onready var spawn_effect = $SpawnEffect
@onready var destroy_timer = $DestroyTimer

func destroy():
	placeholder_spell.visible = false
	spawn_effect.visible = true
	spawn_effect.play("effect")
	path_particle_1.emitting = true
	path_particle_2.emitting = true
	path_started = true
	animation_player.play("fade_out")
	destroy_timer.start()
	
func _on_destroy_timer_timeout():
	queue_free()
	
func set_placeholder_sprite(sprite_path):
	placeholder_spell.set_texture(load(sprite_path))
	
func _ready():
	global_position = player.player_center.global_position
	placeholder_spell = Sprite2D.new()
	placeholder_spell.modulate.a = 0.6
	add_child(placeholder_spell)
	
func _process(delta):
	#update dials position
	global_position = player.player_center.global_position
	#update spell
	placeholder_spell.global_position = player.spell_spawn.global_position
	placeholder_spell.rotation = player.spell_direction.angle()
	placeholder_spell.scale.y = player.mouse_facing
	
	mystic_particles.global_position = player.spell_spawn.global_position
	spawn_effect.global_position = player.spell_spawn.global_position
	
	if (path_started):
		particle_origin.rotation += 10 * delta
		
