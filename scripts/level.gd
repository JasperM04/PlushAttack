extends Node3D
var score = 0
var target_score = 0
var mouse_scene = preload("res://scenes/mouse.tscn")
var mouse_spawned = 0
var collected_mouse = 0
var points_per_second = 15
var time_left : int
@export var two_stars = 0
@export var three_stars = 0
@export var next_scene = PackedScene
@export var max_spawned = 5
@export var mouse_on_screen = 3
@export var level_time = 45
@export var tutorial:bool = false
var score_time
func _ready():
	$HUD/tutorial.state = tutorial
	$HUD/win.visible = false
	$HUD/lose.visible = false
	$HUD/win/Control/One_star.visible = false
	$HUD/win/Control/Two_star.visible = false
	$HUD/win/Control/Three_star.visible = false
	$HUD/tutorial.visible = false
	$HUD/pause.visible = false
	$camera.target = $player
	time_left = level_time * 10
	$HUD/UI/timer/TextureProgressBar.max_value = time_left
	$HUD/UI/timer/TextureProgressBar.value = $HUD/UI/timer/TextureProgressBar.max_value
	$HUD/UI/Label.text = str(collected_mouse) + "/" + str(max_spawned)
	$player.global_position = $playerspawn.global_position
	$player.on_picked_up_mouse.connect(on_picked_up_mouse)
	$picked_up_mouse_container/m1.setup($player/Plueshi/mouse_position)
	$picked_up_mouse_container/m2.setup($player/Plueshi/mouse_position)
	$picked_up_mouse_container/m3.setup($player/Plueshi/mouse_position)
	mouse_spawner(mouse_on_screen)
	
		
func _process(delta):
	if $HUD/UI/timer/TextureProgressBar.value < 100 && GlobalSounds.timer_ring.playing == false:
		GlobalSounds.timer_ring.play()
	tutorial = $HUD/tutorial.state
	if tutorial == true:
		$HUD/tutorial.visible = true
		get_tree().paused = true
	else:
		$HUD/tutorial.visible = false
	if Input.is_action_just_pressed("Pause") && tutorial == false && get_tree().paused == false:
			$HUD/pause.visible = true
			$HUD/pause/Buttons/Continue.grab_focus()
			get_tree().paused = true
		
func _on_basket_body_entered(body):
	if not body.is_in_group("player"): return
	$player.update_basket.connect(update_basket)
	body.submit_mouse()
	
func load_next_scene():
	get_tree().change_scene_to_packed(next_scene)

func update_basket(picked_up_mouse):
	$basket/basketsound.play()
	collected_mouse += picked_up_mouse
	for i in range(3):
		var m =$picked_up_mouse_container.get_node("m"+ str(i+1))
		m.visible = false
	$basket/basket_animated/AnimationPlayer.play("Bounce")
	target_score += picked_up_mouse * 100 * 1.5 - 50
	$basket/CollisionShape3D/Label3D.text = "+"+str(picked_up_mouse * 100 * 1.5 - 50)+"P"
	$basket/AnimationPlayer.play("Score_over_basket")
	$HUD/UI/Label.text = str(collected_mouse) + "/" + str(max_spawned)
	check_spawn_mouse(picked_up_mouse)
	$basket.get_node("basketscore" + str(picked_up_mouse)).play()
	
func mouse_spawner(amount):
	var last_positions = []
	for i in range(amount):
		var m = mouse_scene.instantiate()
		var spawn = get_spawn_position(last_positions)
		last_positions.insert(i,spawn)
		m.global_position = spawn.global_position
		$mouse_spawn_container.add_child(m)
		mouse_spawned += 1
		
func get_spawn_position(last):
	var spawner = $mouse_positions.get_children()
	if last.size() != 0:
		for i in range(last.size()):
			spawner.erase(last[i])
	return spawner.pick_random()
	
func on_picked_up_mouse(amount):
	for i in range(amount):
		var m =$picked_up_mouse_container.get_node("m"+ str(i+1))
		m.visible = true

func check_spawn_mouse(amount):
	if max_spawned <= collected_mouse: return try_load_win_screen()
	if max_spawned <= mouse_spawned: return
	var m = mouse_spawned + amount
	if m < max_spawned:
		mouse_spawner(amount)
	elif m >= max_spawned:
		mouse_spawner(max_spawned - mouse_spawned)

func load_win_screen():
	get_tree().paused = true
	$HUD/lvl_music.stop()
	$HUD/win/win_music.play()
	$HUD/win.visible = true
	$HUD/win/Control/NextLevelButton.grab_focus()
	$HUD/UI/timer/Timer.stop()
	target_score += (score_time /10) * points_per_second
	$HUD/win/Control/TimerIcon/Label.text = "+"+str((score_time /10) * points_per_second)
	$HUD/win/Control/AnimationPlayer.play("Timer_score")
	$HUD/win/Control/Score.text = "SCORE: "+ str(score)
	
func _stars_winscreen():
	if target_score < two_stars:
		$HUD/win/Control/AnimationPlayer.play("One_star")
	elif target_score >= two_stars && target_score < three_stars:
		$HUD/win/Control/AnimationPlayer.play("Two-star")
	else:
		$HUD/win/Control/AnimationPlayer.play("Three_star")
	
func load_lose_screen():
	get_tree().paused = true
	$HUD/lose.visible = true
	$HUD/lvl_music.stop()
	$HUD/lose/lose_music.play()
	$HUD/lose/Control/RestartButton.grab_focus()
	
func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next_level_button_pressed():
	get_tree().paused = false
	load_next_scene()
	
func _on_home_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level/start_menu.tscn")
	
func _on_timer_timeout():
	time_left -=1
	$HUD/UI/timer/TextureProgressBar.value = time_left
	if time_left  <= -35:
		load_lose_screen()
		$HUD/UI/timer/Timer.stop()
	elif $HUD/UI/timer/TextureProgressBar.value == $HUD/UI/timer/TextureProgressBar.min_value:
		$player.freeze = true
		
func try_load_win_screen():
	score_time = time_left
	$HUD/win/win_timer.start()
	$player.freeze = true
	$HUD/lvl_music.stop()
	GlobalSounds.win_drums.play()
	
func _on_add_score_timeout():
	if score < target_score:
		score += 5
		$HUD/win/Control/Score.text = "SCORE: "+ str(int(score))
		$HUD/UI/Labelscore.text = "SCORE: " + str(int(score))
		if $HUD/win/score.playing == false && $HUD/win.visible == true:
			$HUD/win/score.play()


func _on_win_timer_timeout():
	load_win_screen()
