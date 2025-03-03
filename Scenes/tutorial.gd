extends Control

var tutorial_time = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _process(_delta):
	if $ProgressBar.value == 45:
		get_tree().get_root().get_node("Tutorial").queue_free()
	
func _on_timer_timeout() -> void:
	$ProgressBar.value += 1
