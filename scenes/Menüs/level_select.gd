extends CanvasLayer

func _ready():
	for child in $Buttons.get_children():
		child.pressed.connect(_level_select.bind(child.name))
	for child in $Buttons.get_children():
		child.focus_entered.connect(_focus_switch.bind())
	for child in $Buttons.get_children():
		child.mouse_entered.connect(_focus_switch.bind())
	get_node("Buttons/01_level").grab_focus()

func _level_select(level):
	GlobalSounds.on_button_pressed()
	get_tree().change_scene_to_file("res://scenes/level/"+str(level)+".tscn")
	GlobalSounds.home = false

func _on_back_to_home_pressed():
	GlobalSounds.on_button_pressed()
	get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")

func _process(delta):
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")

func _focus_switch():
	$Button_hover.play()
