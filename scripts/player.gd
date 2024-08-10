extends CharacterBody2D

#Physics Constants
const SPEED := 75.0
const GRAVITY := 960.0
const EXTRA_GRAVITY := 200.0
const CLIMB_SPEED := 60.0
const JUMP_VELOCITY := -250.0
const COYOTE_TIME := 0.15
const JUMP_BUFFER := 0.1
const MAX_AIR_TIME := 0.5
const HANG_TIME_THRESHHOLD := 60.0
const HANG_TIME_MULTIPLIER := 0.8
const KNOCK_BACK_FALLOFF := 60.0
const DIAL_RADIUS := 22
const HEALTH := 100
#Physics Variables
var grounded: bool
var knock_back: Vector2
var coyote_time_counter: float
var jump_buffer_time: float
var air_time: float
#Player Stats Variables
var player_health := 100
var player_lives := 3
var marked_dead := false
var souls_collected := 0
var coins_collected := 0
#Player Mechanics Variables
var dial_instance = null
var dial_created := false
var attack_cooldown := false
enum state_type {MOVING, CLIMBING}
var state := state_type.MOVING
var spell_direction: Vector2
#Player Inventory Variables
var selected_slot_pos := 0
var currently_selected_slot = null
var spell_instance = null

#Sprite Paths
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
const DEAD_HEART_UI = preload("res://assets/sprites/UI/player_information/dead_heart_ui.png")
const ALIVE_HEART_UI = preload("res://assets/sprites/UI/player_information/heart_ui.png")
#UI Paths
@onready var inventory = {
	"slot_1" : $hud/Control/GridContainer/Slots/ItemSlot1.get_node("Item"),
	"slot_2" : $hud/Control/GridContainer/Slots/ItemSlot2.get_node("Item"),
	"slot_3" : $hud/Control/GridContainer/Slots/ItemSlot3.get_node("Item"),
}
@onready var hearts = [
	$hud/Control/GridContainer/HeartContainer.get_node("Heart1"),
	$hud/Control/GridContainer/HeartContainer.get_node("Heart2"),
	$hud/Control/GridContainer/HeartContainer.get_node("Heart3"),
]
@onready var healthbar = $hud/Control/GridContainer/Healthbar
@onready var healthbar_label = $hud/Control/GridContainer/Healthbar/HealthbarLabel
@onready var soul_label = $hud/Control/GridContainer/VBoxContainer/SoulCounter/SoulCounterLabel
@onready var money_label = $hud/Control/GridContainer/VBoxContainer/MoneyCounter/MoneyCounterLabel
#Audio Paths
@onready var coin_pickup_audio_player = $CoinPickupAudio
@onready var tome_pickup_audio = $TomePickupAudio
@onready var soul_pickup_audio = $SoulPickupAudio
@onready var player_hurt_audio = $PlayerHurtAudio
@onready var footstep_audio = $FootstepAudio
@onready var spell_cast_audio = $SpellCastAudio
#Mechanics Paths
@onready var player_collider = $PlayerCollider
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var spell_spawn = $SpellSpawn
@onready var camera = $Camera2D

func get_player_info():
	var save_dict = {
		"player_health" : player_health,
		"player_lives" : player_lives,
		"coins_collected" : coins_collected,
		"slot_1" : inventory["slot_1"].get_slot_item(),
		"slot_2" : inventory["slot_2"].get_slot_item(),
		"slot_3" : inventory["slot_3"].get_slot_item(),
	}
	return save_dict
	
func save_player_info():
	var player_info_file = FileAccess.open("user://player_info.save", FileAccess.WRITE)
	var player_data = get_player_info()
	var json_string = JSON.stringify(player_data)
	player_info_file.store_line(json_string)
	
