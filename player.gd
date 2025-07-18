extends CharacterBody3D

const SPEED = 5.0

@onready var camera: Camera3D = $"../Camera3D"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var tween:Tween

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos := get_viewport().get_mouse_position()
		var world_3d := get_world_3d()
		var space_state := world_3d.direct_space_state
		
		var from := camera.project_ray_origin(mouse_pos)
		var to := from + camera.project_ray_normal(mouse_pos) * 1000.0
		
		var query := PhysicsRayQueryParameters3D.create(from, to)
		var result := space_state.intersect_ray(query)
		
		if result:
			agent_goto(result.position)
			summon_particle(result.position)

func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var current_agent_pos := global_transform.origin
	var next_path_pos := nav_agent.get_next_path_position()

	var new_velocity := (next_path_pos - current_agent_pos).normalized() * SPEED
	
	nav_agent.set_velocity(new_velocity)

func agent_goto(target_pos: Vector3) -> void:
	nav_agent.set_target_position(target_pos)

func summon_particle(pos: Vector3) -> void:
	var particle := preload("res://effect.tscn").instantiate()
	particle.position = pos
	get_parent().add_child(particle)

func agent_velocity_handler(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
	
	var direction = velocity
	direction.y = 0
	if direction.length_squared() > 0.001:
		# Quaternion convertion, avoid gimbal lock
		var target_quat := Quaternion(Basis.looking_at(direction.normalized(), Vector3.UP))

		# kill tween, if any
		if tween and tween.is_running():
			tween.kill()
		
		# new tween & rotate
		tween = create_tween()
		tween.tween_property(self, "quaternion", target_quat, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
