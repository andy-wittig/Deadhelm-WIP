extends Control

@onready var message_edit = $VBoxContainer/MessageEdit
@onready var chat_label = $VBoxContainer/ChatPanel/ChatScrollContainer/ChatLabel

@rpc("any_peer", "call_local")
func send_chat(username, message):
	chat_label.text += "\n%s: %s" % [username, message]
	
func _process(_delta):
	if Input.is_action_just_pressed("send_chat"):
		rpc("send_chat", MultiplayerManager.username, message_edit.get_text())
		message_edit.clear()
		
