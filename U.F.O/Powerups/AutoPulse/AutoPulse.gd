tool
extends "../Powerup.gd"

const Pulse = preload("res://Effects/Pulse/Pulse.tscn")

export(float, 0, 1) var margin = 0.3

onready var tween = $Tween

func powerup():
	show()
	$AnimatedSprite.hide()
	$CanvasLayer/ColorRect.show()
	tween.interpolate_property($CanvasLayer/ColorRect, "modulate", \
			Color(1,1,1,0), Color(1,1,1), 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	var ufo = Global.ufo
	if ufo and not Rect2(Vector2(), Global.window_size). \
			encloses(ufo.get_node("IsVisible").rect):
		ufo.take_damage(-ufo.max_health / 10 * ufo.defense)
		ufo._on_IsVisible_screen_exited()
		tween.interpolate_property(self, "active", false, true, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	
	tween.start()

func powerdown():
	set_process(false)
	tween.interpolate_property($CanvasLayer/ColorRect, "modulate", \
			Color(1,1,1), Color(1,1,1,0), 1.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_callback(self, 1.0, "queue_free")
	tween.start()

func _process(delta):
	var ufo = Global.ufo
	
	if ufo and active:
		handler.get_node("../Camera2D").zoom = Vector2(1,1)
		
		position = Vector2()
		rotation = 0
		
		var position = ufo.position
		var velocity = ufo.linear_velocity
		var window = Global.window_size
		var radius = ufo.radius
		
		var pulse
		if position.y - radius < -velocity.y * margin:
			pulse = Pulse.instance()
			pulse.position = Vector2(ufo.position.x, 0)
		if position.x - radius < -velocity.x * margin:
			pulse = Pulse.instance()
			pulse.position = Vector2(0, ufo.position.y)
		if 720 - (position.y + radius) < velocity.y * margin:
			pulse = Pulse.instance()
			pulse.position = Vector2(ufo.position.x, 720)
		if 1280 - (position.x + radius) < velocity.x * margin:
			pulse = Pulse.instance()
			pulse.position = Vector2(1280, ufo.position.y)
		
		if pulse:
			pulse.modulate = Color("80fff2")
			add_child(pulse)
	else:
		rotation += delta * 0.25