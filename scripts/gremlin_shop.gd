extends Area2D

@export var shop_listings: Array[String]

var menu_opened := false
var player: CharacterBody2D
var random = RandomNumberGenerator.new()

@onready var gremlin_squabbles = [
	load("res://assets/sound effects/shop_gremlin/gremlin_1.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_2.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_3.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_4.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_5.mp3"),
]
@onready var shop_items = {
	"heart_crystal" : ["res://assets/sprites/UI/shop/heart_crystal.png", 12, "returns one lost life"],
	"defense_upgrade" : ["res://assets/sprites/UI/shop/defense_upgrade.png", 10, "buffs total health by +10"],
	"double_jump" : ["res://assets/sprites/UI/shop/double_jump.png", 20, "provides a second jump ability"],
	"health_potion" : ["res://assets/sprites/UI/shop/health_potion.png", 5, "heals the player by +25"],
}
@onready var price_labels := [
	$ShopControl/PriceLabel1,
	$ShopControl/PriceLabel2,
	$ShopControl/PriceLabel3,
]
@onready var item_textures = [
	$ShopControl/ItemTexture1,
	$ShopControl/ItemTexture2,
	$ShopControl/ItemTexture3,
]
@onready var soldout_textures = [
	$ShopControl/SoldOutTexture1,
	$ShopControl/SoldOutTexture2,
	$ShopControl/SoldOutTexture3,
]

@onready var shop_sprite = $AnimatedSprite2D
@onready var shop_control = $ShopControl
@onready var animation_player = $AnimationPlayer
@onready var squabble_audio = $SquabbleAudio

func _ready():
	shop_control.visible = false
	for i in range(shop_listings.size()):
		item_textures[i].texture = load(shop_items[shop_listings[i]][0])
		price_labels[i].text = str(shop_items[shop_listings[i]][1])

func _process(delta):
	if (menu_opened):
		shop_control.visible = true
		shop_sprite.material.set_shader_parameter("enabled", false)
		
		for i in range(shop_listings.size()):
			var cost = shop_items[shop_listings[i]][1]
			if (player.coins_collected >= cost):
				soldout_textures[i].visible = false
			else:
				soldout_textures[i].visible = true
		
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				player = body
				if (!menu_opened): shop_sprite.material.set_shader_parameter("enabled", true)
				if Input.is_action_just_pressed("pickup"):
					menu_opened = !menu_opened
					if (menu_opened): animation_player.play("open_menu")
					else: animation_player.play_backwards("open_menu")
			return
	shop_sprite.material.set_shader_parameter("enabled", false)
	animation_player.play_backwards("open_menu")
	menu_opened = false

func _on_input_event(viewport, event, shape_idx):
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				player = body
				if (Input.is_action_just_pressed("left_click")):
					menu_opened = !menu_opened
					if (menu_opened): animation_player.play("open_menu")
					else: animation_player.play_backwards("open_menu")

func _on_animation_player_animation_finished(anim_name):
	if (!menu_opened):
		shop_control.visible = false

func _on_purchase_button_1_pressed():
	var cost = shop_items[shop_listings[0]][1]
	if (player.coins_collected >= cost):
		player.collect_buff(shop_listings[0])
		player.coins_collected -= cost

func _on_purchase_button_2_pressed():
	var cost = shop_items[shop_listings[1]][1]
	if (player.coins_collected >= cost):
		player.collect_buff(shop_listings[1])
		player.coins_collected -= cost

func _on_purchase_button_3_pressed():
	var cost = shop_items[shop_listings[2]][1]
	if (player.coins_collected >= cost):
		player.collect_buff(shop_listings[2])
		player.coins_collected -= cost


func _on_squabble_timer_timeout():
	var choice = random.randi_range(0, 3)
	squabble_audio.set_stream(gremlin_squabbles[choice])
	squabble_audio.play()
