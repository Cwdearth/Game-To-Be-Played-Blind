extends Node3D

@onready var nav_region = $NavigationRegion3D
@onready var enemy_agent_chasing = $"NPC Chasing"
@onready var enemy_agent_avoiding = $"NPC Avoiding"
@onready var player = $"Player"
@onready var timer = $Timer
@onready var environment = $WorldEnvironment.environment
@onready var root_node = get_tree().get_root()

var data_file_path = ""
var data_file
var update_timer = 0.0
var update_interval = 0.2

@onready var round_default = true
@onready var round_blindfold_default = true  # True = Blindfolded first | False = Blindfolded Second
@onready var rounds = 3

var round_in_progress = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var date_time_string = Time.get_datetime_string_from_system().replace("-", "_").replace(":", "_")
	data_file_path = "user://" + date_time_string + ".dat"
	data_file = FileAccess.open(data_file_path, FileAccess.WRITE)
	if (!FileAccess.file_exists(data_file_path)):
		print("Error! Data file not created!")
	
	start_round()

func _physics_process(_delta: float) -> void:
	enemy_agent_chasing.update_target_position(player.global_transform.origin)
	enemy_agent_avoiding.update_target_position(player.global_transform.origin)
	environment.sky_rotation.y += 0.0005
	environment.sky_rotation.x += 0.00005
	
func _process(delta: float):
	update_timer += delta
	if update_timer >= update_interval:
		update_csv()
		update_timer = 0.0

func start_round():
	round_in_progress = true
	player.global_position = Vector3(0, .75, 5)
	# I CRACKED THE CODE! THE ROTATION IS IN... RADIANS
	player.global_rotation = Vector3(0, -1.5708, 0)
	disable_entity(enemy_agent_chasing)
	disable_entity(enemy_agent_avoiding)
	
	if (rounds <= 2):
		initialize_variables()
		if (round_default):
			setup_chaser_round()
		else:
			setup_chasing_round()
	
	timer.start()
	
func end_round():
	rounds -= 1
	round_in_progress = false
	
	if (rounds == 0) and (timer.time_left < timer.wait_time - 1.0):
		# EXIT GAME THE ROUNDS HAVE COMPLETED
		data_file.close()
		get_tree().quit()
	else:
		$Prompt.toggle_prompt(true)
	
func _on_player_target_reached_signal() -> void:
	if round_in_progress:
		print("Target reached!")
		end_round()
	
func _on_timer_timeout() -> void:
	if round_in_progress:
		print("Timer ran out of time!")
		end_round()
	
func initialize_variables():
	$Prompt.set_blindfold_round(round_blindfold_default)
	set_round_default(!round_default)
	set_blindfold_default(!round_blindfold_default)
	enemy_agent_avoiding.nav_region = nav_region

func setup_chaser_round() -> void:
	enable_entity(enemy_agent_chasing)
	enemy_agent_chasing.global_position = Vector3(0, 0.5, -10)
	
func setup_chasing_round() -> void:
	enable_entity(enemy_agent_avoiding)
	enemy_agent_avoiding.global_position = Vector3(6, 0.5, -3)
	
func enable_entity(npc: CharacterBody3D) -> void:
	npc.show()
	npc.set_process(true)
	npc.set_physics_process(true)
	npc.set_process_input(true)
	
func disable_entity(npc: CharacterBody3D) -> void:
	npc.global_position = Vector3(0, -10, 0)
	npc.set_process(false)
	npc.set_physics_process(false)
	npc.set_process_input(false)
	npc.hide()
	
func set_round_default(default) -> void:
	round_default = default	
	
func set_blindfold_default(default) -> void:
	round_blindfold_default = default
	
	
# CSV FILE CREATE FOR RESEARCH VARIABLES - DISTANCE FROM TARGET, ROUND TYPE, BLINDFOLDED TYPE, ROUND TIME, GLOBAL TIME
# ROUND # Numerical value for round
# ROUND TYPE # True = Attacking | False = Avoiding
# BLINDFOLD TYPE # True = Blindfolded first | False = Blindfolded Second
# ROUND TIME # The remaining time in the round
# GLOBAL TIME + DATE
# DISTANCE FROM TARGET

func distance_between_player_target() -> float:
	if round_default:
		# CHASING NPC
		return player.global_position.distance_to(enemy_agent_chasing.global_position)
	else:
		# AVOIDANT NPC
		return player.global_position.distance_to(enemy_agent_avoiding.global_position)
	
func update_csv():
	
	var new_data_line = ""
	var distance = ""
	if rounds == 3:
		distance = str(player.global_position.distance_to(Vector3(0, .75, 5)))
	else:
		distance = str(distance_between_player_target())
	new_data_line = str(rounds) + "," + str(round_default) + "," + str(round_blindfold_default) + "," + str(timer.time_left) + "," + Time.get_time_string_from_system() + "," + distance
	data_file.store_line(new_data_line)
