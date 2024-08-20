extends Area2D

@onready var enemy_parent = get_parent()
@onready var progress_bar = $ProgressBar

func _ready():
	progress_bar.max_value = enemy_parent.MAX_HEALTH
	
func _process(_delta):
	progress_bar.value = enemy_parent.enemy_health

func _on_mouse_entered():
	progress_bar.visible = true

func _on_mouse_exited():
	progress_bar.visible = false
