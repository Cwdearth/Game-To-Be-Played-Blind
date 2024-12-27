extends CharacterBody3D

const WALK_SPEED = 3.5
const SENSITIVITY = 0.03

@onready var head = $"Player Head"
@onready var camera = $"Player Head/Camera3D"
@onready var moving = false
	
func _process(_delta) -> void:
	if Input.is_action_pressed("left"):
		head.rotate_y(SENSITIVITY)
	elif Input.is_action_pressed("right"):
		head.rotate_y(-SENSITIVITY)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("up", "down", "right", "left")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, 0)).normalized()

	if direction:
		moving = true
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		moving = false
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
		
	move_and_slide()
