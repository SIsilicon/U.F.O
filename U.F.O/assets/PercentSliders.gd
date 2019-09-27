tool
extends HBoxContainer

var function : FuncRef setget set_function
var aux_variable

export var text = "Percent" setget set_text 
export(float, 0.0, 1.0) var value = 1.0 setget set_value

onready var label = $Label
onready var slider = $HSlider

func _ready():
	set_text(text)
	set_value(value)

func set_function(method):
	function = method

func set_text(string):
	text = string
	if label:
		label.text = text + ":"

func set_value(val):
	value = val
	if slider:
		slider.value = value * 100.0
		_on_HSlider_value_changed(slider.value)

func _on_HSlider_value_changed(value):
	$Percent.text = str(value) + "%"
	if function:
		if aux_variable == null:
			function.call_func(value / 100.0)
		else:
			function.call_func(aux_variable, value / 100.0)