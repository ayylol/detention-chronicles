extends Label


export(NodePath) var nodee_path

onready var anotherPropsNode = get_node(nodee_path)
onready var childCount = anotherPropsNode.get_child_count()

func objectCounter():
	text = "Objects to Destroy: "+str(childCount)
