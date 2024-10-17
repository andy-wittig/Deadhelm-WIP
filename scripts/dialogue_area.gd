extends Area2D

@export var message : String
@export var message_wait := 4

var started_message := false
const MESSAGE_SPEED_MULTIPLIER := 0.8

func _ready():
	$Control/MessageLabel.visible = false
	$Control/MessageLabel.text = message

func start_message():
	$AnimationPlayer.play("RESET")
	$Control/MessageLabel.visible = true
	
	print ($Control/MessageLabel.visible)
	var tween: Tween = create_tween()
	var text_length = $Control/MessageLabel.get_total_character_count()
	tween.tween_property($Control/MessageLabel, "visible_ratio", 1.0, sqrt(text_length) * MESSAGE_SPEED_MULTIPLIER).from(0.0)
	await tween.finished
	
	$Timer.start(message_wait)
	await $Timer.timeout
	$AnimationPlayer.play("fade_out")
	started_message = false

func _on_body_entered(body):
	if (body.is_in_group("players")):
		if (!started_message):
			start_message()
			started_message = true
