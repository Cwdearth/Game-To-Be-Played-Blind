extends Control

@onready var round_type_default = false
@onready var round_blindfold_default = false
@onready var root_node = get_tree().get_root()

var game = load("res://Scenes/MarcoPoloEsquee.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	root_node.get_node("Menu").queue_free()
	root_node.add_child(game)
	game.set_round_default(round_type_default)
	game.set_blindfold_default(round_blindfold_default)
	game.game_start()
	

func _on_round_type_toggled(toggled_on: bool) -> void:
	round_type_default = toggled_on

func _on_round_blindfold_toggled(toggled_on: bool) -> void:
	round_blindfold_default = toggled_on

func _on_exit_game_pressed() -> void:
	root_node.exit()
