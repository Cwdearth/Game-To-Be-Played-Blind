extends Control

@onready var avoiding = false
@onready var blindfolded = false
@onready var root_node = get_tree().get_root()

var world = load("res://Scenes/world.tscn").instantiate()
var tutorial = load("res://Scenes/tutorial.tscn").instantiate()
var started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $TutorialTimer.is_stopped() and started:
		root_node.get_node("MainMenu").queue_free()
		# Add the game scene to tree
		root_node.add_child(world)

func _on_start_game_pressed() -> void:
	# Initialize avoiding boolean (Avoiding round first, true or false)
	world.set_avoiding(avoiding)
	# Initialize blindfolded boolean (Blindfolded round first, true or false)
	world.set_blindfolded(blindfolded)
	
	# Delete main menu, it is no longer needed
	root_node.add_child(tutorial)
	$TutorialTimer.start()
	started = true

func _on_round_type_toggled(toggled_on: bool) -> void:
	avoiding = toggled_on

func _on_round_blindfold_toggled(toggled_on: bool) -> void:
	blindfolded = toggled_on

func _on_exit_game_pressed() -> void:
	get_tree().quit()
	
func _on_start_game_mouse_entered() -> void:
	$ButtonEntered.play()

func _on_exit_game_mouse_entered() -> void:
	$ButtonEntered.play()
