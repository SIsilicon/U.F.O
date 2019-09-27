extends AnimatedSprite

func _ready():
	$AnimationPlayer.play("explode")
	play()

func _physics_process(delta):
	modulate.a *= 3

