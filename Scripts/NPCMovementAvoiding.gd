extends CharacterBody3D

const WALK_SPEED = 4.0

@onready var enemy_agent = $NavigationAgent3D
@onready var enemy_mesh = $"NPC Chasing Mesh"
@onready var nav_region
	
# Create movement paths
func _physics_process(_delta: float):
		
	var current_location = global_transform.origin #From global transform obtain the origin variable (Vector3D)
	var next_location = enemy_agent.get_next_path_position()
	velocity = (next_location - current_location).normalized() * WALK_SPEED
	
	move_and_slide()


func update_target_position(player_position: Vector3) -> void:
	# If the player is in range, then generate a new position in an opposite quadarent
	if (player_position.distance_to(enemy_mesh.global_transform.origin) < 2):
		var bounds_min = Vector3(0 , player_position.y - 0.5,0)
		var bounds_max = Vector3(15 * -(sign(player_position.x)), player_position.y - 0.5, 15 * -(sign(player_position.z)))
		var target_position = get_random_position_in_bounds(bounds_min, bounds_max)
		
		while (!is_valid_position(target_position)):
			target_position = get_random_position_in_bounds(bounds_min, bounds_max)
	
		enemy_agent.set_target_position(target_position)
	else:
		return


func get_closest_point(pos: Vector3) -> Vector3:
	var nav_map_rid = nav_region.get_navigation_map()
	return NavigationServer3D.map_get_closest_point(nav_map_rid, pos)
	
	
func get_random_position_in_bounds(bounds_min: Vector3, bounds_max: Vector3) -> Vector3:
	var x = randf_range(bounds_min.x, bounds_max.x)
	var y = randf_range(bounds_min.y, bounds_max.y)
	var z = randf_range(bounds_min.z, bounds_max.z)
	var target_position = Vector3(x,y,z)

	return target_position


func is_valid_position(test_position: Vector3) -> bool:
	# Get the closest point
	var closest_point = get_closest_point(test_position)
	return closest_point.distance_to(test_position) < 0.75  # Might adjust this value later
