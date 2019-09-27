extends Light2D

var star_radius
var star_speed = 1000

func _ready():
	star_radius = texture.get_width() / 2 * texture_scale
	$IsVisible.show()

func _process(delta):
	global_position.x += star_speed*delta

func _on_IsVisible_screen_exited():
	queue_free()