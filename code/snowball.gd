extends Area2D

func _on_body_entered(body):
	queue_free()
	var Snowballs = get_tree().get_nodes_in_group("Snowballs")
	if Snowballs.size() == 1:
		print("Level Completed")
		Events.level_completed.emit()
