extends AnimatableBody2D

@export var animation_player_optional: AnimationPlayer

var animate := true

func _process(_delta):
	if (not multiplayer.is_server() && animation_player_optional && animate):
		animation_player_optional.stop()
		animation_player_optional.set_active(false)
		animate = false
