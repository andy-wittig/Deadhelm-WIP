extends CharacterBody2D

#Physics Constants
const SPEED = 75.0
const CLIMB_SPEED = 60.0
const JUMP_VELOCITY = -250.0
const KNOCK_BACK_FALLOFF := 60.0
#Physics Variables
var grounded: bool
var knock_back: Vector2
#Player Stats Variables
var player_health = 100
var souls_collected = 0
var coins_collected = 0
#Player Mechanics Variables
var dial_instance = null
var dial_created = false
var attack_cooldown = false
enum state_type {MOVING, CLIMBING}
var state := state_type.MOVING
#Player Inventory Variables
var selected_slot_pos = 0
var currently_selected_slot = null
var spell_instance = null

#Sprite Paths
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
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
@onready var footstep_audio = $FootstepAudio
@onready var spell_cast_audio = $SpellCastAudio
#Mechanics Paths
@onready var attack_cooldown_timer = $AttackCooldownTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _on_attack_cooldown_timer_timeout():
	attack_cooldown = false
	
func drop_inventory_item(spell_type, pos):
	var tome = load("res://scenes/player/spells/tome.tscn").instantiate()
	tome.spell_type = spell_type
	tome.position.x = pos.x
	tome.position.y = pos.y - 16
	get_tree().get_root().add_child(tome)
	
func _ready():
	$Camera2D.reset_smoothing()
	currently_selected_slot = inventory[inventory.keys()[selected_slot_pos]]
	currently_selected_slot.currently_selected = true
	
func _process(delta):
	healthbar_label.text = str(player_health) + "/100"
	soul_label.text = str(souls_collected)
	money_label.text = "$" + str(coins_collected)
	
	#Handle Inventory Input
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
			drop_inventory_item(currently_selected_slot.get_slot_item(), global_position)
			currently_selected_slot.set_slot_item("empty")
			
	
	if (currently_selected_slot.get_slot_item() != "empty"):
		#Trigger Mystic Dial
		if not attack_cooldown:
			if Input.is_action_just_pressed("right_click"):
				spell_instance = load(currently_selected_slot.get_spell_instance()).instantiate()
				dial_instance = load("res://scenes/player/mystic_dial.tscn").instantiate()
				get_parent().add_child(dial_instance)
				dial_instance.position.x = position.x
				dial_instance.position.y = position.y - 16
				dial_instance.player = self
				dial_instance.set_placeholder_sprite(spell_instance.get_sprite_path())
				dial_created = true
		#Fire Mystic Dial
		if (dial_created):
			if Input.is_action_just_pressed("left_click"):
				var mouse_pos = get_global_mouse_position()
				var mouse_dir = (mouse_pos - dial_instance.global_position).normalized()
				spell_instance.player = self
				spell_instance.direction = mouse_dir
				spell_instance.position = dial_instance.global_position + mouse_dir * dial_instance.DIAL_RADIUS
				get_tree().get_root().add_child(spell_instance)
				spell_cast_audio.play()
				
				dial_instance.destroy()
				attack_cooldown_timer.start(2)
				attack_cooldown = true
				dial_created = false
	#Release Dial		
	if Input.is_action_just_released("right_click"):
			if (dial_created):
				dial_instance.destroy()
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
	
func apply_knockback(other_pos: Vector2, force: float):
		var other_dir = (other_pos - global_position).normalized()
		knock_back = -other_dir * force

func hurt_player(damage: int, other_pos: Vector2, force: float):
	animation_player.play("player_hurt")
	player_hurt_audio.play()
	apply_knockback(other_pos, force)
	
	player_health -= damage
	healthbar.value = player_health
	player_health = max(player_health, 0)
	
	var damage_indicator = load("res://scenes/player/damage_indicator.tscn").instantiate()
	damage_indicator.damage_amount = damage
	damage_indicator.position = global_position
	get_tree().get_root().add_child(damage_indicator)
	
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
	
func is_inventory_full():
	for slot in inventory:
		if inventory[slot].get_slot_item() == "empty":
			return false
	return true
