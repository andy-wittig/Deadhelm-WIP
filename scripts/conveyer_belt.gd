extends StaticBody2D

@export var direction: int
@export var belt_speed: float = 50

func _ready():
	$ConveyerAnimatedSprite.speed_scale = direction
