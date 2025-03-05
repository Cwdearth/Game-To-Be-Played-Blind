extends Control

@onready var timer = $Timer
var avoiding = false
var blindfolded = false
var prompt_toggled = false
var audio_prompt_stage = 0


func _ready() -> void:
	self.hide()
		
func _input(event):
	# If the player hits any of the movement keys then remove the prompt and proceed to the next round
	if prompt_toggled and timer.is_stopped():
		if event.is_action_pressed("up"):
			$StartGamePrompt.hide()
			toggle_prompt(false)
		elif event.is_action_pressed("down"):
			$StartGamePrompt.hide()
			toggle_prompt(false)
		elif event.is_action_pressed("left"):
			$StartGamePrompt.hide()
			toggle_prompt(false)
		elif event.is_action_pressed("right"):
			$StartGamePrompt.hide()
			toggle_prompt(false)
		audio_prompt_stage = 0
			
func _process(_delta: float) -> void:# 11 -> 14
	if !$Timer.is_stopped() and audio_prompt_stage == 0:
		$RoundFinished.play()
		if blindfolded:
			$Don.show()
			$Doff.hide()
		else:
			$Don.hide()
			$Doff.show()
		audio_prompt_stage += 1
	if $Timer.time_left < 14.0 and audio_prompt_stage == 1:# 9 -> 12
		if blindfolded:
			$BlindfoldOn.play()
		else:
			$BlindfoldOff.play()
		audio_prompt_stage += 1
		
	if $Timer.time_left < 7.0 and audio_prompt_stage == 2: # 7->9
		if avoiding:
			print("Avoiding Round")
			$AvoidingRound.play()
		else:
			print("Chasing Round")
			$ChasingRound.play()
		audio_prompt_stage += 1
	
	if $Timer.time_left < 3.0 and audio_prompt_stage == 3:#3 -> 4
		$StartGamePrompt.show()
		$PressMovementKeys.play()
		audio_prompt_stage += 1
		
func start_round() -> void:
	toggle_prompt(false)
	get_tree().get_root().get_node("World").start_round()

func toggle_prompt(state: bool) -> void:
	prompt_toggled = state
	get_tree().paused = state
	
	if state:
		self.show()
		timer.start()
	else:
		self.hide()

func set_blindfolded(state: bool) -> void:
	blindfolded = state
		
func set_avoiding(state: bool) -> void:
	avoiding = state
