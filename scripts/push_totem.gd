extends RigidBody2D

@onready var left_cast = $LeftCast
@onready var right_cast = $RightCast
@onready var push_particle = $PushParticle

const PUSH_FORCE := 600

func _physics_process(delta):
	push_particle.emitting = false
	
	if (right_cast.is_colliding()):
		if (right_cast.get_collider() != null):
			if (right_cast.get_collider().is_in_group("pushable")):
				push_particle.emitting = true
				apply_central_force(Vector2(-1, 0) * PUSH_FORCE)
			
	if (left_cast.is_colliding()):
		if (left_cast.get_collider() != null):
			if (left_cast.get_collider().is_in_group("pushable")):
				push_particle.emitting = true
				apply_central_force(Vector2(1, 0) * PUSH_FORCE)
