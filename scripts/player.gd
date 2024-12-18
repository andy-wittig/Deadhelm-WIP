extends CharacterBody2D

#Physics Constants
const SPEED := 75.0
const GRAVITY := 940
const EXTRA_GRAVITY := 200.0
const CLIMB_SPEED := 75.0
const ZIPLINE_SPEED := 100
const JUMP_VELOCITY := -250.0
const COYOTE_TIME := 0.15
const JUMP_BUFFER := 0.1
const MAX_AIR_TIME := 0.5
const HANG_TIME_THRESHHOLD := 60.0
const HANG_TIME_MULTIPLIER := 0.8
const KNOCK_BACK_FALLOFF := 10.0
const FRICTION_FORCE := 10
const DIAL_RADIUS := 22
const MAX_LIVES := 3
const MAX_UPGRADED_HEALTH := 200
#Physics Variables
var knock_back: Vector2
var friction_multiplier := 1.0
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
var cast_complete := false
var attack_cooldown := false
var spell_direction: Vector2
var mouse_facing := 0
var double_jump_active := false
var double_jump := 0
var player_facing := 1
var invincible := false
#Player Inventory Variables
var selected_slot_pos := 0
var currently_selected_slot = null
var spell_instance = null
#States
enum state_type {SITTING, MOVING, CLIMBING, ZIPLINE}
var state := state_type.SITTING

enum animation_type {SIT, RUN, IDLE, CLIMB, JUMP, FALL}
var animation_state := animation_type.SIT

var animation_queue : Array[String] = []

#Sound Effects
var sound_library := {
	"coin" : load("res://assets/sound effects/player/coin_pickup.mp3"),
	"tome" : load("res://assets/sound effects/player/tome_pickup.wav"),
	"hurt" : load("res://assets/sound effects/player/player_hurt.mp3"),
	"soul" : load("res://assets/sound effects/player/soul_pickup.wav"),
	"cast" : load("res://assets/sound effects/player/spell_cast_sound.mp3"),
}
@onready var audio_player = $AudioStreamPlayer
@onready var footstep_audio = $FootstepAudio

