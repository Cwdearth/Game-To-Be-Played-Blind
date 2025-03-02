extends CharacterBody3D

const WALK_SPEED = 2.85  # Reduced speed for more natural movement
const ESCAPE_DISTANCE = 3.0  # Minimum distance NPC tries to move away
const ESCAPE_ATTEMPTS = 5  # Number of retries if stuck

@onready var enemy_agent = $NavigationAgent3D
@onready var enemy_mesh = $"NPCChasingMesh"
@onready var nav_region

func _physics_process(_delta: float):
	var current_location = global_transform.origin
	var next_location = enemy_agent.get_next_path_position()

	# Ensure NPC is not stuck and there's a valid path
	if enemy_agent.is_navigation_finished():
		return
	
	velocity = (next_location - current_location).normalized() * WALK_SPEED
	move_and_slide()

func update_target_position(player_position: Vector3) -> void:
	var npc_position = enemy_mesh.global_transform.origin  

	# If the player is too close, move away
	if player_position.distance_to(npc_position) < 5:
		var best_position = null
		var best_distance = 0
		
		for i in range(ESCAPE_ATTEMPTS):  # Try multiple escape directions
			var avoid_direction = (npc_position - player_position).normalized()
			
			# Introduce a slight randomness to avoid predictable movement
			avoid_direction.x += randf_range(-0.2, 0.2)
			avoid_direction.z += randf_range(-0.2, 0.2)
			avoid_direction = avoid_direction.normalized()
			
			var test_position = npc_position + (avoid_direction * randf_range(ESCAPE_DISTANCE, ESCAPE_DISTANCE + 3))
			var valid_position = get_closest_point(test_position)

			# Pick the farthest valid position
			var dist = valid_position.distance_to(player_position)
			if dist > best_distance and is_valid_position(valid_position):
				best_distance = dist
				best_position = valid_position

		# If a valid position is found, set it as the target
		if best_position:
			enemy_agent.set_target_position(best_position)

func get_closest_point(pos: Vector3) -> Vector3:
	var nav_map_rid = nav_region.get_navigation_map()
	return NavigationServer3D.map_get_closest_point(nav_map_rid, pos)

func is_valid_position(test_position: Vector3) -> bool:
	var closest_point = get_closest_point(test_position)
	return closest_point.distance_to(test_position) < 1  # Might adjust this value later
