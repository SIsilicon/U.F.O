extends Area2D

export var tutorial_mode = false
export var immediate_play = false
export var progress_speed = 120
export(float, 0, 1) var zoom_margin = 0.7
export(float, 1, 3) var max_zoom = 2

var progress = 0
var game_over = false
var spawn_zoom = 1.0
var ufo = Global.UFO.instance()

onready var powerupHandler = $PowerupHandler
onready var asteroidHandler = $AsteroidHandler
onready var pulseHandler = $PulseHandler
onready var camera = $Camera2D
onready var gameHUD = $GUI/GameHUD
onready var tutorial = $GUI/Tutorial
onready var tween = $Tween

func _ready():
	Global.set_background("play")
	set_process(false)
	
	Global.score = 0.0
	Global.ufo = ufo
	
	$StarLightHandler.start()
	$Area.position = Global.window_size / 2.0
	$Area.shape.extents = Global.window_size / 2.0 * max_zoom
	
	add_child_below_node(asteroidHandler, ufo, true)
	ufo.connect("damage_taken", self, "_on_UFO_damage_taken")
	ufo.connect("killed", self, "_on_UFO_killed")
	ufo.connect("killed", asteroidHandler, "_on_UFO_killed")
	ufo.connect("powered_up", powerupHandler, "reset_timer_icon")
	
	ufo.global_position = Vector2(Global.window_size.x + 200, ufo.global_position.y)
	
	if immediate_play:
		ufo.global_position = ufo.spawn_point
		start_play()
	else:
		tween.interpolate_property(ufo, "global_position", ufo.global_position, ufo.spawn_point, 3, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_callback(self, 3, "start_play")
		tween.start()

func _process(delta):
	Global.score += delta * 10
	gameHUD.display_score(Global.score)
	gameHUD.update_power_meters(powerupHandler.active_powers)
	
	progress += delta
	asteroidHandler.delta_speed = 1.0 - exp(-progress / progress_speed) + 1.0
	asteroidHandler.delta_frequency = 1.0 - exp(-progress / progress_speed) + 1.0
	
	var zoomVec = (ufo.spawn_point - ufo.global_position).abs() / Global.window_size
	$GUI/Border.modulate.a = lerp($GUI/Border.modulate.a, clamp(max(zoomVec.x, zoomVec.y) / max_zoom + 1.0, 1, 2) - 1.0, 0.15)
	zoomVec = zoomVec / zoom_margin + Vector2(zoom_margin, zoom_margin)
	var zoom = clamp(max(zoomVec.x, zoomVec.y), 1, max_zoom)
	
	camera.zoom = camera.zoom.linear_interpolate(Vector2(zoom, zoom), 0.15)
	asteroidHandler.delta_frequency *= zoom

func transform_by_zoom(vec : Vector2):
	vec.y *= camera.zoom.x
	vec.y -= (camera.zoom.x - 1) * Global.window_size.y * 0.5
	vec.x -= (camera.zoom.x- 1) * Global.window_size.x * 0.5
	return vec

func start_play():
	if not tutorial_mode:
		powerupHandler.reset_timer()
		pulseHandler.enabled = true
		asteroidHandler.start()
		
		gameHUD.show()
		gameHUD.update_max_health(ufo.max_health)
		gameHUD.update_health(ufo.health_points)
		set_process(true)
	else:
		tutorial.play_area = self
		tutorial.show()
		tutorial.start()

func _on_UFO_damage_taken(HP):
	gameHUD.update_health(HP)

func _on_UFO_killed(pos):
	game_over = true
	pulseHandler.enabled = false;
	powerupHandler.stop()
	asteroidHandler.stop()
	tween.interpolate_callback(asteroidHandler, 3, "stop")
	
	set_process(false)
	
	var Explosion = preload("res://Effects/Explosion/Explosion.tscn")
	for i in 3:
		var explosion = Explosion.instance()
		explosion.global_position = pos
		add_child(explosion, true)
	
	tween.interpolate_callback(gameHUD, 3, "hide")
	tween.interpolate_callback($GUI/GameOverPopup, 3, "show")
	tween.interpolate_method(self, "set_music_volume", 0,  Global.get_setting("audio/music_volume"), 3, Tween.TRANS_CUBIC, Tween.EASE_OUT_IN)
	tween.start()
	
	if int(Global.score) > Global.high_score:
		if Global.high_score != 0:
			$GUI/GameOverPopup/Margin/VerticalAlign/HighScore.text = "New High Score!"
		Global.high_score = int(Global.score)
		Global.call_deferred("save_highscore")

func set_music_volume(value : float):
	Global.set_setting("audio/music_volume", value)

func _on_Tutorial_dialog_complete():
	tutorial_mode = false
	start_play()