#Sprite Paths
@onready var upper_sprite = $UpperSprite
@onready var lower_sprite = $LowerSprite
@onready var animation_player = $AnimationPlayer
const DEAD_HEART_UI = preload("res://assets/sprites/UI/player_information/dead_heart_ui.png")
const ALIVE_HEART_UI = preload("res://assets/sprites/UI/player_information/heart_ui.png")
var fist_cursor = load("res://assets/sprites/UI/cursor_fist.png")
var point_cursor = load("res://assets/sprites/UI/cursor pointer.png")
var hold_cursor = load("res://assets/sprites/UI/cursor can drop.png")
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
		"double_jump_active" : double_jump_active,
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
			global_position = get_tree().get_root().get_node("game/Level/%s/spawn_point" % GameManager.current_level).global_position
			player_lives -= 1
			player_health = max_health
			
			if (player_lives > 0): 
				get_tree().call_group("transition", "player_death")
			
	#set spell spawn marker position
	var dial_center = player_center.global_position
	
	if (Input.get_connected_joypads().is_empty()):
		var aim_pos = get_global_mouse_position()
		spell_direction = (aim_pos - dial_center).normalized()
		
		if (aim_pos.x > global_position.x): mouse_facing = 1
		else: mouse_facing = -1
		
	elif (!Input.get_connected_joypads().is_empty()):
		var aim_vec = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		if (aim_vec.length() > 0):
			spell_direction = aim_vec.normalized()
			
		if (aim_vec.x >= 0): mouse_facing = 1
		else: mouse_facing = -1
	
	spell_spawn.global_position = dial_center + spell_direction * DIAL_RADIUS
	
	#HANDLE INVENTORY INPUT
	#scrolling
	if (GameManager.access_ingame_menu):
		if (Input.is_action_just_pressed("scroll_up")):
			inventory_scrolling(1)
			
		if (Input.is_action_just_pressed("scroll_down")):
			inventory_scrolling(-1)
		
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
	
	if (currently_selected_slot.get_slot_item() == "empty" 
	|| currently_selected_slot.is_dragging()
	|| !GameManager.access_ingame_menu):
		can_fire = false
		if (dial_created):
			dial_instance.destroy()
			dial_instance = null
			dial_created = false
	else: #ensure spells of same class can't be used at the same time
		var currently_selected_class = currently_selected_slot.get_slot_item_class()
		for slot in inventory:
			if (inventory[slot].get_slot_item() != "empty" && inventory[slot].attack_cooldown):
					if (inventory[slot].get_slot_item_class() == currently_selected_class):
						can_fire = false
	
	#Cursor Logic
	if (GameManager.access_ingame_menu):
		if (can_fire):
			if (dial_created):
				Input.set_custom_mouse_cursor(point_cursor, Input.CURSOR_ARROW)
			else:
				Input.set_custom_mouse_cursor(hold_cursor, Input.CURSOR_ARROW)
		else:
			Input.set_custom_mouse_cursor(fist_cursor, Input.CURSOR_ARROW)
	else:
		Input.set_custom_mouse_cursor(point_cursor, Input.CURSOR_ARROW)
	
	if (can_fire):
		if (!currently_selected_slot.attack_cooldown && Input.is_action_just_pressed("cast_spell")):
			if (!dial_created):
				spell_instance = load(currently_selected_slot.get_spell_instance()).instantiate()
				dial_instance = load("res://scenes/player/mystic_dial.tscn").instantiate()
				dial_instance.player = self
				dial_instance.global_position = player_center.global_position
				get_parent().add_child(dial_instance)
				dial_instance.reset_physics_interpolation()
				dial_instance.set_placeholder_sprite(spell_instance.get_sprite_path())
				dial_created = true
		
		#trigger mystic dial
		if (dial_created && Input.is_action_just_released("cast_spell")):
			spell_instance.player = self
			spell_instance.global_position = spell_spawn.global_position
			get_tree().get_root().get_node("game/Level").add_child(spell_instance)
			spell_instance.reset_physics_interpolation()
			play_sound("cast")
			
			currently_selected_slot.start_cooldown(currently_selected_slot.get_slot_item())
			dial_instance.destroy()
			dial_instance = null
			dial_created = false
			cast_complete = true
	elif (dial_created && Input.is_action_just_released("cast_spell")):
		dial_instance.destroy()
		dial_instance = null
		dial_created = false
	
	#Developer Cheats
	if (Input.is_action_just_pressed("cheat_button_1")):
		souls_collected += 10
	if Input.is_action_just_pressed("cheat_button_2"):
		global_position = portal_gate.global_position
	if Input.is_action_just_pressed("cheat_button_3"):
		#invincible = !invincible
		Engine.set_time_scale(0.1)
	if Input.is_action_just_pressed("cheat_button_4"):
		global_position = get_global_mouse_position()