func load_player_info():
	if not FileAccess.file_exists("user://player_info.save"):
		return
		
	var player_info_file = FileAccess.open("user://player_info.save", FileAccess.READ)
	while player_info_file.get_position() < player_info_file.get_length():
		var json_string = player_info_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var player_data = json.get_data()
		
		inventory["slot_1"].set_slot_item(player_data["slot_1"])
		inventory["slot_2"].set_slot_item(player_data["slot_2"])
		inventory["slot_3"].set_slot_item(player_data["slot_3"])
		
		for data in player_data.keys():
			if(data == "slot_1" || data == "slot_2" || data == "slot_3"):
				continue
			set(data, player_data[data])
	
func _ready():
	$Camera2D.reset_smoothing()
	load_player_info()
	currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
	currently_selected_slot.currently_selected = true
	
func _process(delta):
	#handle UI elements
	for i in range(hearts.size()):
		if (i + 1 > player_lives):
			hearts[i].texture = DEAD_HEART_UI
		else:
			hearts[i].texture = ALIVE_HEART_UI
			
	healthbar_label.text = str(player_health) + "/100"
	healthbar.value = player_health
	soul_label.text = str(souls_collected)
	money_label.text = "$" + str(coins_collected)
	
	#handle player death
	if (player_lives <= 0):
		disable_player()
		var menu_control = get_tree().get_root().get_node("game/MenuLayer")
		menu_control.current_menu = menu_control.menu.GAMEOVER
				
	if (player_health <= 0 && player_lives > 0):
		if (!marked_dead):
			player_lives -= 1
			player_health = HEALTH
			global_position = get_parent().global_position
	
	#set spell spawn marker position
	var mouse_pos = get_global_mouse_position()
	var dial_center = Vector2(global_position.x, global_position.y)
	spell_direction = (mouse_pos - dial_center).normalized()
	spell_spawn.global_position = dial_center + spell_direction * DIAL_RADIUS
	
	#HANDLE INVENTORY INPUT
	#scrolling
	if (Input.is_action_just_pressed("scroll_up")):
		inventory_scrolling(1)
		
	if (Input.is_action_just_pressed("scroll_down")):
		inventory_scrolling(-1)
	
	#droping items
	if (Input.is_action_just_pressed("drop_item")):
		if (currently_selected_slot.get_can_drop()):
			drop_inventory_item(currently_selected_slot.get_slot_item(), global_position)
			currently_selected_slot.set_slot_item("empty")	
	
	#mystic dial and spell spawning
	if (currently_selected_slot.get_slot_item() != "empty"):
		#open mystic dial
		if (!currently_selected_slot.attack_cooldown && Input.is_action_just_pressed("right_click")):
			spell_instance = load(currently_selected_slot.get_spell_instance()).instantiate()
			dial_instance = load("res://scenes/player/mystic_dial.tscn").instantiate()
			get_parent().add_child(dial_instance)
			dial_instance.position.x = position.x
			dial_instance.position.y = position.y
			dial_instance.player = self
			dial_instance.set_placeholder_sprite(spell_instance.get_sprite_path())
			dial_created = true
		
		#trigger mystic dial
		if (dial_created && Input.is_action_just_pressed("left_click")):
			var spell_path = currently_selected_slot.get_spell_instance()
			var new_spell = load(spell_path).instantiate()
			new_spell.player = self
			get_tree().get_root().get_node("game/Level").add_child(new_spell)
			
			spell_cast_audio.play()
			
			currently_selected_slot.start_cooldown()
			dial_instance.destroy()
			dial_created = false
	
	#release mystic dial		
	if Input.is_action_just_released("right_click"):
			if (dial_created):
				dial_instance.destroy()
				dial_created = false

