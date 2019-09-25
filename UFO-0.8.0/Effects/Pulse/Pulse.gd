extends AnimatedSprite

func _ready():
	play("default")

func _physics_process(delta):
	if self.frame == 31:
		queue_free()
