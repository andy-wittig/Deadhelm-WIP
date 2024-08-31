extends CharacterBody2D
#Constants
const SPEED := 28.0
const KNOCK_BACK_FALLOFF := 60.0
const ROAM_RANGE := 48
const ROAM_CHANGE_WAIT := 6
const MAX_HEALTH := 40
#Chase Player Variables
var chasing_player = false
var player = null
#Roaming Variables
var rand_state_timer = RandomNumberGenerator.new()
var init_position: Vector2
var roam_direction = Vector2.UP
#Physics Variables
var knock_back: Vector2
#Enemy Mechanic Variables
var marked_for_death = false
var enemy_health = MAX_HEALTH

enum state_type {
	MOVING,
	CHASE,
}
var state := state_type.MOVING

@onready var body_sprite = $BodySprite
@onready var gun_sprite = $GunSprite
@onready var ray_cast_down = $RayCastDown
@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var audio_stream = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer
@onready var chase_player = $"chase player"

signal enemy_was_hurt

func _ready():
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		init_position = global_position
		%RoamTimer.start()

func apply_knockback(other_pos: Vector2, force: float):
		var other_dir = (other_pos - global_position).normalized()
		knock_back = -other_dir * force
	
@rpc("any_peer", "call_local")
func hurt_enemy(damage: int, other_pos: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	animation_player.play("enemy_blink")
	apply_knockback(other_pos, force)
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	get_parent().add_child(impact)
	impact.position = Vector2(position.x, position.y)
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)
	
@rpc("call_local", "any_peer")
func destroy_self():
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	soul.position = position
	soul.rarities["diamond"] = 60
	soul.rarities["emerald"] = 25
	soul.rarities["gold"] = 5
	soul.rarities["ruby"] = 10
	get_parent().add_child(soul)
	
	var explosion = load("res://scenes/vfx/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.position = Vector2(position.x, position.y - 8)
	
	marked_for_death = true
	queue_free()
	
@rpc("call_local")
func attack(direction):
	var rocket = load("res://scenes/enemies/sentinal_rocket.tscn").instantiate()
	rocket.direction = direction
	rocket.position = %"Rocket Marker".position
	add_child(rocket)
	
func update_rand_direction():
	var rand_x = init_position.x + randi_range(-ROAM_RANGE, ROAM_RANGE)
	var rand_y = init_position.y + randi_range(-ROAM_RANGE, ROAM_RANGE)
	roam_direction = (Vector2(rand_x, rand_y) - global_position).normalized()
	%RoamTimer.start(randf_range(2, ROAM_CHANGE_WAIT))

func _process(_delta):
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		for body in chase_player.get_overlapping_bodies():
			if (body.is_in_group("players")):
				if (!chasing_player):
					player = body
					chasing_player = true
					%AttackTimer.start()
					state = state_type.CHASE
				return
		#player left detection radius
		player = null
		chasing_player = false
		%AttackTimer.stop()
		state = state_type.MOVING

func _physics_process(delta):
	if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
		#Handle enemy death
		if (enemy_health <= 0):
			if (!marked_for_death):
				if (!GameManager.multiplayer_mode_enabled):
					destroy_self()
				elif (multiplayer.is_server()):
					rpc("destroy_self")
			
		#flip sprite
		if (global_position.x + roam_direction.x > global_position.x):
			body_sprite.flip_h = true
			gun_sprite.rotation = deg_to_rad(-135)
			gun_sprite.flip_v = true
		elif (global_position.x + roam_direction.x < global_position.x):
			body_sprite.flip_h = false
			gun_sprite.rotation = deg_to_rad(-45)
			gun_sprite.flip_v = false
		
	match state:
		state_type.MOVING:	
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
				if ray_cast_right.is_colliding():
					roam_direction = Vector2.LEFT
				elif ray_cast_left.is_colliding():
					roam_direction = Vector2.RIGHT
				elif ray_cast_up.is_colliding():
					roam_direction = Vector2.DOWN
				elif ray_cast_down.is_colliding():
					roam_direction = Vector2.UP
					
				if (init_position.distance_to(global_position) >= ROAM_RANGE):
					roam_direction = (init_position - global_position).normalized()
					
				velocity = roam_direction * SPEED
				
		state_type.CHASE:
			if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
				roam_direction = (player.global_position - global_position).normalized()
				if player.global_position.distance_to(global_position) > 64:
					velocity = roam_direction * SPEED
				else:
					velocity = Vector2.ZERO
	
	#Knockback implementation
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
	
	move_and_slide()
			
func _on_roam_timer_timeout():
	if (!chasing_player && !marked_for_death):
		if (multiplayer.is_server() || !GameManager.multiplayer_mode_enabled):
			update_rand_direction()

func _on_attack_timer_timeout():
	if (!marked_for_death):
		if multiplayer.is_server():
			rpc("attack", roam_direction)
		elif (!GameManager.multiplayer_mode_enabled):
			attack(roam_direction)
