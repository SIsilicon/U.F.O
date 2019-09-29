extends Node

const VERSION : String = "0.8.0"

const main_menu : PackedScene = preload("res://Scenes/Menu/Menu.tscn")
const play_area : PackedScene = preload("res://Scenes/PlayArea/PlayArea.tscn")
const UFO = preload("res://UFO/UFO.tscn")

enum {MENU, PLAY}

onready var current_scene : Node = get_tree().get_root().get_node("Menu")

var ufo
var score := 0.0
var high_score := 0
var play_count := 0

var settings = {} setget set_settings

var window_size 

var easter_egg = false

func _enter_tree():
	window_size = get_viewport().size
	load_playcount()
	load_highscore()
	load_settings()
	
	randomize()

func _input(event):
	if Input.is_action_just_pressed("screenshot"):
		var screen = get_viewport().get_texture().get_data()
		screen.flip_y()
		var t = OS.get_datetime()
		screen.save_png("user://screenshot"+ str(t["second"]) + \
				str(t["minute"]) + str(t["hour"]) + str(t["day"]) + \
				str(t["month"]) + str(t["year"]) +".png")

func set_background(background : String):
	$Background/Background1.visible = false
	$Background/Background2.visible = false
	
	if background == "menu":
		$Background/Background1.visible = true
	elif background == "play":
		$Background/Background2.visible = true

func get_setting(name : String):
	return settings[name]

func set_setting(name : String, value):
	match name:
		"audio/music_volume":
			AudioServer.set_bus_volume_db(1, linear2db(value))
		"audio/sfx_volume":
			AudioServer.set_bus_volume_db(2, linear2db(value))
		_:
			printerr("invalid setting", name)
			print_stack()
			return
	
	settings[name] = value

func set_settings(dict):
	settings = dict.duplicate()
	for setting in settings.keys():
		set_setting(setting, settings[setting])

func goto_scene(scene : int):
	call_deferred("_deferred_goto_scene", scene)

func _deferred_goto_scene(scene : int):
	var current_scene = get_tree().get_current_scene()
	if current_scene:
		current_scene.free()
	
	match scene:
		MENU:
			current_scene = main_menu.instance()
		PLAY:
			play_count += 1
			save_playcount()
			current_scene = play_area.instance()
			current_scene.tutorial_mode = play_count <= 1
	
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func save_playcount():
	var file = File.new()
	file.open_encrypted_with_pass("user://playcount.dat", File.WRITE, OS.get_unique_id() + "fwe4t90784064896n7340")
	file.store_pascal_string(VERSION)
	file.store_32(play_count)

func load_playcount():
	var file = File.new()
	if file.file_exists("user://playcount.dat"):
		file.open_encrypted_with_pass("user://playcount.dat", File.READ, OS.get_unique_id() + "fwe4t90784064896n7340")
		var version : String = file.get_pascal_string()
		if version != VERSION:
			print("version is different.")
		play_count = file.get_32()


func save_highscore():
	var file = File.new()
	file.open_encrypted_with_pass("user://high_score.dat", File.WRITE, OS.get_unique_id() + "fwe4t90784064896n7340")
	file.store_pascal_string(VERSION)
	file.store_32(high_score)

func load_highscore():
	var file = File.new()
	if file.file_exists("user://high_score.dat"):
		file.open_encrypted_with_pass("user://high_score.dat", File.READ, OS.get_unique_id() + "fwe4t90784064896n7340")
		var version : String = file.get_pascal_string()
		if version != VERSION:
			print("version is different.")
		high_score = file.get_32()

func save_settings():
	var file = File.new()
	file.open("user://settings.json", File.WRITE)
	file.store_pascal_string(VERSION)
	file.store_line(to_json(settings))

func load_settings():
	var file = File.new()
	if file.file_exists("user://settings.json"):
		file.open("user://settings.json", File.READ)
		var version : String = file.get_pascal_string()
		if version != VERSION:
			print("version is different.")
		set_settings(parse_json(file.get_line()))
	else:
		settings["audio/music_volume"] = 1.0
		settings["audio/sfx_volume"] = 1.0