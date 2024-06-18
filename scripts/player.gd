extends CharacterBody2D

const SPEED = 70.0
const CLIMB_SPEED = 35
const JUMP_VELOCITY = -250.0

var player_health = 100
var souls_collected = 0
var coins_collected = 0
var attack_cooldown = false

enum state_type {
	MOVING,
	CLIMBING
}
var state := state_type.MOVING

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var healthbar = %hud/Control/HBoxContainer/Healthbar
@onready var healthbar_label = %hud/Control/HBoxContainer/Healthbar/HealthbarLabel
@onready var soul_label = %hud/Control/HBoxContainer/SoulCounter/SoulCounterLabel
@onready var money_label = %hud/Control/HBoxContainer/MoneyCounter/MoneyCounterLabel
@onready var coin_pickup_audio_player = $CoinPickupAudioPlayer
@onready var attack_cooldown_timer = $AttackCooldownTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var dial_instance = null
var dial_created = false

func _on_attack_cooldown_timer_timeout():
	attack_cooldown = false

func _process(delta):
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
			var spell_instance = load("res://scenes/meteor.tscn").instantiate()
			spell_instance.direction = dial_instance.mouse_dir
			spell_instance.position = dial_instance.position + dial_instance.mouse_dir * dial_instance.DIAL_RADIUS
			get_parent().add_child(spell_instance)
			
			dial_instance.destroy()
			attack_cooldown_timer.start(2)
			attack_cooldown = true
			dial_created = false
		
func _physics_process(delta):
	#simple state machine
	match state:
		state_type.MOVING:
			#handle gravity
			if not is_on_floor():
				velocity.y += gravity * delta
			#jumping
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
		state_type.CLIMBING:
			velocity.y = 0
			if (Input.is_action_pressed("move_up")):
				velocity.y = -CLIMB_SPEED
			elif (Input.is_action_pressed("move_down")):
				velocity.y = CLIMB_SPEED

	#get input direction
	var direction = Input.get_axis("move_left", "move_right")
	
	#flips sprite
	if (direction > 0):
		animated_sprite.flip_h = false
	elif (direction < 0):
		animated_sprite.flip_h = true
	
	#play animation
	if is_on_floor():
		if (direction == 0):
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if (state == state_type.MOVING):
			animated_sprite.play("jump")
		elif (state == state_type.CLIMBING):
			animated_sprite.play("climb")	
		
	#applys movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func apply_knockback(other_pos):
	var knock_back = 100
	if (other_pos < self.global_position.x):
		self.velocity = Vector2(knock_back * 2.5, -knock_back)
	else:
		self.velocity = Vector2(-knock_back * 2.5, -knock_back)

func hurt_player(damage: int, other_pos: float):
	animation_player.play("player_hurt")
	apply_knockback(other_pos)
	player_health -= damage
	healthbar.value = player_health
	player_health = max(player_health, 0)
	
func collect_soul():
	souls_collected += 1
	
func collect_coin():
	coin_pickup_audio_player.play()
	coins_collected += 1
