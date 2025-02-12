extends Control

@onready var round_type_default = false
@onready var round_blindfold_default = false
@onready var root_node = get_tree().get_root()

var world = load("res://Scenes/world.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	# Delete self
	root_node.get_node("MainMenu").queue_free()
	# Add the game scene to tree
	root_node.add_child(world)
	# Configure defaults
	world.set_round_default(round_type_default)
	world.set_blindfold_default(round_blindfold_default)

func _on_round_type_toggled(toggled_on: bool) -> void:
	round_type_default = toggled_on

func _on_round_blindfold_toggled(toggled_on: bool) -> void:
	round_blindfold_default = toggled_on

func _on_exit_game_pressed() -> void:
	root_node.exit()
	
func _on_start_game_mouse_entered() -> void:
	$ButtonEntered.play()

func _on_exit_game_mouse_entered() -> void:
	$ButtonEntered.play()
