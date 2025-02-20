extends BaseEnemy

@onready var hurt_player_area = $HurtPlayerArea
@onready var animated_fester_sprite = $AnimatedFesterSprite

func _ready():
	super()
	hurt_player_area.active = false
	hurt_player_area.attack_wait = attack_timer_wait

func _physics_process(delta):
	super(delta)
	
	if (direction > 0):
		hurt_player_area.position = Vector2(10, -8)
	elif (direction < 0):
		hurt_player_area.position = Vector2(-10, -8)
		
func start_enemy_attack():
	if (!attack_started):
		animated_fester_sprite.play("attack")
		if (animated_fester_sprite.frame == 3 && player != null):
			attack_started = true
			hurt_player_area.active = true
			attack_timer.start(attack_timer_wait)
		
	velocity.x = 0
	
func attack_finished():
	if (attack_started):
		enemy_sprite.play("idle")
		hurt_player_area.active = false
	
