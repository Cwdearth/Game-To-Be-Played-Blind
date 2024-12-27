extends Node3D

@onready var enemy_agent_chasing = $"NPC Chasing"
@onready var enemy_agent_avoiding = $"NPC Avoiding"
@onready var player = $"Player"

@onready var nav_region = $NavigationRegion3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_agent_avoiding.nav_region = nav_region
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	enemy_agent_chasing.update_target_position(player.global_transform.origin)
	enemy_agent_avoiding.update_target_position(player.global_transform.origin)
