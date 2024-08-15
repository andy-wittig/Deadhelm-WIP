extends Area2D

@export var shop_listings: Array[String]

var menu_opened := false
@onready var shop_items = {
	"heart_crystal" : ["res://assets/sprites/UI/shop/heart_crystal.png", 10],
	"defense_upgrade" : ["res://assets/sprites/UI/shop/defense_upgrade.png", 8],
}
@onready var price_labels := [
	$ShopControl/ShopMenuSprite/PriceLabel1,
	$ShopControl/ShopMenuSprite/PriceLabel2,
	$ShopControl/ShopMenuSprite/PriceLabel3,
]
@onready var item_textures = [
	$ShopControl/ShopMenuSprite/ItemTexture1,
	$ShopControl/ShopMenuSprite/ItemTexture2,
	$ShopControl/ShopMenuSprite/ItemTexture3,
]

@onready var shop_sprite = $AnimatedSprite2D
@onready var shop_control = $ShopControl
@onready var animation_player = $AnimationPlayer

func _ready():
	shop_control.visible = false
	for i in range(shop_listings.size()):
		item_textures[i].texture = load(shop_items[shop_listings[i]][0])
		price_labels[i].text = str(shop_items[shop_listings[i]][1])

func _process(delta):
	if (menu_opened):
		shop_control.visible = true
		shop_sprite.material.set_shader_parameter("enabled", false)
		
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
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
				if (Input.is_action_just_pressed("left_click")):
					menu_opened = !menu_opened
					if (menu_opened): animation_player.play("open_menu")
					else: animation_player.play_backwards("open_menu")

func _on_animation_player_animation_finished(anim_name):
	if (!menu_opened):
		shop_control.visible = false
