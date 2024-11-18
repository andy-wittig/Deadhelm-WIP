extends Node2D

var player = null
var placeholder_spell : Sprite2D

@onready var animation_player = $AnimationPlayer
@onready var mystic_particles = $MysticParticles
@onready var mystic_path_particles1 = $ParticlePath1/PathFollow2D/MysticPathParticles
@onready var mystic_path_particles2 = $ParticlePath2/PathFollow2D/MysticPathParticles
@onready var spawn_effect = $SpawnEffect

func destroy():
	placeholder_spell.visible = false
	spawn_effect.visible = true
	spawn_effect.play("effect")
	mystic_path_particles1.emitting = true
	mystic_path_particles2.emitting = true
	animation_player.play("fade_out")
	$DestroyTimer.start()
	
func _on_destroy_timer_timeout():
	queue_free()
	
func set_placeholder_sprite(sprite_path):
	placeholder_spell.set_texture(load(sprite_path))
	
func _ready():
	placeholder_spell = Sprite2D.new()
	placeholder_spell.modulate.a = 0.6
	add_child(placeholder_spell)
	
func _process(_delta):
	#update dials position
	global_position.x = player.player_center.global_position.x
	global_position.y = player.player_center.global_position.y
	#update spells position
	placeholder_spell.global_position = player.spell_spawn.global_position
	mystic_particles.global_position = player.spell_spawn.global_position
	spawn_effect.global_position = player.spell_spawn.global_position
	#update rotation
	placeholder_spell.rotation = player.spell_direction.angle()
	$ParticlePath1.rotation = player.spell_direction.angle()
	$ParticlePath2.rotation = player.spell_direction.angle()
	
	placeholder_spell.scale.y = player.mouse_facing
