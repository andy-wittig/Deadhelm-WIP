extends Camera2D

@export var target: CharacterBody2D
@export var noise : FastNoiseLite

const LERP_SPEED := .9
const OFFSET_DAMP := 0.4

var decay := 0.9
var max_offset := Vector2(16, 16)
var max_roll := 0.08
var trauma := 0.0
var noise_y := 0
	
func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	
func shake():
	var amount = trauma
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(0, noise_y)
	var new_offset : Vector2
	new_offset.x = max_offset.x * amount * noise.get_noise_2d(1000, noise_y)
	new_offset.y = max_offset.y * amount * noise.get_noise_2d(2000, noise_y)
	
	position = new_offset
	
func _physics_process(delta):
	if (trauma):
		trauma = max(trauma - decay * delta, 0)
		shake()
	
	if (abs(get_parent().velocity) > Vector2.ZERO):
		position = position.lerp(Vector2(
			clamp(target.velocity.x * OFFSET_DAMP, -32, 32), 
			clamp(target.velocity.y * OFFSET_DAMP, -32, 32)),
			delta * LERP_SPEED)
