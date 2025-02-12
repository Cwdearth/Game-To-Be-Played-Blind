extends CharacterBody3D

signal target_reached_signal
const WALK_SPEED = 3.5
const SENSITIVITY = 0.03

@onready var head = $"Player Head"
@onready var camera = $"Player Head/Camera3D"
	
func _process(_delta) -> void:
	if Input.is_action_pressed("left"):
		self.rotate_y(SENSITIVITY)
	elif Input.is_action_pressed("right"):
		self.rotate_y(-SENSITIVITY)
		
	if target_reached():
		emit_signal("target_reached_signal")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("up", "down", "right", "left")
	var direction = (self.transform.basis * Vector3(input_dir.x, 0, 0)).normalized()

	if direction:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
		
	move_and_slide()

func target_reached() -> bool:
	for index in range(get_slide_collision_count()):

		var collision = get_slide_collision(index)

		if collision.get_collider() == null:
			continue
			
		if collision.get_collider().is_in_group("Enemy"):
			return true
			
	return false
