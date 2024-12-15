extends Node

@onready
var swing_sound = $AudioStreamPlayer3D
var swing_timer = 0.0
var swing_duration = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func _process(delta):
	swing_timer += delta
	if swing_timer >= swing_duration:
		swing_timer = 0.0
		swing_sound.play()
	else:
		pass
