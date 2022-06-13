extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var batanimation = $AnimationPlayer
var swingonestate = true  

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
