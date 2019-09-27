extends Panel

signal dialog_complete
signal dialog_progressed(i)

const dialog = [
	"Hello, and thank you for purchasing our latest Ultrasound Based Floating Object.",
	"Or \"UFO\" for short. ;)",
	"Anyway, your UFO is now subjected to the dangers of space. So you'll have to make sure to keep it safe.",
	"As the name implies, you move the ufo with pulses.",
	"You make a pulse by tapping/clicking on the screen.",
	"The pulses will push the UFO away from them.",
	"Why don't you try that now?",
	"Make a pulse to dodge this asteroid.",
	"Let's try this again.",
	"{goto} 7",
	"Good job! you've dodged the asteroid.",
	"You'll have to do that when travelling in these parts.",
	"{gotoif} oob1 16",
	"And another thing. If your UFO is out of sight, it will be teleported back in view.",
	"This however damages your UFO so be careful with that.",
	"{gotoif} oob2 8",
	"Also, help will come along now and then as powerups.",
	"Be sure to collect them. They can prove to be very useful.",
	"Well, that should be all for now.",
	"We hope you enjoy playing with your brand new UFO! :)",
	"{func} hide"
]
var index = 0 setget set_index;
var characters = 0;

var oob1 = false
var oob2 = false

var play_area;
var ufo;

export(float) var speed = 10

onready var label = $Label

func _ready():
	set_process(false)
	label.text = dialog[index]

func _process(delta):
	label.visible_characters = characters
	characters += delta * speed
	if label.visible_characters >= label.text.length():
		set_process(false)

func start():
	set_index(0)

func set_index(ind):
	characters = 0
	
	if ind != index:
		emit_signal("dialog_progressed", min(ind, dialog.size() - 1))
	index = min(ind, dialog.size() - 1)
	
	var string : String = dialog[index]
	if string.begins_with("{func}"):
		call(string.rsplit(" ", true, 1)[1])
	elif string.begins_with("{goto}"):
		set_index(int(string.rsplit(" ", true, 1)[1]))
	elif string.begins_with("{gotoif}"):
		var vari = string.rsplit(" ", true, 2)[1]
		if get(vari):
			set_index(int(string.rsplit(" ", true, 2)[2]))
		else:
			set_index(index + 1)
	else:
		set_process(true)
		if label:
			label.text = string
	
	if index == dialog.size() - 1:
		emit_signal("dialog_complete")

func _on_Tutorial_dialog_progressed(i):
	var end = dialog.size() - 1
	match i:
		3: $TextureRect.show()
		6:
			$TextureRect.hide()
		7:
			$Button.hide()
			if play_area:
				ufo = Global.ufo
				play_area.get_node("PulseHandler").enabled = true
				play_area.get_node("AsteroidHandler").spawn_asteroid( \
				Vector2(-50, Global.window_size.y / 2), Vector2(200, 0), 0.5)
				
				var asteroid = play_area.get_node("AsteroidHandler").get_children()[1]
				asteroid.connect("screen_exited", self, "_on_Asteroid_screen_exited")
				
				if not ufo.is_connected("damage_taken", self, "on_UFO_damage_taken"):
					ufo.connect("damage_taken", self, "_on_UFO_damage_taken")

func _on_Tutorial_dialog_complete():
	ufo.disconnect("damage_taken", self, "_on_UFO_damage_taken")

func _on_UFO_damage_taken(hp):
	ufo.linear_velocity *= 0
	ufo.health_points = ufo.max_health
	ufo.call_deferred("set_position", play_area.ufo.spawn_point)
	play_area.get_node("AsteroidHandler").clear_asteroids()
	play_area.get_node("PulseHandler").enabled = false
	
	$Button.show()
	$AnimationPlayer.play("Transition")
	if ufo.OutOfBounds:
		oob1 = true
		oob2 = true
		set_index(13)
	else:
		set_index(8)

func _on_Asteroid_screen_exited():
	ufo.linear_velocity *= 0
	play_area.get_node("PulseHandler").enabled = false
	
	$Button.show()
	oob2 = false
	set_index(10)

func _on_Button_pressed():
	set_index(index + 1)

