extends KinematicBody

# audio-related stuff - begin
onready var bat_object = $Head/Camera/bat
onready var footstep_timer = $FootstepTimer
onready var footstep_player = $FootstepPlayer
onready var bat_collision = $Head/BatHitbox/CollisionShape;
var swingingstate =  true;
var last_footstep_index = 0

const FOOTSTEP = {
	0: preload("res://assets/audio/footsteps/SFX_player_footstep_1.wav"),
	1: preload("res://assets/audio/footsteps/SFX_player_footstep_2.wav")
}

# audio-related stuff - end

export var speed = 10.0
export var ground_acceleration = 10.0
export var air_acceleration = 6.0
export var jump = 5
export var mouse_sensitivity = 0.5

var fall = 0
var velocity = Vector3()

var acceleration
var forward_or_backward = 0
var left_or_right = 0

onready var principle = $"../Nav/Principle"
onready var head = $Head

var _reset_fb = false
var _reset_lr = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	bat_collision.disabled = true

func _input(event):
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func get_direction():
	# stopping movement
	if _reset_fb and is_on_floor():
		forward_or_backward = 0
		_reset_fb = false
	if _reset_lr and is_on_floor():
		left_or_right = 0
		_reset_lr = false
	
	if ((Input.is_action_just_released("forwards_movement") and forward_or_backward==-1) 
		or (Input.is_action_just_released("backwards_movement") and forward_or_backward==1)):
		if Input.is_action_pressed("forwards_movement"):
			forward_or_backward = -1
		elif Input.is_action_pressed("backwards_movement"):
			forward_or_backward=1
		elif is_on_floor():
			forward_or_backward=0
		else:
			_reset_fb = true
	if ((Input.is_action_just_released("right_movement") and left_or_right==1) 
		or (Input.is_action_just_released("left_movement") and left_or_right==-1)):
		if Input.is_action_pressed("left_movement"):
			left_or_right = -1
		elif Input.is_action_pressed("right_movement"):
			left_or_right=1
		elif is_on_floor():
			left_or_right=0
		else:
			_reset_lr = true
	
	# Initiating movement
	if Input.is_action_just_pressed("backwards_movement"):
		forward_or_backward = 1
		_reset_fb = false
	if Input.is_action_just_pressed("forwards_movement"):
		forward_or_backward = -1
		_reset_fb = false
	if Input.is_action_just_pressed("left_movement"):
		left_or_right = -1
		_reset_lr = false
	if Input.is_action_just_pressed("right_movement"):
		left_or_right = 1
		_reset_lr = false
		
	# Override if clicked off screen
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		forward_or_backward = 0
		left_or_right = 0
	
	# Calculating direction
	return (forward_or_backward * transform.basis.z + left_or_right * transform.basis.x).normalized()
	

func _physics_process(delta):
	# Capture/Uncapture mouse
	if((Input.is_action_just_pressed("escape"))):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if((Input.is_action_just_pressed("hit")) and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# movement
	if is_on_floor():
		acceleration = ground_acceleration
		fall = jump if (Input.is_action_pressed("jump") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED) else 0
	else:
		acceleration = air_acceleration
	fall -= Global.gravity * delta
		
	velocity = velocity.linear_interpolate(get_direction() * speed, acceleration * delta)
	velocity = move_and_slide(velocity + (Vector3.UP * fall), Vector3.UP)
	velocity.y = 0

func play_footstep():
	var footstep_index = randi() % FOOTSTEP.size()
	if footstep_index == last_footstep_index:
		footstep_index = (footstep_index + 1) % FOOTSTEP.size()
	
	footstep_player.set_stream(FOOTSTEP[footstep_index])
	footstep_player.set_pitch_scale(rand_range(0.8, 1.2))
	footstep_player.play()
	
	last_footstep_index = footstep_index


func _on_FootstepTimer_timeout():
	if is_on_floor():
		if not forward_or_backward == 0 or not left_or_right == 0:
			play_footstep()


func _on_bat_hitbox_off():
		bat_collision.disabled = true

func _on_bat_hitbox_on():
	principle.change_sus_meter(2)
	bat_collision.disabled = false

func _on_BatHitbox_body_entered(body):
	
	#Will switch states to alternate the direction of the object that is hit, hence why the swingstate variable changes from true to false.

	var aim = $Head.get_global_transform().basis;	
	var forward = -aim.z
	var backward = aim.z
	var up = aim.y 
	var down = -aim.y
	var left = -aim.x
	var right = aim.x
	
	var left_launch_direction = left + forward + up*.35 

	var right_launch_direction = right + forward + up*.35
	
	if body.has_method("add_central_force") and not bat_object.is_first_swing:
		body.add_central_force(left_launch_direction*1000)
		
	elif body.has_method("add_central_force") and bat_object.is_first_swing:
		body.add_central_force(right_launch_direction*1000)

	if body.has_method("break"):	
		body.break()
	

