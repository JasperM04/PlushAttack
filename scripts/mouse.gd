extends CharacterBody3D


var speed = 2.5
@export var direction = 1

var wrapped = false
var jump_power = 3.5
var jump_time = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity = 50
var collected = false
var player = null
var hole_cooldown = 1
var is_chased = false
@export var is_using_tunnel = false

func _physics_process(delta):
	var player_detect = $player_checker.is_colliding()
	if is_chased:
		speed = 5
	else:
		speed = 3.5
	if player_detect:
		is_chased = true
		if $chase_timer.time_left <= 0 && wrapped == false && is_using_tunnel == false:
			direction *= -1
		$chase_timer.start()
	if collected == false:
		if jump_time > 0:
			jump_time -= delta
		else: 
			jump_time = 0
		if hole_cooldown > 0:
			hole_cooldown -= delta
		else: 
			hole_cooldown = 0
		if not is_on_floor():
			if velocity.y < 0:
				velocity.y -= fall_gravity * delta
			else:
				velocity.y -= gravity * delta
		var wall = $wall_checker.is_colliding()
		var can_jump = !$jump_checker.is_colliding()
		var ledge = !$ledge_checker.is_colliding()
		
		if is_on_wall() or ledge:
			direction *= -1
		elif wall && can_jump == true:
			velocity.y = jump_power
			jump_time = 0.2
		if direction > 0:
			global_rotation_degrees.y = 0
		elif direction < 0:
			global_rotation_degrees.y = 180
		if jump_time > 0:
			velocity.x = direction * 1.2
		elif wrapped == true or is_using_tunnel == true:
			velocity.x = 0
		else:
			velocity.x = direction * speed
			$toy_mouse_animated/AnimationPlayer.play("walk")
		move_and_slide()
	
		
func is_wrapped():
	wrapped = true
	$AnimationPlayer.play("wrapped")
	$mouse_wrapped_animated_V2/AnimationPlayer.play("idle")
	$wrapped_timer.start()
	is_using_tunnel = false
	await get_tree().create_timer(0.06).timeout
	GlobalSounds.get_node("mouse_squeek").play()
	GlobalSounds.get_node("mouse_squeek").pitch_scale= randf_range(0.9,1)
func _on_wrapped_timer_timeout():
	wrapped = false
	$AnimationPlayer.play("idle")

func is_collected(body):
	$wrapped_timer.stop()
	collected = true
	player = body

func try_use_tunnel(entry,exit):
	var r = 3
	if is_chased:
		r = 1
	var rnd = randi_range(0,r)	
	if rnd > 0: return
	if wrapped == false && hole_cooldown <= 0:
		global_position = entry.global_position
		use_tunnel(exit)
func _on_chase_timer_timeout():
	is_chased = false

func use_tunnel(exit):
	direction = -1
	is_using_tunnel = true
	$toy_mouse_animated/AnimationPlayer.play("disappear")
	await $toy_mouse_animated/AnimationPlayer.animation_finished
	if wrapped == true: 
		return
	hole_cooldown = 1
	global_position = exit.global_position
	$toy_mouse_animated/AnimationPlayer.play("appear")
	await $toy_mouse_animated/AnimationPlayer.animation_finished
	is_using_tunnel = false
	
