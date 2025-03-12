extends Control

func _ready():
	for child in $Buttons.get_children():
		child.focus_entered.connect(_focus_switch.bind())
	for child in $Buttons.get_children():
		child.mouse_entered.connect(_focus_switch.bind())

func _on_continue_pressed():
	visible = false
	get_tree().paused = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_help_pressed():
	get_parent().get_node("tutorial").visible = true
	$Buttons/Help.disabled = true

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")
	
	
func _focus_switch():
	$Button_hover.play()
	$Buttons/Help.disabled = false

func _input(event):
	if Input.is_action_just_pressed("Pause"):
		_on_continue_pressed()
