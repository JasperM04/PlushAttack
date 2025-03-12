extends Camera3D

var target = null
var center = Vector3.ZERO

func _process(delta):
	if target != null:
		var camera_position = center.lerp(target.global_position,0.4)
		global_position = camera_position + Vector3(0,2,20)
	position = position.clamp(Vector3(-2.5,-0.5,20),Vector3(2.5,2,20))
