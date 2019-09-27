extends Node2D

const Laser = preload("Laser.tscn")

var fired_top_laser = false

func _on_Timer_timeout():
	var laser = Laser.instance()
	laser.position = ($TopGun if fired_top_laser else $BottomGun) \
	.get_node("Position2D").global_position
	get_parent().add_child(laser)
	
	fired_top_laser = not fired_top_laser

func jetison():
	$AnimationPlayer.play("Jetison")