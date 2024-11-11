extends Area2D

@export var blacksmith_listings: Array[String]

var menu_opened := false
var player: CharacterBody2D

@onready var blacksmith_items = {
	"double_jump" : ["res://assets/sprites/UI/shop/double_jump.png", 15, "provides a second jump ability", false],
}
@onready var price_labels := [
	$BlacksmithControl/PriceLabel1,
	$BlacksmithControl/PriceLabel2,
	$BlacksmithControl/PriceLabel3,
]
@onready var item_textures = [
	$BlacksmithControl/ItemTexture1,
	$BlacksmithControl/ItemTexture2,
	$BlacksmithControl/ItemTexture3,
]
@onready var soldout_rects = [
	$BlacksmithControl/BackBufferCopy/SoldOutShader1,
	$BlacksmithControl/BackBufferCopy/SoldOutShader2,
	$BlacksmithControl/BackBufferCopy/SoldOutShader3,
]

@onready var blacksmith_sprite = $AnimatedSprite2D
@onready var blacksmith_control = $BlacksmithControl
@onready var animation_player = $AnimationPlayer

func _ready():
	blacksmith_control.visible = false
	
	for i in range(blacksmith_listings.size()):
		item_textures[i].texture = load(blacksmith_items[blacksmith_listings[i]][0])
		price_labels[i].text = str(blacksmith_items[blacksmith_listings[i]][1])

func _process(delta):
	if (!GameManager.access_ingame_menu): #close shop if ingame menu is overlapping
		menu_opened = false
		animation_player.play_backwards("open_menu")
		
	if (menu_opened):
		blacksmith_control.visible = true
		blacksmith_sprite.material.set_shader_parameter("enabled", false)
		
		#Shop descriptions
		if ($BlacksmithControl/PurchaseButton1.has_focus()):
			$ItemDescriptionLabel.text = (blacksmith_listings[0] + ": " + blacksmith_items[blacksmith_listings[0]][2])
		elif ($BlacksmithControl/PurchaseButton2.has_focus()):
			$ItemDescriptionLabel.text = (blacksmith_listings[1] + ": " + blacksmith_items[blacksmith_listings[1]][2])
		elif ($BlacksmithControl/PurchaseButton3.has_focus()):
			$ItemDescriptionLabel.text = (blacksmith_listings[2] + ": " + blacksmith_items[blacksmith_listings[2]][2])
				
		#Setiing shop prices
		for i in range(blacksmith_listings.size()):
			blacksmith_items[blacksmith_listings[i]][3] = true
			var cost = blacksmith_items[blacksmith_listings[i]][1]
			
			match blacksmith_listings[i]: #ensure player can't buy something they don't need
				"double_jump":
					if (player.double_jump_active):
						blacksmith_items[blacksmith_listings[i]][3] = false
			
			if (player.coins_collected <= cost):
				blacksmith_items[blacksmith_listings[i]][3] = false
				
			if (blacksmith_items[blacksmith_listings[i]][3]):
				soldout_rects[i].material.set_shader_parameter("enabled", false)
			else:
				soldout_rects[i].material.set_shader_parameter("enabled", true)
		
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				player = body
				if (!menu_opened): blacksmith_sprite.material.set_shader_parameter("enabled", true)
				if (Input.is_action_just_pressed("pickup")):
					menu_opened = !menu_opened
					if (menu_opened): animation_player.play("open_menu")
					else: animation_player.play_backwards("open_menu")
			return
	blacksmith_sprite.material.set_shader_parameter("enabled", false)
	animation_player.play_backwards("open_menu")
	menu_opened = false

func _on_animation_player_animation_finished(anim_name):
	if (!menu_opened):
		$ItemDescriptionLabel.visible = false
		blacksmith_control.visible = false
	else:
		$BlacksmithControl/PurchaseButton1.grab_focus()
		$ItemDescriptionLabel.visible = true

func _on_purchase_button_1_pressed():
	var cost = blacksmith_items[blacksmith_listings[0]][1]
	if (blacksmith_items[blacksmith_listings[0]][3]):
		player.collect_buff(blacksmith_listings[0])
		player.coins_collected -= cost

func _on_purchase_button_2_pressed():
	var cost = blacksmith_items[blacksmith_listings[1]][1]
	if (blacksmith_items[blacksmith_listings[1]][3]):
		player.collect_buff(blacksmith_listings[1])
		player.coins_collected -= cost

func _on_purchase_button_3_pressed():
	var cost = blacksmith_items[blacksmith_listings[2]][1]
	if (blacksmith_items[blacksmith_listings[2]][3]):
		player.collect_buff(blacksmith_listings[2])
		player.coins_collected -= cost

func _on_purchase_button_1_mouse_entered():
	$BlacksmithControl/PurchaseButton1.grab_focus()

func _on_purchase_button_2_mouse_entered():
	$BlacksmithControl/PurchaseButton2.grab_focus()

func _on_purchase_button_3_mouse_entered():
	$BlacksmithControl/PurchaseButton3.grab_focus()
