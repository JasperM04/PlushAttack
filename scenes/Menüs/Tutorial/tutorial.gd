extends Control

var tutorial_id:int
var state = false
func _ready():
	$Animations/Walk_animtaion.visible = true
	$Animations/Walk_animtaion.play("default")
	$Animations/Small_jump_animation.visible = false
	$Animations/Long_jump_animation.visible = false
	$Animations/Throw_animation.visible = false
	$Animations/Collecting_animation.visible = false
	$Animations/Basket.visible = false
	tutorial_id = 0

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		$Animations.get_child(tutorial_id).visible = false
		$Animations.get_child(tutorial_id).pause()
		tutorial_id += 1
		if tutorial_id <= 5:
			$Button_hover.play()
			$Animations.get_child(tutorial_id).visible = true
			$Animations.get_child(tutorial_id).play("default")
		else:
			$Animations/Walk_animtaion.visible = true
			state = false
			tutorial_id = 0
			if get_parent().get_node("pause").visible == false:
				get_tree().paused = false
		
	if Input.is_action_just_pressed("back"):
		if tutorial_id > 0:
			$Button_hover.play()
			$Animations.get_child(tutorial_id).visible = false
			$Animations.get_child(tutorial_id).pause()
			tutorial_id -= 1
			$Animations.get_child(tutorial_id).visible = true
			$Animations.get_child(tutorial_id).play("default")
			
	if Input.is_action_just_pressed("ui_cancel"):
		$Animations/Walk_animtaion.visible = true
		state = false
		tutorial_id = 0
		if get_parent().get_node("pause").visible == false:
			get_tree().paused = false
