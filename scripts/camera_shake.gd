extends Camera2D

@export var noise : FastNoiseLite

const LERP_SPEED := 0.8
const OFFSET_DAMP := 0.5

var decay := 0.9
var max_offset := Vector2(16, 12)
var max_roll := 0.1
var trauma := 0.0
var trauma_power := 3
var noise_y := 0
	
func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(0, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(1000, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(2000, noise_y)
	
func _process(delta):
	if (trauma):
		trauma = max(trauma - decay * delta, 0)
		shake()
	
	offset = offset.lerp(get_parent().velocity * OFFSET_DAMP, delta * LERP_SPEED)


