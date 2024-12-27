extends CharacterBody3D

const WALK_SPEED = 2.0

@onready var enemy_agent = $NavigationAgent3D

# Create movement paths
func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var current_location = global_transform.origin #From global transform obtain the origin variable (Vector3D)
	var next_location = enemy_agent.get_next_path_position()
	velocity = (next_location - current_location).normalized() * WALK_SPEED
	
	move_and_slide()


func update_target_position(target_position):
	enemy_agent.set_target_position(target_position)
