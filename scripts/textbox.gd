extends Control

var menu_started := false
var show_message := false
const MESSAGE_SPEED_MULTIPLIER := 0.6
@onready var text = $Text

func menu_opened():
	if (!menu_started):
		menu_started = true
		
func start_textbox(npc_text_path : String):
	var tween: Tween = create_tween()
	var text_length = text.get_total_character_count()
	tween.tween_property(text, "visible_ratio", 1.0, sqrt(text_length) * MESSAGE_SPEED_MULTIPLIER).from(0.0)
	await tween.finished
	
func stop_textbox():
	pass
