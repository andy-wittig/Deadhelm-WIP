extends CharacterBody2D
#Constants
const SPEED := 28.0
const AIR_FRICTION := 0.05
const KNOCK_BACK_FALLOFF := 25.0
const ROAM_RANGE := 48
const ROAM_CHANGE_WAIT := 6
const MAX_HEALTH := 40
#Chase Player Variables
var chasing_player := false
var player = null
#Roaming Variables
var rand_state_timer := RandomNumberGenerator.new()
var init_position: Vector2
var roam_direction := Vector2.UP
#Physics Variables
var knock_back: Vector2
#Enemy Mechanic Variables
var marked_for_death := false
var enemy_health := MAX_HEALTH

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
	call_deferred("get_start_pos")
	%RoamTimer.start()
	
func get_start_pos():
	init_position = global_position

func apply_knockback(force_direction: Vector2, force: float):
		knock_back = force_direction.normalized() * force

func hurt_enemy(damage: int, direction: Vector2, force: float):
	emit_signal("enemy_was_hurt")
	animation_player.play("enemy_blink")
	apply_knockback(direction, force)
	
	var impact = load("res://scenes/vfx/impact.tscn").instantiate()
	impact.position = Vector2(position.x, position.y)
	get_parent().add_child(impact)
	impact.reset_physics_interpolation()
	
	enemy_health -= damage
	enemy_health = max(enemy_health, 0)

func destroy_self():
	get_tree().call_group("unlock_enemy", "unlock_page", 4)
	
	var soul = load("res://scenes/level_objects/soul.tscn").instantiate()
	soul.position = position
	soul.rarities["diamond"] = 60
	soul.rarities["emerald"] = 25
	soul.rarities["gold"] = 5
	soul.rarities["ruby"] = 10
	get_parent().add_child(soul)
	
	var explosion = load("res://scenes/vfx/explosion.tscn").instantiate()
	explosion.position = Vector2(position.x, position.y - 8)
	get_parent().add_child(explosion)
	explosion.reset_physics_interpolation()
	
	marked_for_death = true
	queue_free()

func attack(direction):
	var rocket = load("res://scenes/enemies/sentinal_rocket.tscn").instantiate()
	rocket.direction = direction
	rocket.global_position = %"Rocket Marker".global_position
	get_parent().add_child(rocket)
	
func update_rand_direction():
	var rand_x = init_position.x + randi_range(-ROAM_RANGE, ROAM_RANGE)
	var rand_y = init_position.y + randi_range(-ROAM_RANGE, ROAM_RANGE)
	roam_direction = (Vector2(rand_x, rand_y) - global_position).normalized()

func _process(_delta):
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
	#Handle enemy death
	if (enemy_health <= 0):
		if (!marked_for_death):
			destroy_self()
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
			if (init_position.distance_to(global_position) >= ROAM_RANGE):
				roam_direction = (init_position - global_position).normalized()
				
			velocity = roam_direction * SPEED
				
		state_type.CHASE:
			roam_direction = (player.player_center.global_position - global_position).normalized()
			if (player.global_position.distance_to(global_position) > 64):
				velocity = roam_direction * SPEED
			elif (player.global_position.distance_to(global_position) < 48):
				velocity = -roam_direction * SPEED
			else:
				velocity = lerp(velocity, Vector2.ZERO, AIR_FRICTION)
	
	#Knockback implementation
	if (abs(knock_back) > Vector2.ZERO):
		velocity = knock_back
		knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
		knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)
	
	move_and_slide()
			
func _on_roam_timer_timeout():
	if (!chasing_player && !marked_for_death):
		update_rand_direction()
		%RoamTimer.start(randf_range(2, ROAM_CHANGE_WAIT))

func _on_attack_timer_timeout():
	if (!marked_for_death):
		attack(roam_direction)
