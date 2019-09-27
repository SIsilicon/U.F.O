extends Area2D

# Every node that uses this class, or an inherited class,
# will need a VisibilityNotifier2D and a Timer node
# as direct children.

export(Texture) var icon

var linear_velocity = Vector2()
var active = false
var handler : Node2D
var ufo : RigidBody2D

func _ready():
	connect("body_entered", self, "_on_body_entered")
	$Timer.connect("timeout", self, "powerdown")
	
	var notifier = $VisibilityNotifier2D as VisibilityNotifier2D
	if not notifier.is_connected("screen_exited", self, "_on_screen_exited"):
		notifier.connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta):
	position += linear_velocity * delta * float(not active)

func _get_configuration_warning():
	if not has_node("Timer"):
		return "Must have a timer node with the specified duration of this powerup"
	elif not has_node("VisibilityNotifier2D"):
		return "Must have a visibility notifier"
	return ""

func _on_screen_exited():
	queue_free()

func _exit_tree():
	if active:
		(handler.active_powers as Dictionary).erase(icon)

func _on_body_entered(body : PhysicsBody2D):
	ufo = body
	ufo.emit_signal("powered_up", icon)
	hide()
	
	if icon:
		var powers : Dictionary = handler.active_powers
		if not powers.has(icon):
			ufo.connect("killed", self, "_on_UFO_killed")
			$CollisionShape2D.set_deferred("disabled", true)
			active = true
			
			var notifier = $VisibilityNotifier2D as VisibilityNotifier2D
			notifier.disconnect("screen_exited", self, "_on_screen_exited")
			
			$Timer.start()
			call_deferred("powerup")
			powers[icon] = self
		else:
			queue_free()
			(powers.get(icon).get_node("Timer") as Timer).start()
	else:
		call_deferred("powerup")

func powerup():
	pass

func powerdown():
	pass

func _on_UFO_killed(pos):
	$Timer.paused = true
	queue_free()