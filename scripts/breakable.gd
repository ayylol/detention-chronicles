extends RigidBody

var normalstate 
var brokencondition = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$normal.visible = true
	$broken.visible = false
	
func break():
	if brokencondition == false: 
		$normal.visible = false
		$broken.visible = true
		brokencondition = true
	else:
		queue_free()		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
