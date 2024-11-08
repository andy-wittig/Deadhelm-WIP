extends CanvasLayer

func _ready():
	$LevelLabel.text = GameManager.current_level.replace("_", " ")
