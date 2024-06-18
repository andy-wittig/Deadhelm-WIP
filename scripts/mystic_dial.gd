extends Node2D

const DIAL_RADIUS = 22
var player = null
var mouse_dir : Vector2

@onready var animation_player = $AnimationPlayer
@onready var meteor_sprite = $MeteorSprite

func destroy():
	meteor_sprite.visible = not meteor_sprite.visible
	animation_player.play("fade_out")
	$DestroyTimer.start()
	
func _on_destroy_timer_timeout():
	queue_free()
	
func _process(delta):
	#update dials position
	global_position.x = player.global_position.x
	global_position.y = player.global_position.y - 16
	
	#update spells position
	var mouse_pos = get_global_mouse_position()
	mouse_dir = (mouse_pos - global_position).normalized()
	meteor_sprite.position = mouse_dir * DIAL_RADIUS
	meteor_sprite.rotation = mouse_dir.angle()

