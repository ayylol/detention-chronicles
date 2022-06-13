extends KinematicBody
enum State {
	SEARCHING,
	CHASING,
}
onready var anim_player = $principle/AnimationPlayer
onready var footstep_player = $FootstepPlayer

const FOOTSTEP = {
	0: preload("res://assets/audio/footsteps/SFX_principal_footstep_1.wav"),
	1: preload("res://assets/audio/footsteps/SFX_principal_footstep_2.wav"),
	2: preload("res://assets/audio/footsteps/SFX_principal_footstep_3.wav"),
	3: preload("res://assets/audio/footsteps/SFX_principal_footstep_4.wav")
}

var last_footstep_index = 0

func _ready():
	#for anim in anim_player.get_animation_list():
	#	anim_player.get_animation(anim).set_loop(true)
	anim_player.play("walk")

func _physics_process(delta):
	pass
	#move_and_slide(Vector3(0,0,-5))


# plays a random footstep with a random playback rate
func play_footstep():
	var footstep_index = randi() % FOOTSTEP.size()
	if footstep_index == last_footstep_index:
		footstep_index = (footstep_index + 1) % FOOTSTEP.size()
	
	footstep_player.set_stream(FOOTSTEP[footstep_index])
	footstep_player.set_pitch_scale(rand_range(0.8, 1.2))
	footstep_player.play()
	
	last_footstep_index = footstep_index
