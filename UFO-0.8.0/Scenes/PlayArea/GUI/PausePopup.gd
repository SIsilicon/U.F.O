extends PopupDialog

var quit_confirmed = false
var buttons = Dictionary()

func _ready():
	for i in $Margin/VerticalAlign.get_children():
		buttons[i.get_name()] = i

func _on_Resume_pressed():
	quit_confirmed = false
	buttons["Quit"].text = "quit"
	buttons["Useless"].text = "useless button"
	hide()
	
	Engine.set_time_scale(0.08)
	$"../../Tween".interpolate_method( Engine, "set_time_scale", 0.08, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$"../../Tween".start()
	get_tree().set_pause(false)

func _on_Quit_pressed():
	if !quit_confirmed:
		buttons["Quit"].text = "Are you sure?"
		quit_confirmed = true
	else:
		buttons["Quit"].text = "quit"
		buttons["Useless"].text = "useless button"
		get_tree().set_pause(false)
		Global.goto_scene(Global.MENU)

func _on_Useless_pressed():
	buttons["Useless"].text = "told you :P"
