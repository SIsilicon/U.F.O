extends Node2D

var progress = 0
var game_over = false
var ufo

export var tutorial_mode = false

func _ready():
	Global.set_background("play")
	set_process(false)
	
	Global.score = 0.0
	Global.ufo = Global.UFO.instance()
	ufo = Global.ufo
	
	$StarLightHandler.start()
	
	add_child_below_node($AsteroidHandler, ufo, true)
	ufo.connect("damage_taken", self, "_on_UFO_damage_taken")
	ufo.connect("killed", self, "_on_UFO_killed")
	ufo.connect("killed", $AsteroidHandler, "_on_UFO_killed")
	ufo.connect("powered_up", $PowerupHandler, "reset_timer_icon")
	
	ufo.global_position = Vector2(Global.window_size.x + 200, ufo.global_position.y)
	
	$Tween.interpolate_property(ufo, "global_position", ufo.global_position, ufo.spawn_point, 3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_callback(self, 3, "start_play")
	$Tween.start()

func _process(delta):
	Global.score += delta * 10
	$GUI/GameHUD.display_score(Global.score)
	$GUI/GameHUD.update_power_meters($PowerupHandler.active_powers)
	
	progress += delta
	
	var extra_speed  = 400 * (1.0 - exp(-progress / 120))
	if not $PowerupHandler.active_powers.empty():
		$AsteroidHandler.speed = 800 + extra_speed
		$AsteroidHandler.focus = 0.2
		$AsteroidHandler.frequency = 2.0
	else:
		$AsteroidHandler.speed = 450 + extra_speed
		$AsteroidHandler.focus = 0.7
		$AsteroidHandler.frequency = 0.6

func start_play():
	if not tutorial_mode:
		$PowerupHandler.reset_timer()
		$PulseHandler.enabled = true
		$AsteroidHandler.start()
		$GUI/GameHUD.show()
		$GUI/GameHUD.update_max_health(ufo.max_health)
		$GUI/GameHUD.update_health(ufo.health_points)
		set_process(true)
	else:
		$GUI/Tutorial.play_area = self
		$GUI/Tutorial.show()
		$GUI/Tutorial.start()

func _on_UFO_damage_taken(HP):
	$GUI/GameHUD.update_health(HP)

func _on_UFO_killed(pos):
	game_over = true
	$PulseHandler.enabled = false;
	$PowerupHandler.stop()
	
	$AsteroidHandler.stop()
	$Tween.interpolate_callback(self, 3, "clear_asteroids")
	
	set_process(false)
	
	var Explosion = preload("res://Effects/Explosion/Explosion.tscn")
	for i in 3:
		var explosion = Explosion.instance()
		explosion.global_position = pos
		add_child(explosion, true)
	
	$Tween.interpolate_callback($GUI/GameHUD, 3, "hide")
	$Tween.interpolate_callback($GUI/GameOverPopup, 3, "show")
	$Tween.interpolate_method(self, "set_music_volume", 0,  Global.get_setting("audio/music_volume"), 3, Tween.TRANS_CUBIC, Tween.EASE_OUT_IN)
	$Tween.start()
	
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
