extends Node2D

const FALL_VELOCITY := 80

var origin: Vector2
var damage := 20
var stalactite_fall := false
var can_fall := true

@onready var animation_player = $AnimationPlayer
@onready var ray_cast = $RayCast2D
@onready var fall_particles = $FallingParticles
@onready var idle_particles = $IdleParticles

func _ready():
	origin = global_position

func _process(delta):
	if ray_cast.is_colliding():
		var body = ray_cast.get_collider()
		if (body.is_in_group("players") && can_fall):
			start_fall()
			
	if (stalactite_fall):
		if ($FallTimer.get_time_left() == 0):
			fall_particles.emitting = true
			idle_particles.emitting = false
			animation_player.play("fall")
			$FallTimer.start()
		position += Vector2.DOWN * FALL_VELOCITY * delta

func start_fall():
	stalactite_fall = true
	can_fall = false
		
func _on_fall_timer_timeout():
	global_position = origin
	fall_particles.emitting = false
	idle_particles.emitting = true
	animation_player.play("fade_in")
	stalactite_fall = false
	$WaitTimer.start()

func _on_wait_timer_timeout():
	animation_player.play("RESET")
	can_fall = true

func destroy_self():
	queue_free()
