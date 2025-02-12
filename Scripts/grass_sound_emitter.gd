extends Area3D

@onready var grass_sound = $"GrassSoundPlayer"
@onready var grass_sound_npc = AudioStreamPlayer3D.new()
@onready var sound_player_dictionary = {"Player": grass_sound, "NPC Chasing": grass_sound_npc, "NPC Avoiding": grass_sound_npc}
@onready var overlapping_bodies = get_overlapping_bodies()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grass_sound_npc.set_stream(load("res://Sounds/grass.wav"))
	grass_sound_npc.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
	grass_sound_npc.volume_db = 2.5
	grass_sound_npc.max_distance = 40
	
	add_child(grass_sound_npc)

func _process(_delta):
	var new_overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
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

		
