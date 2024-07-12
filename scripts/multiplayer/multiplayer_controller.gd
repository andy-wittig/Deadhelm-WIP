extends CharacterBody2D

#Physics Constants
const SPEED = 75.0
const CLIMB_SPEED = 60.0
const JUMP_VELOCITY = -250.0

#Physics Variables
var grounded: bool
var hor_direction = 1
var ver_direction = 1
var jumped = false
var _is_on_floor = true
#Player Stats Variables
var username := ""
var player_health = 100
var souls_collected = 0
var coins_collected = 0
#Player Mechanics Variables
var dial_instance = null
var dial_created = false
var attack_cooldown = false
enum state_type {MOVING, CLIMBING}
var state := state_type.MOVING
#Player UI Variables
var selected_slot_pos = 0
var currently_selected_slot = null
var is_in_chat := false
#Multiplayer Variables
@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id) #only client has acess to change inputs

#Sprite Paths
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var username_label = $Username
#UI Paths
@onready var inventory = {
	"slot_1" : $hud/Control/GridContainer/Slots/ItemSlot1.get_node("Item"),
	"slot_2" : $hud/Control/GridContainer/Slots/ItemSlot2.get_node("Item"),
	"slot_3" : $hud/Control/GridContainer/Slots/ItemSlot3.get_node("Item"),
}
@onready var healthbar = $hud/Control/GridContainer/Healthbar
@onready var healthbar_label = $hud/Control/GridContainer/Healthbar/HealthbarLabel
@onready var soul_label = $hud/Control/GridContainer/VBoxContainer/SoulCounter/SoulCounterLabel
@onready var money_label = $hud/Control/GridContainer/VBoxContainer/MoneyCounter/MoneyCounterLabel
#Audio Paths
@onready var coin_pickup_audio_player = $CoinPickupAudio
@onready var tome_pickup_audio = $TomePickupAudio
@onready var soul_pickup_audio = $SoulPickupAudio
@onready var player_hurt_audio = $PlayerHurtAudio
#Mechanics Paths
@onready var attack_cooldown_timer = $AttackCooldownTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		
func _ready():
	currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
	currently_selected_slot.currently_selected = true
	
	if multiplayer.get_unique_id() == player_id: #player_id is client
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false
		$hud.visible = false
	
@rpc ("call_local", "any_peer")
func drop_inventory_item(spell_type, pos):
	var tome = load("res://scenes/tome.tscn").instantiate()
	tome.spell_type = spell_type
	tome.position.x = pos.x
	tome.position.y = pos.y - 16
	get_tree().get_root().add_child(tome)

@rpc("any_peer", "call_local")
func create_spell(path, dir, pos): 
	var new_spell = load(path).instantiate()
	new_spell.direction = dir
	new_spell.position = pos
	get_tree().get_root().add_child(new_spell)
	
@rpc ("any_peer", "call_local")
func apply_knockback(other_pos):
	var knock_back = 100
	if (other_pos < self.global_position.x):
		self.velocity = Vector2(knock_back * 2.5, -knock_back)
	else:
		self.velocity = Vector2(-knock_back * 2.5, -knock_back)
		
@rpc("any_peer", "call_local")
func hurt_player(damage: int, other_pos: float):
	animation_player.play("player_hurt")
	rpc("apply_knockback", other_pos)
	
	player_health -= damage
	healthbar.value = player_health
	player_health = max(player_health, 0)
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = damage
	damage_indicator.position = global_position
	get_tree().get_root().add_child(damage_indicator)

func _process(_delta):	
	if (multiplayer.get_unique_id() == player_id):
		healthbar_label.text = str(player_health) + "/100"
		soul_label.text = str(souls_collected)
		money_label.text = "$" + str(coins_collected)
		
		#handle inventory input
		if (Input.is_action_just_pressed("scroll_up")):
			selected_slot_pos += 1
			selected_slot_pos = clamp(selected_slot_pos, 0 , inventory.size() - 1)
			currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
			for slot in inventory:
				inventory[slot].currently_selected = false
			currently_selected_slot.currently_selected = true
			
		if (Input.is_action_just_pressed("scroll_down")):
			selected_slot_pos -= 1
			selected_slot_pos = clamp(selected_slot_pos, 0 , inventory.size() - 1)
			currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
			for slot in inventory:
				inventory[slot].currently_selected = false
			currently_selected_slot.currently_selected = true
			
		if (Input.is_action_just_pressed("drop_item")):
			if (currently_selected_slot.get_slot_item() != "empty" && !currently_selected_slot.dragging):
				rpc("drop_inventory_item", currently_selected_slot.get_slot_item(), global_position)
				currently_selected_slot.set_slot_item("empty")
		
		if (currently_selected_slot.get_slot_item() != "empty"):
			#Trigger Mystic Dial
			if not attack_cooldown:
				if Input.is_action_just_pressed("right_click"):
					var spell_placeholder_instance = load(currently_selected_slot.get_spell_instance()).instantiate()
					dial_instance = load("res://scenes/player/mystic_dial.tscn").instantiate()
					get_parent().add_child(dial_instance)
					dial_instance.position.x = position.x
					dial_instance.position.y = position.y - 16
					dial_instance.player = self
					dial_instance.set_placeholder_sprite(spell_placeholder_instance.get_sprite_path())
					dial_created = true
			#Fire Mystic Dial
			if (dial_created):
				if Input.is_action_just_pressed("left_click"):
					var mouse_pos = get_global_mouse_position()
					var mouse_dir = (mouse_pos - dial_instance.global_position).normalized()
					var spell_pos = dial_instance.global_position + mouse_dir * dial_instance.DIAL_RADIUS
					var spell_path = currently_selected_slot.get_spell_instance()
					rpc("create_spell", spell_path, mouse_dir, spell_pos)
					
					dial_instance.destroy()
					attack_cooldown_timer.start(2)
					attack_cooldown = true
					dial_created = false
		#Release Dial		
		if Input.is_action_just_released("right_click"):
				if (dial_created):
					dial_instance.destroy()
					dial_created = false
					
func colllect_spell(spell_type):
	for slot in inventory:
		if inventory[slot].get_slot_item() == "empty":
			inventory[slot].set_slot_item(spell_type)
			tome_pickup_audio.play()
			break
	
func is_inventory_full():
	for slot in inventory:
		if inventory[slot].get_slot_item() == "empty":
			return false
	return true

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
				velocity.y += gravity * delta
			#jumping
			if jumped and is_on_floor() and not is_in_chat:
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
		grounded = is_on_floor()
		_apply_movement_from_input(delta)
		username = %InputSynchronizer.username
		
	if not multiplayer.is_server() || GameManager.host_mode_enabled:
		_apply_animations(delta)
		if (username_label && username != ""):
			username_label.set_text(username)
	
func collect_soul():
	soul_pickup_audio.play()
	souls_collected += 1
	
func collect_coin():
	coin_pickup_audio_player.play()
	coins_collected += 1
	
func _on_attack_cooldown_timer_timeout():
	attack_cooldown = false
