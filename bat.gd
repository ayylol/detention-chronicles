extends Spatial


var currently_swinging = false

onready var batanimation = $AnimationPlayer
var swingonestate = true  

# Called when the node enters the scene tree for the first time.
func _input(event):
	if not currently_swinging:
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


func _on_AnimationPlayer_animation_started(anim_name):
	currently_swinging = true
	$Timer.start(0.25)

func _on_Timer_timeout():
	currently_swinging = false
