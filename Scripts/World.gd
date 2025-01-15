extends Node3D

@onready var enemy_agent_chasing = $"NPC Chasing"
@onready var enemy_agent_avoiding = $"NPC Avoiding"
@onready var player = $"Player"

@onready var round_default = true
@onready var round_blindfold_default = true  # True = Blindfolded first | False = Blindfolded Second
@onready var rounds = 3
@onready var timer = $Timer
@onready var root_node = get_tree().get_root()
var prompt = preload("res://Scenes/Prompt.tscn").instantiate()

@onready var nav_region = $NavigationRegion3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_agent_avoiding.nav_region = nav_region
	game_start()
	
	
func _physics_process(_delta: float) -> void:
	enemy_agent_chasing.update_target_position(player.global_transform.origin)
	enemy_agent_avoiding.update_target_position(player.global_transform.origin)
	
	if (player.target_reached() or timer.is_stopped()):
		#TODO PROMPT PLAYER
		root_node.add_child(prompt)
		prompt.enable_label("doff")
		get_tree().paused = true
		#root_node.get_node("Prompt").queue_free()
		#get_tree().paused = false
		# PAUSE GAME
		# HAVE PROMPT WAIT FOR MOVEMENT
		transition_round()
		
		
func game_start() -> void:
	reset_round()
	timer.start()
		
func transition_round() -> void:
	rounds -= 1
	reset_round()
	
	if (round_default):
		setup_chaser_round()
	else:
		setup_chasing_round()
		
	round_default = !round_default
	
	if (rounds == 0):
		get_tree().quit()
		
	timer.start()


func reset_round() -> void:
	player.position = Vector3(0, .75, 5)
	player.head.rotation = Vector3(0, 0, 0)
	# Reset player pos, remove all current enemies.
	disable_entity(enemy_agent_chasing)
	disable_entity(enemy_agent_avoiding)
	
# HARDCODING SOME VARIABLES, MIGHT MAKE MORE DYNAMIC LATER, BUT I'D RATHER REDUCE VARIABLES
func setup_chaser_round() -> void:
	enable_entity(enemy_agent_chasing)
	enemy_agent_chasing.position = Vector3(0, 1, -3)
	
	
func setup_chasing_round() -> void:
	enable_entity(enemy_agent_avoiding)
	enemy_agent_avoiding.position = Vector3(0, 1, 3)
	
	
func set_round_default(default) -> void:
	round_default = default
	
	
func set_blindfold_default(default) -> void:
	round_blindfold_default = default
	
	
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
