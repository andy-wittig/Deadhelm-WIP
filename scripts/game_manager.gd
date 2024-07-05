extends Node

var username := "unknown"
var host_mode_enabled = false
var multiplayer_mode_enabled = false
var started_game := false

var can_drop_cursor = load("res://assets/sprites/cursor can drop.png")
var can_not_drop_cursor = load("res://assets/sprites/cursor cancel.png")

func _ready():
	Input.set_custom_mouse_cursor(can_drop_cursor, Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(can_not_drop_cursor, Input.CURSOR_FORBIDDEN)
