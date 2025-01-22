extends Node
var DEBUG_MODE := true
var started_game := false
var current_level: String
var access_ingame_menu := true
var access_shop_menu := true
var continues := 0
var can_drop_cursor = load("res://assets/sprites/UI/cursor can drop.png")
var can_not_drop_cursor = load("res://assets/sprites/UI/cursor cancel.png")
var visible_hud := true

func _ready():
	Input.set_custom_mouse_cursor(can_drop_cursor, Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(can_not_drop_cursor, Input.CURSOR_FORBIDDEN)
