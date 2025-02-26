extends CSGBox3D

@onready var timer = $Timer
@onready var sound_player = $SoundPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	sound_player.play()

func _process(_delta):
	if timer.time_left < 0.1:
		timer.start()
		sound_player.play()
