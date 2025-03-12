extends Node

var home = false
@onready var win_drums = $win_drums
@onready var timer_ring = $timer_ring
func _process(delta):
	if home == true && $home_music.playing == false:
		$home_music.play()
	elif home == false:
		$home_music.stop()

		
func on_button_pressed():
	$button_pressed.play()

