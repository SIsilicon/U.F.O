extends Node2D

var Star = preload("res://Effects/StarLight/starLight.tscn")

var window_size
var star_timer = Timer.new()

func _ready():
	window_size = Global.window_size
	add_child(star_timer)
	star_timer.wait_time = 0.1
	star_timer.connect("timeout", self, "_on_StarTimer_timeout")

func _on_StarTimer_timeout():
	var star = Star.instance()
	add_child(star)
	
	star.position = Vector2(-star.star_radius, rand_range(0, window_size.y))
	star.position = get_parent().transform_by_zoom(star.position)

func stop():
	star_timer.stop()
	get_tree().call_group("StarLights", "queue_free")

func start():
	for i in range(20):
		var star = Star.instance()
		star.global_position = Vector2(rand_range(0, window_size.x), rand_range(0, window_size.y))
		add_child(star)
	star_timer.start()
