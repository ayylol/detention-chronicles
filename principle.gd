extends KinematicBody
enum State {
	SEARCHING,
	CHASING,
}
export var speed = 10.0
export var ground_acceleration = 10.0
export var air_acceleration = 6.0

var path = []
var path_node = 0
var max_speed = 8.0
var points_of_interest = []
var _target

onready var anim_player = $principle/AnimationPlayer
onready var nav = get_parent()
onready var Player = $"../../Player"

onready var current_speed = max_speed

func _ready():	
	for point in $"../NavMesh/PointsOfInterest".get_children():
		points_of_interest.push_back(point)
		
	#_target = points_of_interest[0]
	_target = Player # start moving towards player
	anim_player.play("walk")

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * current_speed, Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	look_at_from_position(global_transform.origin, Vector3(target_pos.x, global_transform.origin.y, target_pos.z), Vector3.UP)
	path_node = 0

func _on_MoveTimer_timeout():
	move_to(_target.global_transform.origin)
