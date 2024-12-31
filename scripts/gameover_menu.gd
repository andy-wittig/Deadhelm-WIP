extends Control

@onready var menu_layer = $"../.."
@onready var game = $"../../.."
@onready var continue_label = $VBoxContainer/ContinueLabel
@onready var grey_scale_canvas = $GreyScaleCanvas

var menu_started := false

func menu_opened():
	if (!menu_started):
		$VBoxContainer/RetryButton.grab_focus()
		menu_started = true
		
func _process(_delta):
	continue_label.text = "continues: %s" % GameManager.continues
	
	grey_scale_canvas.visible = menu_started
	
func _on_return_button_pressed():
	menu_started = false
	GameManager.started_game = false
	game.end_level()
	menu_layer.current_menu = menu_layer.menu.MAIN
	
func _on_retry_button_pressed():
	menu_started = false
	GameManager.continues += 1
	get_tree().call_group("players", "reset_player")
	menu_layer.current_menu = menu_layer.menu.HIDDEN
