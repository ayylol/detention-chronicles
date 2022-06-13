extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var batanimation = $AnimationPlayer
var swingonestate = true  


# audio-related stuff - begin

onready var bat_swing_player = $BatSwingPlayer

const BAT_SWING = {
	0: preload("res://assets/audio/SFX_bat_swing_R-L.wav"),
	1: preload("res://assets/audio/SFX_bat_swing_L-R.wav")
}

# audio-related stuff - end

# Called when the node enters the scene tree for the first time.
func _input(event):

	if swingonestate == true:
		if event.is_action_pressed('hit'): 
			batanimation.play("swing 1")
			swingonestate = false
	else:
		if event.is_action_pressed('hit'): 
			batanimation.play("swing 2")
			swingonestate = true
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# plays left to right bat swing with a random playback rate
func play_bat_swing_LtoR():
	bat_swing_player.set_stream(BAT_SWING[0])
	bat_swing_player.set_pitch_scale(rand_range(0.9, 1.1))
	bat_swing_player.play()
	
func play_bat_swing_RtoL():
	bat_swing_player.set_stream(BAT_SWING[1])
	bat_swing_player.set_pitch_scale(rand_range(0.9, 1.1))
	bat_swing_player.play()
