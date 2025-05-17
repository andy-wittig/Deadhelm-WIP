extends Camera2D

@export var target: CharacterBody2D
@export var noise : FastNoiseLite

const LERP_SPEED := 8
const SHIFT_SPEED := 0.5
const MOVE_OFFSET_MAX := 32.0

var decay := 0.9
var max_offset := Vector2(16, 16)
var shake_offset : Vector2
var move_offset : Vector2
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
	
	shake_offset = new_offset
	
func _process(delta):
	if (trauma):
		trauma = max(trauma - decay * delta, 0)
		shake()
		
	if (abs(target.velocity) > Vector2.ZERO):
		move_offset = lerp(move_offset, Vector2(MOVE_OFFSET_MAX * sign(target.velocity.x), MOVE_OFFSET_MAX * sign(target.velocity.y)), delta * SHIFT_SPEED)
	else:
		move_offset = lerp(move_offset, Vector2.ZERO, delta * SHIFT_SPEED * 0.8)
	
	global_position = lerp(global_position,
		Vector2(target.global_position.x + shake_offset.x + move_offset.x,
		target.global_position.y - 16 + shake_offset.y + move_offset.y),
		delta * LERP_SPEED)