func _physics_process(delta):
	#simple state machine
	match state:
		state_type.SITTING:
			if (GameManager.current_level != "level_grasslands_1"):
				state = state_type.MOVING
			else:
				$Camera2D.zoom = Vector2(5, 5)
				upper_sprite.play("sit")
				lower_sprite.play("sit")
				
				if (Input.is_anything_pressed()):
					animation_player.play("zoom_out")
					state = state_type.MOVING
		state_type.MOVING:
			#handle gravity and jumping
			if is_on_floor():
				air_time = 0
				double_jump = 0
				coyote_time_counter = COYOTE_TIME
			else:
				air_time += delta
				air_time = clamp(air_time, 0, MAX_AIR_TIME)
				
				if (abs(velocity.y) < HANG_TIME_THRESHHOLD):
					velocity.y += (GRAVITY + (EXTRA_GRAVITY * air_time) ) * HANG_TIME_MULTIPLIER * delta
				else:
					velocity.y += (GRAVITY + (EXTRA_GRAVITY * air_time)) * delta
				
				coyote_time_counter -= delta
				
			if (Input.is_action_just_pressed("jump")):
				jump_buffer_time = JUMP_BUFFER
			else:
				jump_buffer_time -= delta
			
			if (double_jump_active):
				if (jump_buffer_time > 0 && double_jump < 2):
					double_jump += 1
					dust_particles.emitting = true
					velocity.y = JUMP_VELOCITY
					jump_buffer_time = 0
			elif (jump_buffer_time > 0 && coyote_time_counter > 0):
				dust_particles.emitting = true
				velocity.y = JUMP_VELOCITY
				jump_buffer_time = 0
			
			if (Input.is_action_just_released("jump") && velocity.y < 0): #jump height control
				velocity.y *= 0.5
				coyote_time_counter = 0
				
			#Change Animation States
			if is_on_floor():
				if (direction == 0):
					change_animation_state(animation_type.IDLE)
					footstep_audio.stop()
				else:
					change_animation_state(animation_type.RUN)
					if (!footstep_audio.is_playing()):
						footstep_audio.play()
			else:
				footstep_audio.stop()
				if (velocity.y < 0):
					change_animation_state(animation_type.JUMP)
				else:
					change_animation_state(animation_type.FALL)
		state_type.CLIMBING:
			change_animation_state(animation_type.CLIMB)
			velocity.y = 0
			
			if (Input.is_action_pressed("move_up")):
				velocity.y = -CLIMB_SPEED
			elif (Input.is_action_pressed("move_down")):
				velocity.y = CLIMB_SPEED
		state_type.ZIPLINE:
			change_animation_state(animation_type.CLIMB)
			velocity = Vector2.ZERO

	#get input direction
	direction = Input.get_axis("move_left", "move_right")
	
	#flips sprite
	if (direction > 0):
		player_facing = 1
		upper_sprite.flip_h = false
		lower_sprite.flip_h = false
	elif (direction < 0):
		player_facing = -1
		upper_sprite.flip_h = true
		lower_sprite.flip_h = true
		
	#Slippery Surfaces
	#var test_tile: TileData
	#var tile_map := get_tree().get_root().get_node("game/Level/%s/TileMap" % GameManager.current_level)
	#friction_multiplier = 1.0
	#for layer in range(tile_map.get_layers_count()):
	#	test_tile = tile_map.get_cell_tile_data(layer, tile_map.local_to_map(Vector2(global_position.x, global_position.y + 1)))
	#	if (test_tile != null):
	#		if (test_tile.get_custom_data("slippery")):
	#			friction_multiplier = 0.1
		
	#Apply movement
	if (state != state_type.ZIPLINE):
		if (abs(knock_back.x) > 0 || direction):
			velocity.x = (direction * SPEED) + knock_back.x
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION_FORCE * friction_multiplier)
	
	velocity.y += knock_back.y
	
	#knock-back falloff
	knock_back.x = move_toward(knock_back.x, 0, KNOCK_BACK_FALLOFF)
	knock_back.y = move_toward(knock_back.y, 0, KNOCK_BACK_FALLOFF * 1.5)
	
	if (knock_back.length_squared() < 0.01):
		knock_back = Vector2.ZERO
	
	move_and_slide()
	
func change_animation_state(new_state : animation_type):	
	if (dial_created):
		if (animation_queue.size() == 0):
			animation_queue.push_back("cast")
			upper_sprite.play(animation_queue[0])
	else:
		animation_queue.clear()
		
	if (animation_state != new_state):
		animation_queue.clear()
	
	match new_state:
		animation_type.RUN:
			if (dial_created):
				if (!animation_queue.has("cast_run")):
					animation_queue.push_back("cast_run")
					upper_sprite.play(animation_queue[0])
			elif (!cast_complete):
				upper_sprite.play("run")
			else:
				upper_sprite.play("cast_done")
			lower_sprite.play("run")
		animation_type.IDLE:
			if (dial_created):
				if (!animation_queue.has("cast_idle")):
					animation_queue.push_back("cast_idle")
					upper_sprite.play(animation_queue[0])
			elif (!cast_complete):
				upper_sprite.play("idle")
			else:
				upper_sprite.play("cast_done")
			lower_sprite.play("idle")
		animation_type.SIT:
			upper_sprite.play("sit")
			lower_sprite.play("sit")
		animation_type.JUMP:
			if (dial_created):
				if (!animation_queue.has("cast_hold")):
					animation_queue.push_back("cast_hold")
					upper_sprite.play(animation_queue[0])
			elif (!cast_complete):
				upper_sprite.play("jump")
			else:
				upper_sprite.play("cast_done")
			lower_sprite.play("jump")
		animation_type.FALL:
			if (dial_created):
				if (!animation_queue.has("cast_hold")):
					animation_queue.push_back("cast_hold")
					upper_sprite.play(animation_queue[0])
			elif (!cast_complete):
				upper_sprite.play("fall")
			else:
				upper_sprite.play("cast_done")
			lower_sprite.play("fall")
		animation_type.CLIMB:
			upper_sprite.play("climb")
			lower_sprite.play("climb")
	
	animation_state = new_state
	
