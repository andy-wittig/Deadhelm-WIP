extends CanvasLayer

func _ready():
	$LevelLabel.text = GameManager.current_level.replace("_", " ")
	
func player_death():
	$LevelLabel.text = "another chance..."
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("fade_in")