func _physics_process(delta):
	#simple state machine
	match state:
		state_type.MOVING:
			#handle gravity and jumping
			if is_on_floor():
				air_time = 0
				coyote_time_counter = COYOTE_TIME
			else:
				air_time += delta
				air_time = clamp(air_time, 0, MAX_AIR_TIME)
				
				if (abs(velocity.y) < HANG_TIME_THRESHHOLD):
					velocity.y += (GRAVITY + (EXTRA_GRAVITY * air_time)) * HANG_TIME_MULTIPLIER * delta
				else:
					velocity.y += (GRAVITY + (EXTRA_GRAVITY * air_time)) * delta
				
				coyote_time_counter -= delta
				
			if (Input.is_action_just_pressed("jump")):
				jump_buffer_time = JUMP_BUFFER
			else:
				jump_buffer_time -= delta
				
			if (jump_buffer_time > 0 && coyote_time_counter > 0):
				velocity.y = JUMP_VELOCITY
				jump_buffer_time = 0
			
			if (Input.is_action_just_released("jump") && velocity.y < 0): #jump height control
				velocity.y *= 0.5
				coyote_time_counter = 0
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
		grounded = true
		if (direction == 0):
			animated_sprite.play("idle")
			footstep_audio.stop()
		else:
			animated_sprite.play("run")
			if (!footstep_audio.is_playing()):
				footstep_audio.play()
	else:
		grounded = false
		footstep_audio.stop()
		if (state == state_type.MOVING):
			animated_sprite.play("jump")
		elif (state == state_type.CLIMBING):
			animated_sprite.play("climb")	
		
	#applys movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)

	move_and_slide()

#PLAYER LOGIC FUNCTIONS
func apply_knockback(other_pos: Vector2, force: float):
		var other_dir = (other_pos - global_position).normalized()
		knock_back = -other_dir * force

func heal_player(health: int):
	animation_player.play("player_heal")
	
	player_health += health
	if (player_health > 100): player_health = 100
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = health
	damage_indicator.damage_indicator_color = "5ab552"
	damage_indicator.position = global_position
	get_tree().get_root().get_node("game/Level").add_child(damage_indicator)

func hurt_player(damage: int, other_pos: Vector2, force: float):
	animation_player.play("player_hurt")
	player_hurt_audio.play()
	camera.add_trauma(0.5)
	apply_knockback(other_pos, force)
	
	player_health -= damage
	player_health = max(player_health, 0)
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = damage
	damage_indicator.damage_indicator_color = "ec273f"
	damage_indicator.position = global_position
	get_tree().get_root().get_node("game/Level").add_child(damage_indicator)
	
func disable_player():
	set_process(false)
	set_physics_process(false)
	player_collider.set_deferred("disabled", true)
	#$hud.visible = false
	visible = false
	#$Camera2D.enabled = false
	marked_dead = true
	
#INVENTORY FUNCTIONS
func inventory_scrolling(scroll_amount: int):
		selected_slot_pos += scroll_amount
		
		#wrap scrolling
		if (selected_slot_pos > inventory.size() - 1): 
			selected_slot_pos = 0
		elif (selected_slot_pos < 0):
			selected_slot_pos = inventory.size() - 1
		
		currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
		for slot in inventory:
			inventory[slot].currently_selected = false
		currently_selected_slot.currently_selected = true
		
func drop_inventory_item(spell_type, pos):
	var tome = load("res://scenes/player/spells/tome.tscn").instantiate()
	tome.spell_type = spell_type
	tome.position.x = pos.x
	tome.position.y = pos.y
	get_tree().get_root().get_node("game/Level").add_child(tome)
	
func is_inventory_full():
	for slot in inventory:
		if inventory[slot].get_slot_item() == "empty":
			return false
	return true
	
#COLLECT ITEM FUNCTIONS
func collect_soul():
	soul_pickup_audio.play()
	souls_collected += 1
	
func collect_coin():
	coin_pickup_audio_player.play()
	coins_collected += 1
	
func colllect_spell(spell_type):
	for slot in inventory:
		if inventory[slot].get_slot_item() == "empty":
			inventory[slot].set_slot_item(spell_type)
			tome_pickup_audio.play()
			break
