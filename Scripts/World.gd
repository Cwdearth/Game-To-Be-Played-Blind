extends Node3D

@onready var enemy_agent_chasing = $"NPC Chasing"
@onready var enemy_agent_avoiding = $"NPC Avoiding"
@onready var player = $"Player"

@onready var round_type = 1 # 1 = Chaser, -1 = Chasing
@onready var rounds = 2
@onready var timer = $Timer

@onready var nav_region = $NavigationRegion3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_agent_avoiding.nav_region = nav_region
	
	reset_round()
	
	if (round_type == 1):
		setup_chasing_round()
		# SPAWN AVOIDANT TYPE NPC
	else:
		setup_chaser_round()
		# SPAWN CHASER TYPE NPC
	
func _physics_process(_delta: float) -> void:
	enemy_agent_chasing.update_target_position(player.global_transform.origin)
	enemy_agent_avoiding.update_target_position(player.global_transform.origin)
	
	if (player.target_reached() or timer.is_stopped()):
		rounds -= 1
		reset_round()
		
		if (round_type == 1):
			setup_chaser_round()
		elif (round_type == 2):
			setup_chasing_round()
			
		round_type *= -1
		
		if (rounds == 0):
			get_tree().quit()
			
		timer.start()

# HARDCODING SOME VARIABLES, MIGHT MAKE MORE DYNAMIC LATER, BUT I'D RATHER REDUCE VARIABLES
func setup_chaser_round() -> void:
	enable_entity(enemy_agent_chasing)
	enemy_agent_chasing.position = Vector3(0, 1, -3)
	
func setup_chasing_round() -> void:
	enable_entity(enemy_agent_avoiding)
	enemy_agent_avoiding.position = Vector3(0, 1, 3)
	
func reset_round() -> void:
	player.position = Vector3(0, .75, 5)
	player.head.rotation = Vector3(0, 0, 0)
	# Reset player pos, remove all current enemies.
	disable_entity(enemy_agent_chasing)
	disable_entity(enemy_agent_avoiding)
	
func enable_entity(npc: CharacterBody3D) -> void:
	npc.show()
	npc.set_process(true)
	npc.set_physics_process(true)
	npc.set_process_input(true)
	
func disable_entity(npc: CharacterBody3D) -> void:
	npc.position = Vector3(0, -10, 0)
	npc.hide()
	npc.set_process(false)
	npc.set_physics_process(false)
	npc.set_process_input(false)
