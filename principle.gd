extends KinematicBody
enum State {
	CHASE,
	SEARCH,
	PATROL,
}

export var speed = 10.0
export var ground_acceleration = 10.0
export var air_acceleration = 6.0
export var chase_to_search_time = 1
export var search_to_patrol_time = 0.5
export var patrol_to_search_time = 2

onready var anim_player = $principle/AnimationPlayer
onready var footstep_player = $FootstepPlayer
onready var lower_state_timer = $LowerState
onready var increase_state_timer = $IncreaseState

const FOOTSTEP = {
	0: preload("res://assets/audio/footsteps/SFX_principal_footstep_1.wav"),
	1: preload("res://assets/audio/footsteps/SFX_principal_footstep_2.wav"),
	2: preload("res://assets/audio/footsteps/SFX_principal_footstep_3.wav"),
	3: preload("res://assets/audio/footsteps/SFX_principal_footstep_4.wav")
}

var last_footstep_index = 0

var sus_meter := 0.0
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

func change_sus_meter(sus_change :float)-> void:
	sus_meter = clamp(sus_meter+sus_change, 0, 100)

func get_target():
	match behaviour:
		State.CHASE:
			change_sus_meter(-4)
			_target = Player
		State.SEARCH:
			var min_dist = 9223372036854775807
			for point in points_of_interest:
				var dist = Player.global_transform.origin.distance_squared_to(point.global_transform.origin)
				if dist < min_dist:
					_target = point
					min_dist = dist
			if min_dist < 2:
				lower_state_timer.stop()
				increase_state_timer.stop()
				if sus_meter > 55:
					change_sus_meter(55-sus_meter)
					behaviour = State.CHASE
				else:
					behaviour = State.SEARCH
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
		_:
			_target = Player

func calc_state():
	match behaviour:
		State.CHASE:
			if sus_meter < 60:
				if lower_state_timer.is_stopped():
					lower_state_timer.start(chase_to_search_time)
			elif not lower_state_timer.is_stopped():
					lower_state_timer.stop()
		State.SEARCH:
			if sus_meter > 60:
				lower_state_timer.stop()
				increase_state_timer.stop()
				behaviour = State.CHASE
		State.PATROL:
			if sus_meter > 50 and increase_state_timer.is_stopped():
				increase_state_timer.start(patrol_to_search_time)

func _on_IncreaseState_timeout():
	lower_state_timer.stop()
	increase_state_timer.stop()
	match behaviour:
		State.CHASE:
			pass
		State.SEARCH:
			behaviour = State.CHASE
		State.PATROL:
			lower_state_timer.start(search_to_patrol_time)
			behaviour = State.SEARCH

func _on_LowerState_timeout():
	lower_state_timer.stop()
	increase_state_timer.stop()
	match behaviour:
		State.CHASE:
			behaviour = State.SEARCH
			lower_state_timer.start(search_to_patrol_time)
		State.SEARCH:
			behaviour = State.PATROL
		State.PATROL:
			pass
			
func _on_MoveTimer_timeout():
	var sus_change = -1
	var dist_to_player = global_transform.origin.distance_to(Player.global_transform.origin)
	if(dist_to_player < 50):
		sus_change += 20/dist_to_player
	sus_change += Player.velocity.length()/9
	change_sus_meter(sus_change)
	print(String(sus_meter) + " " + String(behaviour))
	calc_state()
	get_target()
	move_to(_target.global_transform.origin)

