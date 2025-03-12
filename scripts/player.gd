extends CharacterBody3D
signal update_basket
signal on_picked_up_mouse
@export var speed = 8
@export var jump_power = 12
var wool = preload("res://scenes/wool.tscn")
var jump_vfx = preload("res://assets/vfx/jump_vfx.tscn")
var landing_vfx = preload("res://assets/vfx/landing_vfx.tscn")
@export var jump_gravity = 20
@export var fall_gravity = 50
var gravity = jump_gravity
var wool_cooldown = 0.3
var can_jump = false
var jump_buffer = 0.0
var collect_cooldown = 0.0
var current_speed = speed
var picked_up_mouse = 0
var freeze = false
@export var is_shooting = false

func _physics_process(delta):
	var is_landing = $landing_checker.is_colliding() && jump_buffer <= 0
	if jump_buffer > 0:
		jump_buffer -= delta
	else:
		jump_buffer = 0
	check_shoot()
	if wool_cooldown > 0:
		wool_cooldown -= delta
	else:
		wool_cooldown = 0
	if collect_cooldown > 0:
		collect_cooldown -= delta
	else:
		collect_cooldown = 0
	if is_on_floor() && can_jump == false:
		can_jump = true
	elif can_jump == true && $coyote.is_stopped():
		$coyote.start()
	if jump_buffer > 0 && can_jump == true:
		velocity.y = jump_power
		can_jump = false
		jump_buffer = 0.0
		$jump_sound.play()
	velocity.y -= get_gravity() * delta
	if Input.is_action_just_pressed("jump") && can_jump == true && freeze == false:
		jump_buffer = 0.3
		$vfx_cooldown.start()
	if not is_on_floor() && is_landing:
		play_vfx()
		if velocity.x == 0:
			$walk_sound.play()
	var input_dir = Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && freeze == false:
		velocity.x = direction.x * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
	if freeze == true:
		$Plueshi.global_rotation_degrees.y = 0
	elif direction.x > 0:
		$Plueshi.global_rotation_degrees.y = 90
	elif direction.x < 0:
		$Plueshi.global_rotation_degrees.y = -90
	$Plueshi.scale = Vector3(1.255,1.255,1.255)
	if is_on_floor() && velocity.x != 0 && not is_on_wall():
		if $walk_sound.playing == false:
			$walk_sound.pitch_scale = randf_range(0.8,1.2)
			$walk_sound.play()
	move_and_slide()
	play_animation()
	
func check_shoot():
	if freeze == true: return
	if Input.is_action_just_pressed("shoot") && wool_cooldown <= 0:
		$AnimationPlayer.play("on_shoot")
		wool_cooldown = 0.3
		
func shoot():
	var w = wool.instantiate()
	w.global_position = $Plueshi/wool_spawn.global_position
	var shoot_direction = $Plueshi/wool_spawn.global_transform.basis.z.normalized()
	var x = shoot_direction * 15
	w.direction = shoot_direction.x
	w.apply_central_impulse(x)
	get_tree().root.add_child(w)
	$shoot_sound.play()
	
func _on_coyote_timeout():
	can_jump = false
	
func _on_detact_mouse_body_entered(body):
	if body.is_in_group("mouse") && body.wrapped == true && picked_up_mouse < 3 && body.collected == false:
		current_speed -= 0.5
		picked_up_mouse += 1
		$pickedup.text = str(picked_up_mouse) + "/3"
		$AnimationPlayer.play("on_pickup")
		on_picked_up_mouse.emit(picked_up_mouse)
		body.queue_free()
		get_node("pickup_sound" + str(picked_up_mouse)).play()
	elif picked_up_mouse >= 3 && body.wrapped == true: 
		$AnimationPlayer.play("on_pickup_full")
		$pickup_sound_deny.play()
		
func submit_mouse():
	if picked_up_mouse < 1: return
	update_basket.emit(picked_up_mouse)
	picked_up_mouse = 0
	current_speed = speed
	
func is_below_ceiling():
	return $ceiling_checker.is_colliding()
	
func get_gravity():
	if velocity.y < 0:
		return fall_gravity
	if is_below_ceiling():
		return fall_gravity
	return jump_gravity if Input.is_action_pressed("jump") else fall_gravity

func get_animation():
	if $landing_checker.is_colliding() && not is_on_floor() && velocity.y < 0:
		return "landing"
	if is_shooting:
		return "throw"
	if velocity.y > 0:
		return "jump"
	elif velocity.y < 0:
		return "fall"
	else:
		if velocity.x != 0:
			return "walk"
		else:
			return "idle"
			
func play_animation():
	var state = get_animation()
	$Plueshi/AnimationPlayer.play(state)

func play_vfx():
	if !$vfx_cooldown.is_stopped(): return
	var v = landing_vfx.instantiate()
	v.global_position = global_position
	get_tree().root.add_child(v)
	$vfx_cooldown.start()
	
