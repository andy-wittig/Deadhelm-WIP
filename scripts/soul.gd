extends RigidBody2D

var can_collect := true
var soul_value := 1
var soul_rarity = null

@onready var sprite = $Sprite2D
@onready var cpu_particles = $CPUParticles2D
@onready var detect_player = $DetectPlayer

@export var randomly_choose_soul := true

var rarities = {
	"diamond" : 60,
	"emerald" : 20,
	"gold" : 5,
	"ruby" : 10,
	"onyx" : 0,
}

@rpc("any_peer", "call_local")
func destroy_self():
	queue_free()
	
func choose_rarity():
	var total_weight = 0
	for weight in rarities.values():
		total_weight += weight
		
	var random_val = randi() % total_weight
	var current_weight = 0
	
	for rarity in rarities.keys():
		current_weight += rarities[rarity]
		if (random_val <= current_weight):
			return rarity
	
func _ready():
	var spawn_effect = load("res://scenes/vfx/spawn_effect.tscn").instantiate()
	spawn_effect.position = position
	get_parent().add_child.call_deferred(spawn_effect)
	
	if (randomly_choose_soul):
		soul_rarity = choose_rarity()
	else:
		soul_rarity = "diamond"

	match soul_rarity:
		"diamond":
			sprite.texture = load("res://assets/sprites/level_objects/diamond_soul.png")
			cpu_particles.color = "36c5f4"
			soul_value = 1
		"emerald":
			sprite.texture = load("res://assets/sprites/level_objects/emerald_soul.png")
			cpu_particles.color = "62a477"
			soul_value = 2
		"gold":
			sprite.texture = load("res://assets/sprites/level_objects/gold_soul.png")
			cpu_particles.color = "f3a833"
			soul_value = 3
		"ruby":
			sprite.texture = load("res://assets/sprites/level_objects/ruby_soul.png")
			cpu_particles.color = "fa6e79"
			soul_value = 1
		"onyx":
			sprite.texture = load("res://assets/sprites/level_objects/onyx_soul.png")
			cpu_particles.color = "10121c"
			soul_value = 2
			
func set_player_effect(body):
	match soul_rarity:
		"ruby":
			body.heal_player(20)
			
	
func _process(delta):
	sprite.material.set_shader_parameter("enabled", false)
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup") && can_collect):
					for i in range(soul_value):
						body.collect_soul()
					set_player_effect(body)
					can_collect = false
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")

func _on_input_event(viewport, event, shape_idx):
	for body in detect_player.get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("left_click") && can_collect):
					for i in range(soul_value):
						body.collect_soul()
					set_player_effect(body)
					can_collect = false
					if (!GameManager.multiplayer_mode_enabled):
						destroy_self()
					elif (multiplayer.is_server()):
						rpc("destroy_self")
