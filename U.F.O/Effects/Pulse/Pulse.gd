extends AnimatedSprite

func _ready():
	play("default")
	
	Global.ufo.push_UFO(global_position, 250)

func _physics_process(delta):
	if self.frame == 31:
		queue_free()
