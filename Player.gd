extends KinematicBody

export var speed = 10.0
export var ground_acceleration = 10.0
export var air_acceleration = 6.0
export var jump = 5
export var gravity = 9.81 # Eventually make global
export var mouse_sensitivity = 0.5

var fall = 0
var velocity = Vector3()

var acceleration
var forward_or_backward = 0
var left_or_right = 0

onready var head = $Head

var _reset_fb = false
var _reset_lr = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		fall = jump if Input.is_action_pressed("jump") else 0
	else:
		acceleration = air_acceleration
	fall -= gravity * delta
		
	velocity = velocity.linear_interpolate(get_direction() * speed, acceleration * delta)
	velocity = move_and_slide(velocity + (Vector3.UP * fall), Vector3.UP)
	velocity.y = 0