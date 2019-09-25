extends MarginContainer

var quit_confirmed = false
onready var quit_button = $VBox/Buttons/Panel/VBox/Quit

func _ready():
	$VBox/HighScore.text = "High Score: " + str(Global.high_score)

func reset_quit_button():
	quit_confirmed = false
	quit_button.text = "Quit"

func _on_Play_pressed():
	reset_quit_button()
	Global.goto_scene(Global.PLAY)

func _on_Tutorial_pressed():
	reset_quit_button()
	Global.goto_scene(Global.TUTORIAL)

func _on_Quit_pressed():
	if !quit_confirmed:
		quit_button.text = "Are you sure?"
		quit_confirmed = true
	else:
		get_tree().quit()

# easter egg :3
var count = 0
func _on_Creator_pressed():
	count += 1
	if count >= 3:
		Global.easter_egg = true
