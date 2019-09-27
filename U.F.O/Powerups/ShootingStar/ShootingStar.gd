tool
extends "../Powerup.gd"

onready var shield = $Shield

func _process(delta):
	$Head.material.set_shader_param("global_transform", $Head.get_global_transform())

func powerup():
	shield.show()
	shield.get_node("CollisionShape2D").set_deferred("disabled", false)
	
	remove_child(shield)
	ufo.add_child(shield)
	ufo.set_collision_layer_bit(0, false)
	ufo.set_collision_mask_bit(1, false)
	
	$Tween.interpolate_property(shield.get_node("Sprite"), "modulate",
			Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(ufo.get_node("SpriteGlow"), "modulate",
			ufo.default_glow, Color("faff5d"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func powerdown():
	ufo.set_collision_layer_bit(0, true)
	ufo.set_collision_mask_bit(1, true)
	$Tween.interpolate_property(shield.get_node("Sprite"), "modulate",
			Color(1,1,1,0), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(ufo.get_node("SpriteGlow"), "modulate",
			Color("faff5d"), ufo.default_glow, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_callback(shield, 0.5, "queue_free")
	$Tween.interpolate_callback(self, 0.6, "queue_free")
	$Tween.start() 