extends "../Powerup.gd"

func _process(delta):
	rotation += delta

func powerup():
	ufo.health_points += ufo.max_health / 3.0
	var particles = $Particles
	remove_child(particles)
	ufo.add_child(particles)
	particles.emitting = true
	$Timer.start()
	yield($Timer, "timeout")
	particles.queue_free()
	queue_free()