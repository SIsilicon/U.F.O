extends MarginContainer

var old_settings

func _ready():
	$Panel/VBox/Audio/MusicVol.function = funcref(Global, "set_setting")
	$Panel/VBox/Audio/MusicVol.aux_variable = "audio/music_volume"
	$Panel/VBox/Audio/SFXVol.function = funcref(Global, "set_setting")
	$Panel/VBox/Audio/SFXVol.aux_variable = "audio/sfx_volume"

func load_settings():
	old_settings = Global.settings.duplicate();
#	breakpoint
	$Panel/VBox/Audio/MusicVol.value = Global.get_setting("audio/music_volume") 
	$Panel/VBox/Audio/SFXVol.value = Global.get_setting("audio/sfx_volume")

func _on_Back_pressed():
	get_parent().to_section(Vector2())
	Global.settings = old_settings

func _on_Save_pressed():
	get_parent().to_section(Vector2())
	Global.save_settings()
