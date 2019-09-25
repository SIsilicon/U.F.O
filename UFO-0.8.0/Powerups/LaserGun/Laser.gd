extends StaticBody2D

export(float) var speed = 100;

func _physics_process(delta):
	position.x -= speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


