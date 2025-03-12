extends CanvasLayer

func _on_back_to_home_pressed():
	get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")

func _ready():
	$Buttons/back_to_home.grab_focus()
	for child in $Buttons.get_children():
		child.focus_entered.connect(_focus_switch.bind())
	for child in $Buttons.get_children():
		child.mouse_entered.connect(_focus_switch.bind())
	for child in $Slider.get_children():
		child.focus_entered.connect(_focus_switch.bind())
	for child in $Slider.get_children():
		child.mouse_entered.connect(_focus_switch.bind())
	
func _process(delta):
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")

func _focus_switch():
	$Button_hover.play()
