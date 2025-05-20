extends Control

var menu_started := false
var show_message := false
var text_array : Array[String]
var text_page := 0

const MESSAGE_SPEED_MULTIPLIER := 0.6

@onready var text_label = $TextLabel
@onready var exit_button = $ExitButton
@onready var next_button = $NextButton
@onready var menu_layer = $"../.."

func _process(_delta):
	print (text_page)
	if (text_page >= text_array.size() - 2):
		exit_button.visible = true
		next_button.visible = false
	else:
		exit_button.visible = false
		next_button.visible = true

func menu_opened():
	if (!menu_started):
		menu_started = true
		
func read_textline(page : int):
	text_label.text = text_array[page]
	
	var tween: Tween = create_tween()
	var text_length = text_label.get_total_character_count()
	tween.tween_property(text_label, "visible_ratio", 1.0, sqrt(text_length) * MESSAGE_SPEED_MULTIPLIER).from(0.0)
	await tween.finished
		
func start_textbox(npc_text_path : String):
	var text_file = FileAccess.open(npc_text_path, FileAccess.READ)
	
	if (text_file != null):
		while (!text_file.eof_reached()):
			text_array.push_back(text_file.get_line())
			
		read_textline(text_page)
	
func stop_textbox():
	text_page = 0
	text_array.clear()

func _on_next_button_pressed():
	if (text_array.size() > 0 && text_page + 1 < text_array.size() && text_array[text_page + 1] != ""):
		text_page += 1
		read_textline(text_page)

func _on_exit_button_pressed():
	stop_textbox()
	menu_layer.return_to_prev_menu()
