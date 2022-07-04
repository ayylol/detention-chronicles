extends KinematicBody
enum State {
	SEARCH,
	CHASE,
	PATROL,
}

export var speed = 10.0
export var ground_acceleration = 10.0
export var air_acceleration = 6.0
onready var anim_player = $principle/AnimationPlayer
onready var footstep_player = $FootstepPlayer

const FOOTSTEP = {
	0: preload("res://assets/audio/footsteps/SFX_principal_footstep_1.wav"),
	1: preload("res://assets/audio/footsteps/SFX_principal_footstep_2.wav"),
	2: preload("res://assets/audio/footsteps/SFX_principal_footstep_3.wav"),
	3: preload("res://assets/audio/footsteps/SFX_principal_footstep_4.wav")
}

var last_footstep_index = 0

var behaviour = State.PATROL
var path = []
var path_node = 0
var max_speed = 8.0
var gravity = Vector3.DOWN * 9.81
var points_of_interest = []
var _target_index
var _target

onready var nav = get_parent()
onready var Player = $"../../Player"

onready var current_speed = max_speed

func _ready():	
	for point in $"../NavMesh/PointsOfInterest".get_children():
		points_of_interest.push_back(point)
	anim_player.play("walk")

func _physics_process(delta):
	#print(global_transform.origin)
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		direction.y = 0
		if direction.length() < 1:
			path_node += 1
		else:
			direction = direction.normalized()
			var look_dir = lerp(-global_transform.basis.z, direction, delta*10)
			look_dir.y = global_transform.origin.y
			look_at(global_transform.origin+look_dir, Vector3.UP)
			move_and_slide(direction * current_speed + gravity, Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

# plays a random footstep with a random playback rate
func play_footstep():
	var footstep_index = randi() % FOOTSTEP.size()
	if footstep_index == last_footstep_index:
		footstep_index = (footstep_index + 1) % FOOTSTEP.size()
	
	footstep_player.set_stream(FOOTSTEP[footstep_index])
	footstep_player.set_pitch_scale(rand_range(0.8, 1.2))
	footstep_player.play()
	
	last_footstep_index = footstep_index

func get_target():
	match behaviour:
		State.CHASE:
			_target = Player
		State.PATROL:
			if(not _target in points_of_interest):
				var min_dist = 9223372036854775807
				var i = 0
				for point in points_of_interest:
					var dist = global_transform.origin.distance_squared_to(point.global_transform.origin)
					if dist < min_dist:
						_target_index = i
						_target = point
						min_dist = dist
					i+=1
			else:
				if global_transform.origin.distance_squared_to(
					Vector3(_target.global_transform.origin.x, 
							global_transform.origin.y, 
							_target.global_transform.origin.z)) < 2:
					_target_index = (_target_index+1) % points_of_interest.size()
					_target = points_of_interest[_target_index]
		State.SEARCH:
			var min_dist = 9223372036854775807
			for point in points_of_interest:
				var dist = Player.global_transform.origin.distance_squared_to(point.global_transform.origin)
				if dist < min_dist:
					_target = point
					min_dist = dist
		_:
			_target = Player

func _on_MoveTimer_timeout():
	get_target()
	move_to(_target.global_transform.origin)
