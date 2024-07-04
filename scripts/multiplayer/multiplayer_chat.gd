extends Control

@onready var message_edit = $VBoxContainer/MessageEdit
@onready var chat_label = $VBoxContainer/ChatPanel/ChatScrollContainer/ChatLabel

@rpc("any_peer", "call_local")
func send_chat(username, message):
	chat_label.text += str(username, ": ", message, "\n")
	
func _ready():
	visible = false
	
func _input(event):
	if (event.is_action_pressed("show_chat") 
	&& GameManager.multiplayer_mode_enabled):
		visible = not visible
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("send_chat"):
		get_viewport().set_input_as_handled()
		var text_to_send = message_edit.get_text()
		rpc("send_chat", GameManager.username, text_to_send)
		message_edit.clear()

func _on_message_edit_focus_entered():
	var player_client = get_tree().get_current_scene().get_node("Level/level_1/players/" + str(multiplayer.get_unique_id()))
	player_client.is_in_chat = true

func _on_message_edit_focus_exited():
	var player_client = get_tree().get_current_scene().get_node("Level/level_1/players/" + str(multiplayer.get_unique_id()))
	player_client.is_in_chat = false
