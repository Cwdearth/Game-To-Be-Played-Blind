extends Node

@onready var root_node = get_tree().get_root()

@onready var environment = $WorldEnvironment.environment
@onready var nav_region = $NavigationRegion3D
@onready var player = $"Player"
@onready var enemy_agent_chasing = $"NPCChasing"
@onready var enemy_agent_avoiding = $"NPCAvoiding"

@onready var timer = $Timer

var data_file_path = ""
var data_file
var update_timer = 0.0
var update_interval = 0.2

var avoiding = false # Avoiding target if true, Chasing target if false
var blindfolded = false  # True = Blindfolded first | False = Blindfolded Second
var total_rounds = 2
var round = total_rounds

var round_in_progress = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_agent_avoiding.nav_region = nav_region
	
	var date_time_string = Time.get_datetime_string_from_system().replace("-", "_").replace(":", "_")
	data_file_path = "user://" + date_time_string + ".dat"
	data_file = FileAccess.open(data_file_path, FileAccess.WRITE)
	if (!FileAccess.file_exists(data_file_path)):
		print("Error! Data file not created!")

	start_round()
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	# Rotate the sky for a more enjoyable experience
	environment.sky_rotation.y += 0.0005
	environment.sky_rotation.x += 0.00005

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If it isn't the first round, then update the appropriate npc's knowledge of the player's location.
	if round != total_rounds:
		if avoiding:
			enemy_agent_chasing.update_target_position(player.global_transform.origin)
		else:
			enemy_agent_avoiding.update_target_position(player.global_transform.origin)
			
	# Update CSV file based on timer intervals
	update_timer += delta
	if update_timer >= update_interval:
		update_csv()
		update_timer = 0.0
	
	# HANDLE END CONDITIONS IN PROCESS
	
	# If the timer stops while the round is in progress, then end the round.
	# When the target reached condition occurs the timer is stopped, which triggers this logic as well.
	if round_in_progress and (timer.is_stopped() or (distance_between_player_target() < 0.6)):
		end_round()

func start_round() -> void:
	# Start round timer
	timer.start()
	round_in_progress = true
	
	$RoundStarted.play()
	
	# Transition player into the round
	if round != total_rounds:
		if avoiding:
			spawn_chaser()
		else:
			spawn_avoider()
		default_transition()
		
func end_round() -> void:
	round_in_progress = false
	# If it is the last round, end the game
	if (round == 0):
		data_file.close()
		get_tree().quit()
	
	# Reset the player position when the round ends, and reset the enemies.
	reset_player_position()
	enable_entity(enemy_agent_avoiding, false)
	enable_entity(enemy_agent_chasing, false)
	# Change round type and blindfold
	set_avoiding(!avoiding)
	set_blindfolded(!blindfolded)
		
	round -= 1
	# Start the next round
	start_round()
	
func spawn_chaser() -> void:
	enable_entity(enemy_agent_chasing, true)
	enemy_agent_chasing.global_position = Vector3(0, .75, 10)

func spawn_avoider() -> void:
	enable_entity(enemy_agent_avoiding, true)
	enemy_agent_avoiding.global_position = Vector3(0.5, 0.75, 3)
	
func reset_player_position() -> void:
	player.global_position = Vector3(0, .75, 5)
	# I CRACKED THE CODE! THE ROTATION IS IN... RADIANS
	player.global_rotation = Vector3(0, -1.5708, 0)

func default_transition() -> void:
	$Prompt.toggle_prompt(true)
	
func enable_entity(npc: CharacterBody3D, enable: bool) -> void:
	if enable:
		npc.show()
		npc.set_process(true)
		npc.set_physics_process(true)
		npc.set_process_input(true)
	else:
		npc.global_position = Vector3(0, -10, 0)
		npc.set_process(false)
		npc.set_physics_process(false)
		npc.set_process_input(false)
		npc.hide()

func set_avoiding(state) -> void:
	avoiding = state
	$Prompt.set_avoiding(avoiding)
	
func set_blindfolded(state) -> void:
	blindfolded = state
	$Prompt.set_blindfolded(blindfolded)
	
func _on_player_target_reached_signal() -> void:
	timer.stop()
	
# Data collection utility
func distance_between_player_target() -> float:
	if avoiding:
		# CHASING NPC DISTANCE TO PLAYER
		return player.global_position.distance_to(enemy_agent_chasing.global_position)
	else:
		# PLAYER DISTANCE TO AVOIDANT NPC
		return player.global_position.distance_to(enemy_agent_avoiding.global_position)
	
# CSV Updater for the CSV Research Data File
func update_csv():
	var new_data_line = ""
	var distance = ""
	
	if round == total_rounds:
		distance = str(player.global_position.distance_to(Vector3(0, .75, 5)))
	else:
		distance = str(distance_between_player_target())
	new_data_line = str(round) + "," + str(avoiding) + "," + str(blindfolded) + "," + str(timer.time_left) + "," + Time.get_time_string_from_system() + "," + distance
	data_file.store_line(new_data_line)
