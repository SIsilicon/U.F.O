extends Node2D

var Asteroid = preload("res://Asteroids/Asteroid.tscn")

export (float) var speed
export (float, 0, 1) var focus # The larger this variable is, the more asteroids that go towards the UFO.
export (float) var frequency

var delta_speed = 1.0
var delta_frequency = 1.0

var asteroid_types : Array = []
var asteroid_timer = Timer.new()

func _ready():
	add_child(asteroid_timer)
	asteroid_timer.connect("timeout", self, "_on_AsteroidTimer_timeout")

func _on_AsteroidTimer_timeout() -> void:
#	asteroid.type = pick_asteroid()
	var radius = rand_range(0.2, 0.8)
	
	var pos = Vector2(0, rand_range(0, Global.window_size.y))
	pos = get_parent().transform_by_zoom(pos)
	pos.x -= radius*512
	
	var spawn_focus = Global.ufo.global_position
	var base_velocity = (spawn_focus - get_global_transform() * pos).normalized()
	
	base_velocity *= rand_range(speed / 2, speed) * delta_speed
	var velocity = base_velocity.linear_interpolate(Vector2(base_velocity.length(), 0), 1 - focus)
	
	spawn_asteroid(pos, velocity, radius)
	
	var time = 1.0 / (frequency * delta_frequency)
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

func clear_asteroids() -> void:
	get_tree().call_group("asteroids", "queue_free")
