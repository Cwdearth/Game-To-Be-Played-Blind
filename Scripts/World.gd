extends Node3D

@onready var nav_region = $NavigationRegion3D
@onready var enemy_agent_chasing = $"NPC Chasing"
@onready var enemy_agent_avoiding = $"NPC Avoiding"
@onready var player = $"Player"
@onready var timer = $Timer
@onready var environment = $WorldEnvironment.environment
@onready var root_node = get_tree().get_root()

@onready var round_default = true
@onready var round_blindfold_default = true  # True = Blindfolded first | False = Blindfolded Second
@onready var rounds = 3

var round_in_progress = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_round()

func _physics_process(_delta: float) -> void:
	enemy_agent_chasing.update_target_position(player.global_transform.origin)
	enemy_agent_avoiding.update_target_position(player.global_transform.origin)
	environment.sky_rotation.y += 0.0005
	environment.sky_rotation.x += 0.00005

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
	
	if rounds == 0:
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
