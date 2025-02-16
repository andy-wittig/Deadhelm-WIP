extends RigidBody2D

@onready var left_cast = $LeftCast
@onready var right_cast = $RightCast

const PUSH_FORCE := 2

func _process(_delta):
	if (right_cast.is_colliding()):
		if (right_cast.get_collider().is_in_group("pushable")):
			self.add_constant_central_force(Vector2.LEFT * PUSH_FORCE)
			
	if (left_cast.is_colliding()):
		if (left_cast.get_collider().is_in_group("pushable")):
			self.add_constant_central_force(Vector2.RIGHT * PUSH_FORCE)
