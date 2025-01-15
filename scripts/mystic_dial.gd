extends Node2D

var player = null
var placeholder_spell : Sprite2D
var starting_path_pos : Vector2

@onready var spawn_particles = $SpawnParticles
@onready var left_hand_particle = $LeftHandParticle
@onready var right_hand_particle = $RightHandParticle
@onready var spell_origin = $SpellOrigin
@onready var spawn_effect = $SpellOrigin/SpawnEffect
@onready var animation_player = $AnimationPlayer
@onready var destroy_timer = $DestroyTimer

func destroy():
	placeholder_spell.visible = false
	spawn_effect.visible = true
	spawn_effect.play("effect")
	spawn_particles.emitting = true
	left_hand_particle.emitting = true
	right_hand_particle.emitting = true
	animation_player.play("fade_out")
	destroy_timer.start()
	
func _on_destroy_timer_timeout():
	queue_free()
	
func set_placeholder_sprite(sprite_path):
	placeholder_spell.set_texture(load(sprite_path))
	
func _ready():
	global_position = player.player_center.global_position
	placeholder_spell = Sprite2D.new()
	placeholder_spell.modulate.a = 0.8
	add_child(placeholder_spell)
	
func _process(delta):
	#update dials position
	global_position = player.player_center.global_position
	#update spell
	placeholder_spell.global_position = player.spell_spawn.global_position
	placeholder_spell.rotation = player.spell_direction.angle()
	placeholder_spell.scale.y = player.mouse_facing
	
	spell_origin.global_position = player.spell_spawn.global_position
		

func _on_animation_player_animation_finished(anim_name):
	animation_player.play("dial_rotate")
