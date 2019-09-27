extends RigidBody2D

signal screen_exited

var radius : float
var type : int

var asteroid_modulate = Color(0.5, 0.5, 0.5) setget set_asteroid_modulate

var collision_shape

onready var label = $Label

func _ready():
	
	radius = radius if radius else rand_range(0.2, 0.8)
	type = type if type else randi()%7 + 1
	
	radius *= 0.4;
	
	for i in get_children():
		if i is CollisionPolygon2D:
			i.hide()
	
	var color_mod : Color = Color.white
	color_mod.v -= rand_range(0, 0.4)
	
	var asteroid = get_node("Asteroid_"+str(type))
	asteroid.show()
	asteroid.modulate = color_mod
	collision_shape = asteroid
	
	for i in get_children():
		if i.name.find("Asteroid_") != -1:
			i.scale *= radius
		
		if i is CPUParticles2D:
			i.scale *= radius
			i.scale_amount *= radius
		
		if i.name.find("Asteroid_") != -1 and not i.visible:
			i.queue_free()
	
	mass *= radius * radius

func _physics_process(delta):
	if label.visible:
		label.rect_position.y -= delta * 150

func set_asteroid_modulate(colour):
	for i in get_children():
		if i.name.find("Asteroid_") != -1:
			i.modulate = colour

func _on_IsVisible_screen_exited():
	if not is_queued_for_deletion():
		emit_signal("screen_exited")
	queue_free()

func _on_body_collision(body):
	
	# 4 and 3 are collision layers Protection and Laser respectively
	if not $AnimationPlayer.current_animation == "Explode" && \
			(body.get_collision_layer_bit(3) || body.get_collision_layer_bit(4)):
		$AnimationPlayer.play("Explode")
		
		var score = floor(mass * 50)
		
		remove_child(label)
		get_parent().get_parent().add_child(label)
		
		collision_shape.set_deferred("disabled", true)
		$AudioStreamPlayer2D.play()
		set_deferred("linear_velocity", Vector2())
		
		label.show()
		label.text = "+" + str(score)
		label.rect_position = position
		label.rect_position -= label.rect_size / 2
		label.rect_position.x = max(label.rect_position.x, 0.0)
		label.rect_position.y = max(label.rect_position.y, 0.0)
		
		Global.score += score
		
		# It's a laser
		if body.get_collision_layer_bit(3):
			body.queue_free()

func _on_tree_exiting():
	label.queue_free()

func is_asteroid():
	pass

