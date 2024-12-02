extends Node2D

@onready var enemy_parent = get_parent()
@onready var progress_bar = $ProgressBar

func _ready():
	progress_bar.max_value = enemy_parent.MAX_HEALTH
	enemy_parent.connect("enemy_was_hurt", start_visible_timer)
	
func _process(_delta):
	progress_bar.value = enemy_parent.enemy_health
	
func start_visible_timer():
	progress_bar.visible = true
	$VisibleTimer.start()

func _on_visible_timer_timeout():
	progress_bar.visible = false
