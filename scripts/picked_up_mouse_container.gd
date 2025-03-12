extends Node3D
var player_position = null
var target = []
func _process(delta):
	if player_position != null:
		var child = get_children()
				
