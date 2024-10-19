extends CharacterBody2D

#Physics Constants
const SPEED := 75.0
const GRAVITY := 960.0
const EXTRA_GRAVITY := 200.0
const CLIMB_SPEED := 75.0
const ZIPLINE_SPEED := 100
const JUMP_VELOCITY := -250.0
const COYOTE_TIME := 0.15
const JUMP_BUFFER := 0.1
const MAX_AIR_TIME := 0.5
const HANG_TIME_THRESHHOLD := 60.0
const HANG_TIME_MULTIPLIER := 0.8
const KNOCK_BACK_FALLOFF := 100.0
const DIAL_RADIUS := 22
const MAX_LIVES := 3
const MAX_UPGRADED_HEALTH := 200
#Physics Variables
var knock_back: Vector2
var coyote_time_counter: float
var jump_buffer_time: float
var air_time: float
var direction: float
#Player Stats Variables
var max_health := 100
var player_health := max_health
var player_lives := 3
var marked_dead := false
var souls_collected := 0
var coins_collected := 0
#Player Mechanics Variables
var dial_instance = null
var dial_created := false
var attack_cooldown := false
enum state_type {SITTING, MOVING, CLIMBING, ZIPLINE}
var state := state_type.SITTING
var spell_direction: Vector2
var double_jump_active := false
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
	"slot_1" : $hud/Control/Slots/ItemSlot1.get_node("Item"),
	"slot_2" : $hud/Control/Slots/ItemSlot2.get_node("Item"),
	"slot_3" : $hud/Control/Slots/ItemSlot3.get_node("Item"),
}
@onready var hearts = [
	$hud/Control/HealthContainer/LivesContainer.get_node("Heart1"),
	$hud/Control/HealthContainer/LivesContainer.get_node("Heart2"),
	$hud/Control/HealthContainer/LivesContainer.get_node("Heart3"),
]
@onready var healthbar = $hud/Control/HealthContainer/Healthbar
@onready var healthbar_label = $hud/Control/HealthContainer/Healthbar/HealthbarLabel
@onready var soul_label = $hud/Control/StatsContainer/SoulCounter/SoulCounterLabel
@onready var money_label = $hud/Control/StatsContainer/MoneyCounter/MoneyCounterLabel
@onready var portal_progress = $hud/Control/PortalProgess/ProgressBar
#Audio Paths
@onready var coin_pickup_audio_player = $"Sound Effects/CoinPickupAudio"
@onready var tome_pickup_audio = $"Sound Effects/TomePickupAudio"
@onready var soul_pickup_audio = $"Sound Effects/SoulPickupAudio"
@onready var player_hurt_audio = $"Sound Effects/PlayerHurtAudio"
@onready var footstep_audio = $"Sound Effects/FootstepAudio"
@onready var spell_cast_audio = $"Sound Effects/SpellCastAudio"
#Mechanics Paths
@onready var player_center = $PlayerCenter
@onready var player_collider = $PlayerCollider
@onready var spell_spawn = $SpellSpawn
@onready var camera = $Camera2D
@onready var dust_particles = $DustParticles

