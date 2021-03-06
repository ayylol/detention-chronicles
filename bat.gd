extends Spatial

signal hitbox_on
signal hitbox_off

var currently_swinging = false

onready var batanimation = $AnimationPlayer
var is_first_swing = true


# audio-related stuff - begin

onready var bat_swing_player = $BatSwingPlayer

const BAT_SWING = {
	0: preload("res://assets/audio/SFX_bat_swing_L-R.wav"),
	1: preload("res://assets/audio/SFX_bat_swing_R-L.wav")
}

# audio-related stuff - end

# Called when the node enters the scene tree for the first time.
func _input(event):
	if not currently_swinging and event.is_action_pressed('hit'):
		if is_first_swing:
			batanimation.play("swing 1")
		else:
			batanimation.play("swing 2")
		is_first_swing = not is_first_swing


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
	
func hitbox_on():
	emit_signal("hitbox_on")
func hitbox_off():
	emit_signal("hitbox_off")

func _on_AnimationPlayer_animation_started(anim_name):
	currently_swinging = true
	$Timer.start(0.4)

func _on_Timer_timeout():
	currently_swinging = false
