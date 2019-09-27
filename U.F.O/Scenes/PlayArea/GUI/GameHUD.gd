extends VBoxContainer

const PowerMeter = preload("PowerMeter.tscn")

var max_health = 100 setget update_max_health

onready var score_label : Label = $UpperHUD/Score_meter/Score_label

onready var health_bar : TextureProgress = $LowerHUD/HealthMeter/Health_bar
onready var health_icon : TextureRect = $LowerHUD/HealthMeter/Health_icon
onready var health_icon_pos = health_icon.rect_position

onready var tween : Tween = $Tween

func _physics_process(delta):
	health_icon.rect_rotation += delta*100
	if health_bar.value <= 10:
		health_icon.modulate.s = sin(OS.get_ticks_msec())/2+1
	else:
		health_icon.modulate.s = 0
	
	if OS.window_minimized:
		pause()

func display_score(score : int):
	score_label.text = "score: " + str(score)
	score_label.get_parent().rect_size.x = score_label.rect_size.x

func update_max_health(max_health : float):
	health_bar.max_value = max_health

func update_health(health : float):
	tween.interpolate_property(health_bar, "value", health_bar.value, health, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	var shake_tween_start = health_icon.rect_position
	shake_tween_start.x -= 20 + health/5
	health_icon.rect_position = health_icon_pos
	tween.interpolate_property(health_icon, "rect_position", shake_tween_start, health_icon.rect_position, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func update_power_meters(active_powers : Dictionary):
	var meters = $LowerHUD/PowerMeters.get_children()
	for i in active_powers.size():
		var meter : TextureProgress
		if i < meters.size():
			meter = meters[i]
		else:
			meter = PowerMeter.instance()
			$LowerHUD/PowerMeters.add_child(meter)
		
		var power : Area2D = active_powers[active_powers.keys()[i]]
		var wait_time = (power.get_node("Timer") as Timer).wait_time
		var time_left = (power.get_node("Timer") as Timer).time_left
		meter.value = float(time_left) / wait_time
		meter.visible = not time_left <= 0
		meter.get_node("Symbol").texture = power.icon
	
	if meters.size() > active_powers.size():
		for i in range(active_powers.size(), meters.size()):
			$LowerHUD/PowerMeters.remove_child(meters[i])
			meters[i].queue_free()

func _input(event):
	if event.is_action_pressed("pause") and not get_parent().get_parent().game_over:
		pause()

func pause():
	$"../PausePopup".show()
	get_tree().set_pause(true)
