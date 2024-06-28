extends CharacterBody2D

const SPEED = 70.0
const CLIMB_SPEED = 35
const JUMP_VELOCITY = -250.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var grounded: bool
var hor_direction = 1
var ver_direction = 1
var jumped = false
var _is_on_floor = true
var player_name
var player_health = 100
var souls_collected = 0
var coins_collected = 0
var dial_instance = null
var dial_created = false
var attack_cooldown = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var healthbar = get_tree().get_current_scene().get_node("%hud/Control/HBoxContainer/Healthbar")
@onready var healthbar_label = get_tree().get_current_scene().get_node("%hud/Control/HBoxContainer/Healthbar/HealthbarLabel")
@onready var soul_label = get_tree().get_current_scene().get_node("%hud/Control/HBoxContainer/SoulCounter/SoulCounterLabel")
@onready var money_label = get_tree().get_current_scene().get_node("%hud/Control/HBoxContainer/MoneyCounter/MoneyCounterLabel")

@export var player_id := 1:
	set(id):
		player_id = id
		#client only has acess to change inputs
		%InputSynchronizer.set_multiplayer_authority(id)
		
enum state_type {
	MOVING,
	CLIMBING
}
var state := state_type.MOVING
		
func _ready():
	$Label.text = str(player_name)
	
	if multiplayer.get_unique_id() == player_id: #player_id is client
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false
		
func _on_attack_cooldown_timer_timeout():
	attack_cooldown = false
	
@rpc("any_peer", "call_local", "reliable")
func fire_spell(peer_position, peer_dir, radius): 
	var spell_instance = load("res://scenes/meteor.tscn").instantiate()
	spell_instance.direction = peer_dir
	spell_instance.position = peer_position + peer_dir * radius
	get_parent().add_child(spell_instance)

func _process(_delta):
	if multiplayer.get_unique_id() == player_id:
		healthbar_label.text = str(player_health) + "/100"
		soul_label.text = str(souls_collected)
		money_label.text = "$" + str(coins_collected)
		
		#trigger mystic dial
		if not attack_cooldown:
			if Input.is_action_just_pressed("right_click"):
				dial_instance = load("res://scenes/mystic_dial.tscn").instantiate()
				get_parent().add_child(dial_instance)
				dial_instance.player = self
				dial_created = true
		
		if Input.is_action_just_released("right_click"):
			if (dial_created):
				dial_instance.destroy()
				dial_created = false
		
		#fire mystic dial
		if (dial_created):
			if Input.is_action_just_pressed("left_click"):
				rpc("fire_spell", dial_instance.position, dial_instance.mouse_dir, dial_instance.DIAL_RADIUS)
				dial_instance.destroy()
				attack_cooldown_timer.start(2)
				attack_cooldown = true
				dial_created = false

func _apply_animations(_delta):
	#flips sprite
	if (hor_direction > 0):
		animated_sprite.flip_h = false
	elif (hor_direction < 0):
		animated_sprite.flip_h = true
	
	#play animation
	if _is_on_floor:
		if (hor_direction == 0):
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if (state == state_type.MOVING):
			animated_sprite.play("jump")
		elif (state == state_type.CLIMBING):
			animated_sprite.play("climb")	

func _apply_movement_from_input(delta):
	#direction is set server-side from client input
	hor_direction = %InputSynchronizer.input_direction 
	ver_direction = %InputSynchronizer.climb_direction
	
	#simple state machine
	match state:
		state_type.MOVING:
			#handle gravity
			if not is_on_floor():
				grounded = false
				velocity.y += gravity * delta
			else:
				grounded = true
			#jumping
			if jumped and is_on_floor():
				velocity.y = JUMP_VELOCITY
				jumped = false
		state_type.CLIMBING:
			jumped = false
			velocity.y = 0
			if (ver_direction > 0):
				velocity.y = CLIMB_SPEED
			elif (ver_direction < 0):
				velocity.y = -CLIMB_SPEED
		
	#applys movement
	if hor_direction:
		velocity.x = hor_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _physics_process(delta):
	if multiplayer.is_server():
		_is_on_floor = is_on_floor()
		_apply_movement_from_input(delta)
		
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)
		
@rpc ("any_peer", "call_local")
func apply_knockback(other_pos):
	var knock_back = 100
	if (other_pos < self.global_position.x):
		self.velocity = Vector2(knock_back * 2.5, -knock_back)
	else:
		self.velocity = Vector2(-knock_back * 2.5, -knock_back)
		
@rpc("any_peer", "call_local", "reliable")
func hurt_player(damage: int, other_pos: float):
	animation_player.play("player_hurt")
	rpc("apply_knockback", other_pos)
	player_health -= damage
	healthbar.value = player_health
	player_health = max(player_health, 0)
	
func collect_soul():
	souls_collected += 1
	
func collect_coin():
	coins_collected += 1
