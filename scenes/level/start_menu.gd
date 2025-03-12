extends CanvasLayer

@export var level_select = PackedScene
@export var settings = PackedScene

func _ready():
	$Buttons/Level_select.grab_focus()
	for child in $Buttons.get_children():
		child.focus_entered.connect(_focus_switch.bind())
	for child in $Buttons.get_children():
		child.mouse_entered.connect(_focus_switch.bind())
	GlobalSounds.home = true
	
func _on_level_select_pressed():
	GlobalSounds.on_button_pressed()
	get_tree().change_scene_to_packed(level_select)
	
func _on_settings_pressed():
	GlobalSounds.on_button_pressed()
	get_tree().change_scene_to_file("res://scenes/Menüs/Settings/settings_menu.tscn")

func _on_exit_pressed():
	GlobalSounds.on_button_pressed()
	get_tree().quit()

func _focus_switch():
	$Button_hover.play()

