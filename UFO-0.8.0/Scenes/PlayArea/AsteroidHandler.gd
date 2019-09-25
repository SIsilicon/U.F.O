extends Node2D

var Asteroid = preload("res://Asteroids/Asteroid.tscn")

export (float) var speed
export (float, 0, 1) var focus # The larger this variable is, the more asteroids that go towards the UFO.
export (float) var frequency

var asteroid_types : Array = []

var asteroid_timer = Timer.new()

func _ready():
	add_child(asteroid_timer)
	asteroid_timer.connect("timeout", self, "_on_AsteroidTimer_timeout")

func _on_AsteroidTimer_timeout() -> void:
#	asteroid.type = pick_asteroid()
	var radius = rand_range(0.2, 0.8)
	var position = Vector2(-radius*512, rand_range(0, get_viewport_rect().size.y))
	
	var spawn_focus = Global.ufo.global_position
	var base_velocity = (spawn_focus - position).normalized()
	
	base_velocity *= rand_range(speed / 2, speed)
	var velocity = base_velocity.linear_interpolate(Vector2(base_velocity.length(), 0), 1 - focus)
	
	spawn_asteroid(position, velocity, radius)
	
	var time = 1.0 / frequency
	asteroid_timer.wait_time = rand_range(time / 2, time)

func pick_asteroid() -> int:
	if asteroid_types.empty():
		for i in 28:
			asteroid_types.append(ceil(float(i) / 4))
		asteroid_types.shuffle()
	
	return int(asteroid_types.pop_back())

func spawn_asteroid(pos, vel, radius):
	var asteroid = Asteroid.instance()
	asteroid.position = pos
	asteroid.linear_velocity = vel
	asteroid.radius = radius
	add_child(asteroid)

func start():
	asteroid_timer.start()

func stop() -> void:
	asteroid_timer.stop()
	clear_asteroids()

func clear_asteroids() -> void:
	get_tree().call_group("asteroids", "queue_free")
