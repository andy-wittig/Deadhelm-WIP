extends Area2D

@export var shop_listings: Array[String]

var menu_opened := false
@onready var shop_items = {
	"heart_crystal" : ["res://assets/sprites/UI/shop/heart_crystal.png", 10],
	"defense_upgrade" : ["res://assets/sprites/UI/shop/defense_upgrade.png", 8],
}
@onready var price_labels := [
	$ShopMenuSprite/PriceLabel1,
	$ShopMenuSprite/PriceLabel2,
	$ShopMenuSprite/PriceLabel3,
]
@onready var item_textures = [
	$ShopMenuSprite/ItemTexture1,
	$ShopMenuSprite/ItemTexture2,
	$ShopMenuSprite/ItemTexture3,
]

@onready var shop_sprite = $AnimatedSprite2D
@onready var shop_menu_sprite = $ShopMenuSprite

func _ready():
	#print (shop_items[shop_listings[0]][0])
	for i in range(shop_listings.size()):
		item_textures[i].texture = load(shop_items[shop_listings[i]][0])
		price_labels[i].text = str(shop_items[shop_listings[i]][1])

func _process(delta):
	if (menu_opened):
		shop_menu_sprite.visible = true
		shop_sprite.material.set_shader_parameter("enabled", false)
	else:
		shop_menu_sprite.visible = false
		
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (!menu_opened): shop_sprite.material.set_shader_parameter("enabled", true)
				if Input.is_action_just_pressed("pickup"):
					menu_opened = !menu_opened
			return
	shop_sprite.material.set_shader_parameter("enabled", false)
	menu_opened = false

func _on_input_event(viewport, event, shape_idx):
	for body in get_overlapping_bodies():
		if (body.is_in_group("players") && !menu_opened):
			if (!GameManager.multiplayer_mode_enabled ||
			body.player_id == multiplayer.get_unique_id()):
				if (Input.is_action_just_pressed("left_click")):
					menu_opened = true
