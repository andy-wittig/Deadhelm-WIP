extends Node2D

func _ready():
	if (!GameManager.game_completed):
		GameManager.save_runtime()
		GameManager.game_completed = true
