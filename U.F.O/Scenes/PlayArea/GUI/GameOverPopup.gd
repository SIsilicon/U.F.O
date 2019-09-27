extends PopupDialog

var quit_sureness = false
var buttons = Dictionary()

func _ready():
	for i in $Margin/VerticalAlign.get_children():
		buttons[i.get_name()] = i

func _process(delta):
	$Margin/VerticalAlign/VSplit/DisplayScore.text = str(int(Global.score))

func _on_Restart_pressed():
	buttons["Quit"].text = "Quit"
	buttons["Useless"].text = "Useless Button"
	quit_sureness = false
	Global.goto_scene(Global.PLAY)

func _on_Quit_pressed():
	if !quit_sureness:
		buttons["Quit"].text = "Are you sure?"
		quit_sureness = true
	else:
		buttons["Quit"].text = "Quit"
		buttons["Useless"].text = "Useless Button"
		quit_sureness = false
		Global.goto_scene(Global.MENU)

func _on_Useless_pressed():
	buttons["Useless"].text = "told you :P"
