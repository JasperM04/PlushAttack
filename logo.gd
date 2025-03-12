extends Node2D


func _start_animation():
	$Logo_frames.play("default")

func _next_scene():
	get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")
	GlobalSounds.home = true
