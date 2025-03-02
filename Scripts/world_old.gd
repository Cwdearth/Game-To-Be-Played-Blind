extends Node3D

@onready var nav_region = $NavigationRegion3D
@onready var enemy_agent_chasing = $"NPCChasing"
@onready var enemy_agent_avoiding = $"NPCAvoiding"
@onready var player = $"Player"
@onready var timer = $Timer
@onready var environment = $WorldEnvironment.environment
@onready var root_node = get_tree().get_root()

var data_file_path = ""
var data_file
var update_timer = 0.0
var update_interval = 0.2

var avoiding = false # Avoiding target if true, Chasing target if false
var blindfolded = false  # True = Blindfolded first | False = Blindfolded Second
var total_rounds = 3
var round = total_rounds

var round_in_progress = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Give avoidant type npc access to the nav mesh
	enemy_agent_avoiding.nav_region = nav_region
	
	var date_time_string = Time.get_datetime_string_from_system().replace("-", "_").replace(":", "_")
	data_file_path = "user://" + date_time_string + ".dat"
	data_file = FileAccess.open(data_file_path, FileAccess.WRITE)
	if (!FileAccess.file_exists(data_file_path)):
		print("Error! Data file not created!")

	start_round()

func _physics_process(_delta: float) -> void:
	# Rotate the sky for a more enjoyable experience
	environment.sky_rotation.y += 0.0005
	environment.sky_rotation.x += 0.00005
	
func _process(delta: float):
	# If it isn't the first round (Exploratory) then begin updating enemy of player position
	if round != total_rounds:
		if avoiding:
			enemy_agent_chasing.update_target_position(player.global_transform.origin)
		else:
			enemy_agent_avoiding.update_target_position(player.global_transform.origin)
	
	# Periodically add a row to this game's CSV logs
	update_timer += delta
	if update_timer >= update_interval:
		update_csv()
		update_timer = 0.0

func start_round():
	$RoundStarted.play()
	$Player.set_target_reached_value(false)
	round_in_progress = true
	
	if (round != total_rounds):
		$Prompt.set_blindfolded(blindfolded)
		
		if (avoiding):
			setup_chaser_round()
		else:
			setup_chasing_round()
	
	timer.start()
	
func end_round():
	if (round == 0) and (timer.time_left < timer.wait_time - 1.0):
		# EXIT GAME THE ROUNDS HAVE COMPLETED
		data_file.close()
		get_tree().quit()
	else:
		$Prompt.toggle_prompt(true)
	
func setup_chaser_round() -> void:
	enable_entity(enemy_agent_chasing)
	reset_chaser_type_npc_position()
	
func setup_chasing_round() -> void:
	enable_entity(enemy_agent_avoiding)
	reset_avoidant_type_npc_position()
	
func reset_player_position() -> void:
	player.global_position = Vector3(0, .75, 5)
	# I CRACKED THE CODE! THE ROTATION IS IN... RADIANS
	player.global_rotation = Vector3(0, -1.5708, 0)
	
func reset_chaser_type_npc_position() -> void:
	enemy_agent_chasing.global_position = Vector3(0, 0.5, -10)

func reset_avoidant_type_npc_position() -> void:
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
	
func _on_player_target_reached_signal() -> void:
	if round_in_progress:
		if (round != total_rounds):
			set_avoiding(!avoiding)
			set_blindfolded(!blindfolded)
		round_in_progress = false
		round -= 1
		# Prevent timer from timing out and triggering alternative end condition
		timer.stop()
		reset_player_position()
		disable_entity(enemy_agent_avoiding)
		disable_entity(enemy_agent_chasing)
			
		print("Target reached!")
		
		end_round()
	
func _on_timer_timeout() -> void:
	if round_in_progress:
		if (round != total_rounds):
			set_avoiding(!avoiding)
			set_blindfolded(!blindfolded)
		round_in_progress = false
		round -= 1
		reset_player_position()
		disable_entity(enemy_agent_avoiding)
		disable_entity(enemy_agent_chasing)
		
		print("Timer ran out of time!")
		
		end_round()

func distance_between_player_target() -> float:
	if avoiding:
		# CHASING NPC DISTANCE TO PLAYER
		return player.global_position.distance_to(enemy_agent_chasing.global_position)
	else:
		# PLAYER DISTANCE TO AVOIDANT NPC
		return player.global_position.distance_to(enemy_agent_avoiding.global_position)
	
func update_csv():
	var new_data_line = ""
	var distance = ""
	
	if round == total_rounds:
		distance = str(player.global_position.distance_to(Vector3(0, .75, 5)))
	else:
		distance = str(distance_between_player_target())
	new_data_line = str(round) + "," + str(avoiding) + "," + str(blindfolded) + "," + str(timer.time_left) + "," + Time.get_time_string_from_system() + "," + distance
	data_file.store_line(new_data_line)
	
func set_avoiding(state) -> void:
	avoiding = state
	$Prompt.set_avoiding(avoiding)
	
func set_blindfolded(state) -> void:
	blindfolded = state
	$Prompt.set_blindfolded(blindfolded)
