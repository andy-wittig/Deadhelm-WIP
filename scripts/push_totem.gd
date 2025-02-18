extends RigidBody2D

@onready var left_cast = $LeftCast
@onready var right_cast = $RightCast
@onready var push_particle = $PushParticle
@onready var totem_sprite = $TotemSprite
@onready var totem_activated_sprite = $TotemActivatedSprite

const PUSH_FORCE := 600

func _physics_process(delta):
	push_particle.emitting = false
	totem_sprite.visible = true
	totem_activated_sprite.visible = false
	
	if (right_cast.is_colliding()):
		if (right_cast.get_collider() != null):
			if (right_cast.get_collider().is_in_group("pushable")):
				push_particle.emitting = true
				totem_sprite.visible = false
				totem_activated_sprite.visible = true
				apply_central_force(Vector2(-1, 0) * PUSH_FORCE)
			
	if (left_cast.is_colliding()):
		if (left_cast.get_collider() != null):
			if (left_cast.get_collider().is_in_group("pushable")):
				push_particle.emitting = true
				totem_sprite.visible = false
				totem_activated_sprite.visible = true
				apply_central_force(Vector2(1, 0) * PUSH_FORCE)
