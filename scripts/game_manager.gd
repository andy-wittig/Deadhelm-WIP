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
var current_run_time : float
var runtime_enabled := true
var show_runtime := false
var game_completed := false

func _ready():
	Input.set_custom_mouse_cursor(can_drop_cursor, Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(can_not_drop_cursor, Input.CURSOR_FORBIDDEN)
	
func save_runtime():
	if not FileAccess.file_exists("user://runtime.save"):
		FileAccess.open("user://runtime.save", FileAccess.WRITE)
	
	runtime_enabled = false
	var runtime_file = FileAccess.open("user://runtime.save", FileAccess.READ_WRITE)
	
	runtime_file.seek_end()
	runtime_file.store_line(str(current_run_time))
	runtime_file.close()
	
	get_tree().call_group("stats", "load_runtime")
