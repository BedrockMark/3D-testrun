extends GPUParticles3D

func _enter_tree() -> void:
	emitting = true

func _on_finished() -> void:
	#print("I'm Free!")
	queue_free()
	pass # Replace with function body.
