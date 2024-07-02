extends CanvasLayer

@onready var message_edit = $VBoxContainer/MessageEdit
@onready var chat_label = $VBoxContainer/ChatPanel/ChatScrollContainer/ChatLabel

@rpc("any_peer", "call_local")
func send_chat(username, message):
	chat_label.text += str(username, ": ", message, "\n")
	
func _ready():
	visible = false
	
func _process(_delta):
	if Input.is_action_just_pressed("show_chat"):
		visible = not visible

	if Input.is_action_just_pressed("send_chat"):
		var text_to_send = message_edit.get_text()
		rpc("send_chat", MultiplayerManager.username, text_to_send)
		message_edit.clear()