func get_player_info():
	var save_dict = {
		"player_health" : player_health,
		"max_health" : max_health,
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
	var portal_gate = get_tree().get_root().get_node("game/Level/%s/portal_gate" % GameManager.current_level)
	
	for i in range(hearts.size()):
		if (i + 1 > player_lives):
			hearts[i].texture = DEAD_HEART_UI
		else:
			hearts[i].texture = ALIVE_HEART_UI
	
	portal_progress.max_value = portal_gate.soul_cost
	portal_progress.value = clamp(souls_collected + portal_gate.souls_input, 0, portal_progress.max_value)
	healthbar_label.text = str(player_health) + "/" + str(max_health)
	healthbar.max_value = max_health
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
			global_position = get_tree().get_root().get_node("game/Level/%s/spawn_point" % GameManager.current_level).global_position
			$level_transition.get_node("AnimationPlayer").play("fade_in")
			player_health = max_health
			
	#set spell spawn marker position
	var dial_center = player_center.global_position
	
	if (Input.get_connected_joypads().is_empty()):
		var aim_pos = get_global_mouse_position()
		spell_direction = (aim_pos - dial_center).normalized()
	elif (!Input.get_connected_joypads().is_empty()):
		var aim_vec = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		if (aim_vec.length() > 0):
			spell_direction = aim_vec.normalized()
		elif (direction != 0):
			spell_direction = Vector2(direction, 0).normalized()
	
	spell_spawn.global_position = dial_center + spell_direction * DIAL_RADIUS
	
	#HANDLE INVENTORY INPUT
	#scrolling
	if (Input.is_action_just_pressed("scroll_up")):
		inventory_scrolling(1)
		
	if (Input.is_action_just_pressed("scroll_down")):
		inventory_scrolling(-1)
	#hotkeys
	inventory_hotkey()
	
	for slot in inventory:
		inventory[slot].currently_selected = false
	currently_selected_slot.currently_selected = true
	
	#droping items
	if (Input.is_action_just_pressed("drop_item")):
		if (currently_selected_slot.get_can_drop()):
			drop_inventory_item(currently_selected_slot.get_slot_item(), player_center.global_position)
			currently_selected_slot.set_slot_item("empty")	
	
	#mystic dial and spell spawning
	var can_fire := true
	
	if (currently_selected_slot.get_slot_item() == "empty" || currently_selected_slot.is_dragging()): 
		can_fire = false
		if (dial_created):
			dial_instance.destroy()
	else: #ensure spells of same class can't be used at the same time
		var currently_selected_class = currently_selected_slot.get_slot_item_class()
		for slot in inventory:
			if (inventory[slot].get_slot_item() != "empty" && inventory[slot].attack_cooldown):
					if (inventory[slot].get_slot_item_class() == currently_selected_class):
						can_fire = false
	
	if (can_fire):
		if (!currently_selected_slot.attack_cooldown && Input.is_action_just_pressed("left_click")):
			spell_instance = load(currently_selected_slot.get_spell_instance()).instantiate()
			dial_instance = load("res://scenes/player/mystic_dial.tscn").instantiate()
			get_parent().add_child(dial_instance)
			dial_instance.position.x = player_center.global_position.x
			dial_instance.position.y = player_center.global_position.y
			dial_instance.player = self
			dial_instance.set_placeholder_sprite(spell_instance.get_sprite_path())
			dial_created = true
		
		#trigger mystic dial
		if (dial_created && Input.is_action_just_released("left_click")):
			var spell_path = currently_selected_slot.get_spell_instance()
			var new_spell = load(spell_path).instantiate()
			new_spell.player = self
			get_tree().get_root().get_node("game/Level").add_child(new_spell)
			spell_cast_audio.play()
			
			currently_selected_slot.start_cooldown(currently_selected_slot.get_slot_item())
			dial_instance.destroy()
			dial_created = false
			
	#Developer Cheats
	if (Input.is_action_just_pressed("cheat_button_1")):
		souls_collected += 10
		
	if Input.is_action_just_pressed("cheat_button_2"):
		global_position = portal_gate.global_position
			
	move_and_slide()

func _physics_process(delta):
	#simple state machine
	match state:
		state_type.SITTING:
			if (GameManager.current_level != "level_grasslands_1"):
				state = state_type.MOVING
			else:
				$Camera2D.zoom = Vector2(5, 5)
				animated_sprite.play("sit")
				
				if (Input.is_anything_pressed()):
					animation_player.play("zoom_out")
					state = state_type.MOVING
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
				dust_particles.emitting = true
				velocity.y = JUMP_VELOCITY
				jump_buffer_time = 0
			
			if (Input.is_action_just_released("jump") && velocity.y < 0): #jump height control
				velocity.y *= 0.5
				coyote_time_counter = 0
				
			#play animation
			if is_on_floor():
				if (direction == 0):
					animated_sprite.play("idle")
					footstep_audio.stop()
				else:
					animated_sprite.play("run")
					if (!footstep_audio.is_playing()):
						footstep_audio.play()
			else:
				footstep_audio.stop()
				if (velocity.y < 0):
					animated_sprite.play("jump")
				else:
					animated_sprite.play("fall")
		state_type.CLIMBING:
			animated_sprite.play("climb")
			velocity.y = 0
			
			if (Input.is_action_pressed("move_up")):
				velocity.y = -CLIMB_SPEED
			elif (Input.is_action_pressed("move_down")):
				velocity.y = CLIMB_SPEED
		state_type.ZIPLINE:
			animated_sprite.play("climb")
			velocity = Vector2.ZERO

	#get input direction
	direction = Input.get_axis("move_left", "move_right")
	
	#flips sprite
	if (direction > 0):
		animated_sprite.flip_h = false
	elif (direction < 0):
		animated_sprite.flip_h = true
		
	#applys movement
	if (direction && state != state_type.ZIPLINE):
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	velocity += knock_back
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF)

#PLAYER LOGIC FUNCTIONS
func apply_knockback(other_pos: Vector2, force: float):
		var other_dir = (other_pos - player_center.global_position).normalized()
		knock_back = -other_dir * force

func heal_player(health: int):
	animation_player.play("player_heal")
	
	player_health += health
	if (player_health > 100): player_health = 100
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = health
	damage_indicator.damage_indicator_color = "5ab552"
	damage_indicator.position = player_center.global_position
	get_tree().get_root().get_node("game/Level").add_child(damage_indicator)

func hurt_player(damage: int, other_pos: Vector2, force: float):
	animation_player.play("player_hurt")
	player_hurt_audio.play()
	set_screen_shake(0.5)
	apply_knockback(other_pos, force)
	
	player_health -= damage
	player_health = max(player_health, 0)
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = damage
	damage_indicator.damage_indicator_color = "ec273f"
	damage_indicator.position = player_center.global_position
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
		
func inventory_hotkey():
	if (Input.is_action_just_pressed("slot_1")):
		currently_selected_slot = inventory[inventory.keys()[0]]
	if (Input.is_action_just_pressed("slot_2")):
		currently_selected_slot = inventory[inventory.keys()[1]]
	if (Input.is_action_just_pressed("slot_3")):
		currently_selected_slot = inventory[inventory.keys()[2]]
		
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
func collect_buff(buff: String):
	match buff:
		"heart_crystal":
			if (player_lives < MAX_LIVES):
				player_lives += 1
		"defense_upgrade":
			if (max_health <= MAX_UPGRADED_HEALTH - 10):
				max_health += 10
		"health_potion":
			if (player_health < max_health):
				player_health += 25
				player_health = min(player_health, max_health)
		"double_jump":
			double_jump_active = true

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
			
func set_screen_shake(amount: float):
	camera.add_trauma(amount)
