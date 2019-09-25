extends Node2D

export(float) var min_time = 10
export(float) var max_time = 100

var powerup_spawn_timer = Timer.new()
var active_powers : Dictionary = {}

const Powerups = [preload("res://Powerups/LaserGun/LaserGun.tscn"),
		preload("res://Powerups/ShootingStar/ShootingStar.tscn"),
		preload("res://Powerups/RepairBox/RepairBox.tscn")]

func _ready():
	add_child(powerup_spawn_timer)
	powerup_spawn_timer.one_shot = true
	powerup_spawn_timer.connect("timeout", self, "_on_PowerupTimer_timeout")

func reset_timer_icon(icon):
	reset_timer()

func reset_timer():
	print("reset_timer")
	powerup_spawn_timer.wait_time = rand_range(min_time, max_time)
	powerup_spawn_timer.start()

func stop():
	powerup_spawn_timer.stop()

func _on_PowerupTimer_timeout():
	var powerup = Powerups[floor(rand_range(0, Powerups.size()))].instance()
	powerup.linear_velocity = Vector2(240, 0)
	powerup.position = Vector2(-80, rand_range(0, get_viewport_rect().size.y))
	
	powerup.connect("tree_exited", self, "reset_timer")
	powerup.handler = self
	
	add_child(powerup)
