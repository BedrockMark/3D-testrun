extends MeshInstance3D

func _ready() -> void:
	var trans_control = create_tween()
	mesh.material.albedo_color.a = 1.0
	trans_control.tween_property(mesh.material, "albedo_color:a", 0.0, 1.0)
