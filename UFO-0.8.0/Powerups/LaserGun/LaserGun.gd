extends "../Powerup.gd"

onready var background = $BackgroundSprite
onready var gun = $Guns
onready var remote_trans = $RemoteTransform2D

func _physics_process(delta):
	rotation += delta

func powerup():
	background.show()
	gun.show()
	remove_child(background)
	remove_child(gun)
	remove_child(remote_trans)
	handler.add_child(background)
	handler.add_child(gun)
	ufo.add_child(remote_trans)
	gun.get_node("Timer").start()
	
	$Tween.interpolate_property(background, "modulate",
			Color.black, Color.white, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(ufo.get_node("SpriteGlow"), "modulate",
			ufo.default_glow, Color("74ff58"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func powerdown():
	gun.jetison()
	remote_trans.queue_free()
	$Tween.interpolate_property(ufo.get_node("SpriteGlow"), "modulate",
			Color("74ff58"), ufo.default_glow, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(background, "modulate",
			Color.white, Color.black, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_callback(background, 0.5, "queue_free")
	$Tween.interpolate_callback(self, 0.6, "queue_free")
	$Tween.start()

func _on_UFO_killed(pos):
	._on_UFO_killed(pos)
	gun.queue_free()
	background.queue_free()