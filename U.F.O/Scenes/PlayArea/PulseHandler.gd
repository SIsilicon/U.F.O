extends Node2D

var Pulse = preload("res://Effects/Pulse/Pulse.tscn")

var enabled = false

var easter_egg = [
	0.679225077, 0.679225077,
	1.358448998, 1.017686936,
	0.943874565, 0.890898178,
	0.793700980, 0.667419909,
	0.793700980, 0.890898178,
	
	0.594603252, 0.594603252,
	1.358448998, 1.017686936,
	0.943874565, 0.890898178,
	0.793700980, 0.667419909,
	0.793700980, 0.890898178,
	
	0.571157133, 0.571157133,
	1.358448998, 1.017686936,
	0.943874565, 0.890898178,
	0.793700980, 0.667419909,
	0.793700980, 0.890898178,
	
	0.529731492, 0.529731492,
	1.358448998, 1.017686936,
	0.943874565, 0.890898178,
	0.793700980, 0.667419909,
	0.793700980, 0.890898178]
var i = 0

func _input(event : InputEvent):
	if event is InputEventScreenTouch and event.pressed and enabled:
		Global.ufo.push_UFO(event.get_position(), 250)
		var pulse = Pulse.instance()
		pulse.add_to_group("pulses")
		pulse.global_position = get_global_mouse_position()
		
		if Global.easter_egg:
			pulse.get_node("AudioStreamPlayer2D").pitch_scale = easter_egg[i];
			i = wrapi(i + 1, 0, easter_egg.size())
		
		add_child(pulse)

func clear_pulses():
	get_tree().call_group("pulses", "queue_free")
	i = 0