func _on_upper_sprite_animation_finished():
	if (animation_queue.size() > 0):
		animation_queue.pop_front()
		upper_sprite.play(animation_queue[0])
		
	if (cast_complete):
		cast_complete = false

#PLAYER LOGIC FUNCTIONS
func apply_knockback(other_pos: Vector2, force: float):
		var other_dir = (other_pos - player_center.global_position).normalized()
		knock_back = -other_dir * force

func heal_player(health: int):
	animation_player.play("player_heal")
	
	player_health += health
	if (player_health > max_health): player_health = max_health
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = health
	damage_indicator.damage_indicator_color = "5ab552"
	damage_indicator.position = player_center.global_position
	get_tree().get_root().get_node("game/Level").add_child(damage_indicator)

func hurt_player(damage: int, other_pos: Vector2, force: float):
	if (!invincible):
		animation_player.play("player_hurt")
		play_sound("hurt")
		set_screen_shake(0.5)
		apply_knockback(other_pos, force)
		
		player_health -= damage
		player_health = max(player_health, 0)
		
		var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
		damage_indicator.damage_amount = damage
		damage_indicator.damage_indicator_color = "ec273f"
		damage_indicator.global_position = player_center.global_position
		get_tree().get_root().get_node("game/Level").add_child(damage_indicator)
	
func disable_player():
	set_process(false)
	set_physics_process(false)
	player_collider.set_deferred("disabled", true)
	#$hud.visible = false
	visible = false
	#$Camera2D.enabled = false
	marked_dead = true
	
func reset_player():
	set_process(true)
	set_physics_process(true)
	player_collider.set_deferred("disabled", false)
	visible = true
	marked_dead = false
	
	global_position = get_tree().get_root().get_node("game/Level/%s/spawn_point" % GameManager.current_level).global_position
	$level_transition.get_node("AnimationPlayer").play("fade_in")
	player_lives = MAX_LIVES
	player_health = max_health
	
func enable_collision(enabled: bool):
	player_collider.disabled = !enabled

func set_screen_shake(amount: float):
	camera.add_trauma(amount)
	
func play_sound(sound_name: String):
	const PITCH_RANGE := 0.1
	var pitch_shift := randf_range(-PITCH_RANGE, PITCH_RANGE)
	audio_player.pitch_scale = 1 + pitch_shift
	audio_player.set_stream(sound_library[sound_name])
	audio_player.play()

#INVENTORY FUNCTIONS
func inventory_scrolling(scroll_amount: int):
		selected_slot_pos += scroll_amount
		
		#wrap scrolling
		if (selected_slot_pos > inventory.size() - 1): 
			selected_slot_pos = 0
		elif (selected_slot_pos < 0):
			selected_slot_pos = inventory.size() - 1
		
		currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
		update_spell_placeholder()
		
func inventory_hotkey():
	if (Input.is_action_just_pressed("slot_1")):
		currently_selected_slot = inventory[inventory.keys()[0]]
	if (Input.is_action_just_pressed("slot_2")):
		currently_selected_slot = inventory[inventory.keys()[1]]
	if (Input.is_action_just_pressed("slot_3")):
		currently_selected_slot = inventory[inventory.keys()[2]]
		
func update_spell_placeholder():
	if (dial_created && currently_selected_slot.get_spell_instance() != null):
			spell_instance = load(currently_selected_slot.get_spell_instance()).instantiate()
			dial_instance.set_placeholder_sprite(spell_instance.get_sprite_path())
		
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
	play_sound("soul")
	souls_collected += 1
	
func collect_coin():
	play_sound("coin")
	coins_collected += 1
	
func colllect_spell(spell_type):
	for slot in inventory:
		if inventory[slot].get_slot_item() == "empty":
			inventory[slot].set_slot_item(spell_type)
			play_sound("tome")
			break
