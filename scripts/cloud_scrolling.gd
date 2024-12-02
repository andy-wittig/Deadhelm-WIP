extends ParallaxLayer

@export var scroll_speed : float

func _physics_process(delta):
	self.motion_offset.x += scroll_speed * delta
