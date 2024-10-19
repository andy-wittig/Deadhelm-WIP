extends Area2D

@export var shop_listings: Array[String]

var menu_opened := false
var player: CharacterBody2D
var random := RandomNumberGenerator.new()

@onready var gremlin_squabbles = [
	load("res://assets/sound effects/shop_gremlin/gremlin_1.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_2.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_3.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_4.mp3"),
	load("res://assets/sound effects/shop_gremlin/gremlin_5.mp3"),
]
@onready var shop_items = {
	"heart_crystal" : ["res://assets/sprites/UI/shop/heart_crystal.png", 12, "returns one lost life", false],
	"defense_upgrade" : ["res://assets/sprites/UI/shop/defense_upgrade.png", 8, "buffs total health by +10", false],
	"double_jump" : ["res://assets/sprites/UI/shop/double_jump.png", 15, "provides a second jump ability", false],
	"health_potion" : ["res://assets/sprites/UI/shop/health_potion.png", 5, "heals the player by +25", false],
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
@onready var soldout_rects = [
	$ShopControl/SoldOutShader1,
	$ShopControl/SoldOutShader2,
	$ShopControl/SoldOutShader3,
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
	if (!GameManager.access_ingame_menu): #close shop if ingame menu is overlapping
		menu_opened = false
		animation_player.play_backwards("open_menu")
		
	if (menu_opened):
		shop_control.visible = true
		shop_sprite.material.set_shader_parameter("enabled", false)
		
		#Shop descriptions
		if ($ShopControl/PurchaseButton1.has_focus()):
			$ItemDescriptionLabel.text = (shop_listings[0] + ": " + shop_items[shop_listings[0]][2])
		elif ($ShopControl/PurchaseButton2.has_focus()):
			$ItemDescriptionLabel.text = (shop_listings[1] + ": " + shop_items[shop_listings[1]][2])
		elif ($ShopControl/PurchaseButton3.has_focus()):
			$ItemDescriptionLabel.text = (shop_listings[2] + ": " + shop_items[shop_listings[2]][2])
				
		#Setiing shop prices
		for i in range(shop_listings.size()):
			shop_items[shop_listings[i]][3] = true
			var cost = shop_items[shop_listings[i]][1]
			
			match shop_listings[i]: #ensure player can't buy something they don't need
				"heart_crystal":
					if (player.player_lives >= player.MAX_LIVES):
						shop_items[shop_listings[i]][3] = false
				"defense_upgrade":
					if (player.max_health >= player.MAX_UPGRADED_HEALTH):
						shop_items[shop_listings[i]][3] = false
				"health_potion":
					if (player.player_health >= player.max_health):
						shop_items[shop_listings[i]][3] = false
				"double_jump":
					if (player.double_jump_active):
						shop_items[shop_listings[i]][3] = false
			
			if (player.coins_collected <= cost):
				shop_items[shop_listings[i]][3] = false		
				
			if (shop_items[shop_listings[i]][3]):
				soldout_rects[i].material.set_shader_parameter("enabled", false)
			else:
				soldout_rects[i].material.set_shader_parameter("enabled", true)
		
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				player = body
				if (!menu_opened): shop_sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup")):
					menu_opened = !menu_opened
					if (menu_opened): animation_player.play("open_menu")
					else: animation_player.play_backwards("open_menu")
			return
	shop_sprite.material.set_shader_parameter("enabled", false)
	animation_player.play_backwards("open_menu")
	menu_opened = false

func _on_animation_player_animation_finished(anim_name):
	if (!menu_opened):
		$ItemDescriptionLabel.visible = false
		shop_control.visible = false
	else:
		$ShopControl/PurchaseButton1.grab_focus()
		$ItemDescriptionLabel.visible = true

func _on_purchase_button_1_pressed():
	var cost = shop_items[shop_listings[0]][1]
	if (shop_items[shop_listings[0]][3]):
		player.collect_buff(shop_listings[0])
		player.coins_collected -= cost

func _on_purchase_button_2_pressed():
	var cost = shop_items[shop_listings[1]][1]
	if (shop_items[shop_listings[1]][3]):
		player.collect_buff(shop_listings[1])
		player.coins_collected -= cost

func _on_purchase_button_3_pressed():
	var cost = shop_items[shop_listings[2]][1]
	if (shop_items[shop_listings[2]][3]):
		player.collect_buff(shop_listings[2])
		player.coins_collected -= cost
		
func _on_squabble_timer_timeout():
	var choice = random.randi_range(0, 3)
	squabble_audio.set_stream(gremlin_squabbles[choice])
	squabble_audio.play()

func _on_purchase_button_1_mouse_entered():
	$ShopControl/PurchaseButton1.grab_focus()

func _on_purchase_button_2_mouse_entered():
	$ShopControl/PurchaseButton2.grab_focus()

func _on_purchase_button_3_mouse_entered():
	$ShopControl/PurchaseButton3.grab_focus()
