extends Spatial

onready var note_timer = $NoteTimer
onready var music_player1 = $MusicPlayer1
onready var music_player2 = $MusicPlayer2
onready var fade_in = $FadeIn
onready var fade_out = $FadeOut

const MUSIC = preload("res://assets/audio/music/E2.wav")

var is_first_player = true
var fade_in_dur = 8
var fade_out_dur = 7

func _ready():
	music_player1.set_stream(MUSIC)
	music_player2.set_stream(MUSIC)
	music_player1.play()
	note_timer.start()
	
func _on_NoteTimer_timeout():
	note_timer.start()
	
	if is_first_player:
		music_player2.set_pitch_scale(rand_range(0.75, 1.5))
		music_player2.play(randi() % 10)
		
		fade_in_note(music_player2)
		fade_out_note(music_player1)
		
		is_first_player = not is_first_player
		
	else:
		music_player1.set_pitch_scale(rand_range(0.75, 1.5))
		music_player1.play(randi() % 10)
		
		fade_in_note(music_player1)
		fade_out_note(music_player2)
		
		is_first_player = not is_first_player

func fade_in_note(music_player):
	fade_in.interpolate_property(music_player, "volume_db", -80, 0, fade_in_dur, 5, Tween.EASE_OUT, 0)
	fade_in.start()
	
func fade_out_note(music_player):
	fade_out.interpolate_property(music_player, "volume_db", 0, -80, fade_out_dur, 5, Tween.EASE_IN, 0)
	fade_out.start()
