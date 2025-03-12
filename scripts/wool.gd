extends RigidBody3D
var direction
func _process(delta):
	if direction > 0:
		$wool_asset.global_rotation_degrees = Vector3(0,0,-10)
	elif direction < 0:
		$wool_asset.global_rotation_degrees = Vector3(0,180,-10)
		
func _on_body_entered(body):
	queue_free()
	if body.is_in_group("mouse"):
		body.is_wrapped()
