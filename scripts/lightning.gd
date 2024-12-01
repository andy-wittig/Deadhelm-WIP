extends Area2D

var player: CharacterBody2D
var fading := true

@onready var lightning_animated_sprite = $LightningAnimatedSprite
@onready var lightning_orb_sprite = $LightningOrbSprite
@onready var ray_cast = $RayCast2D
@onready var point_light = $PointLight2D
@onready var animation_player = $AnimationPlayer
@onready var enemy_collider = $hurt_enemy_area/EnemyCollider
@onready var cpu_particles = $CPUParticles2D

func get_sprite_path():
	return $LightningOrbSprite.texture.resource_path
	
func _ready():
	set_spell_position()

func _process(_delta):
	if (ray_cast.is_colliding()):
		enemy_collider.disabled = true
		cpu_particles.emitting = false
		if (fading):
			animation_player.play_backwards("fade")
			fading = false
	else:
		enemy_collider.disabled = false
		cpu_particles.emitting = true
		if (!fading):
			animation_player.play("fade")
			fading = true
	
	set_spell_position()

func set_spell_position():
	global_position = player.spell_spawn.global_position
	rotation = player.spell_direction.angle()

func _on_destroy_timer_timeout():
	if (!ray_cast.is_colliding()):
		var disolve_effect = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
		disolve_effect.player = player
		disolve_effect.spell_texture = $LightningAnimatedSprite.get_sprite_frames().get_frame_texture("lightning", 0)
		disolve_effect.spell_offset = $LightningAnimatedSprite.offset
		get_parent().add_child(disolve_effect)
	
	var disolve_effect2 = load("res://scenes/vfx/spell_disolve_effect.tscn").instantiate()
	disolve_effect2.player = player
	disolve_effect2.spell_texture = $LightningOrbSprite.get_texture()
	disolve_effect2.spell_rotation = rotation
	get_parent().add_child(disolve_effect2)
	queue_free()
