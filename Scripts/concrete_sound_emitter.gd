extends Area3D

@onready var concrete_sound = $"ConcreteSoundPlayer"
@onready var concrete_sound_npc = AudioStreamPlayer3D.new()
@onready var sound_player_dictionary = {"Player": concrete_sound, "NPCChasing": concrete_sound_npc, "NPCAvoiding": concrete_sound_npc}
@onready var overlapping_bodies = get_overlapping_bodies()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	concrete_sound_npc.set_stream(load("res://Sounds/concrete.wav"))
	concrete_sound_npc.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
	concrete_sound_npc.volume_db = 3.5
	concrete_sound_npc.max_distance = 40

	add_child(concrete_sound_npc)

func _process(_delta):
	var new_overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		# Get the AudioStreamPlayer3D appropriate for the body, need three emitters for possibility of all NPCs
		var current_sound = sound_player_dictionary[body.name]
		if (new_overlapping_bodies.find(body) == -1):
			current_sound.stop()
		else:
			if (body.velocity.length() > 0):
				current_sound.pitch_scale = randf() * 0.2 + 0.9 #This random pitch change is supposed to make it more realistic
				current_sound.global_position = body.global_position
				current_sound.global_position.y -= 0.5
				if(current_sound.playing == false):
					current_sound.play()

			elif (current_sound.playing == true):
				current_sound.stop()
				
	overlapping_bodies = get_overlapping_bodies()
