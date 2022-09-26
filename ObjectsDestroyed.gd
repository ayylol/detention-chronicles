extends Label
signal wincondition

export(NodePath) var nodee_path

onready var PropsNode = get_node(nodee_path)
onready var childCount = PropsNode.get_child_count()-1

func _ready():
	text = "Objects to Destroy: "+str(childCount)
	
func on_objectDestroyed():
	childCount = childCount-1
	text = "Objects to Destroy: "+str(childCount)
	if childCount == 0:
		emit_signal("wincondition")		
