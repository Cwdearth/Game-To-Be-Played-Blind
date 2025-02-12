extends Control

@onready var timer = $Timer
var blindfold_round = true
var is_toggled = false
var audio_prompt_stage = 0


func _ready() -> void:
	self.hide()
	set_blindfold_round(blindfold_round)
		
func _input(event):
	# If the player hits any of the movement keys then remove the prompt and proceed to the next round
	if is_toggled and timer.is_stopped():
		if event.is_action_pressed("up"):
			toggle_prompt(false)
			get_tree().get_root().get_node("World").start_round()
		elif event.is_action_pressed("down"):
			toggle_prompt(false)
			get_tree().get_root().get_node("World").start_round()
		elif event.is_action_pressed("left"):
			toggle_prompt(false)
			get_tree().get_root().get_node("World").start_round()
		elif event.is_action_pressed("right"):
			toggle_prompt(false)
			get_tree().get_root().get_node("World").start_round()
		audio_prompt_stage = 0
			
func _process(float:) -> void:
	if !$Timer.is_stopped() and audio_prompt_stage == 0:
		if blindfold_round:
			$BlindfoldOn.play()
		else:
			$BlindfoldOff.play()
		audio_prompt_stage += 1
		
	if $Timer.time_left < 7.0 and audio_prompt_stage == 1:
		if is_toggled:
			$AvoidingRound.play()
		else:
			$ChasingRound.play()
		audio_prompt_stage += 1
	
	if $Timer.time_left < 3.0 and audio_prompt_stage == 2:
		$PressMovementKeys.play()
		audio_prompt_stage += 1
		
func toggle_prompt(state: bool) -> void:
	is_toggled = state
	get_tree().paused = state
	
	if state:
		self.show()
		timer.start()
	else:
		self.hide()

func set_blindfold_round(state: bool) -> void:
	blindfold_round = state
	
	if blindfold_round:
		$Don.show()
		$Doff.hide()
	else:
		$Don.hide()
		$Doff.show()
