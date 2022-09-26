extends RigidBody

var normalstate 
var brokencondition = false
signal objectCounter
export(NodePath) var node_path

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	$normal.visible = true
	$broken.visible = false
	var labelNode = get_node("../ObjectsDestroyed")
	self.connect("objectCounter", labelNode, "on_objectDestroyed")
	
func break():
	if brokencondition == false: 
		$normal.visible = false
		$broken.visible = true
		brokencondition = true
	else:
		queue_free()
		emit_signal("objectCounter")
		
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
