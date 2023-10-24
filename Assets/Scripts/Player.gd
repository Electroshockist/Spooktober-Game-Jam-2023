class_name Player
extends CharacterBody3D

@export var debug:bool = false

#Camera controls
@export var rotation_sensitvity: float = 4
@export var min_pitch: = -85
@export var max_pitch = 85

#Movement variables
@export var speed : float = 10

@export var crouch_height_reduction: float = .5
@export var crouch_speed_reduction: float = 0.7
@export var sprint_speed_amplification: float = 1.3


@export var jump_force : float = 25
@export var gravity_scale : float = 0.1
@onready var GRAVITY : float = ProjectSettings.get_setting("physics/3d/default_gravity")

#Input data
@onready var horizontal : Input_Pair = Input_Pair.new("Move Right", "Move Left")
@onready var vertical : Input_Pair = Input_Pair.new("Move Forward", "Move Backward")

#private variables
var _input_dir: Vector2 = Vector2.ZERO

var _current_speed: float = speed

var _full_body_is_on_ceiling: bool = false

enum {
	NONE,
	CROUCH,
	SPRINT
} 
var _motion_type = NONE

func _ready():
	globals.player_id = get_instance_id()

func _input(event):	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var rot: Vector2 = Vector2(event.relative.y * rotation_sensitvity * 0.001, -event.relative.x * rotation_sensitvity * 0.001)
		
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x - rot.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		rotate_y(rot.y)
	
	_handle_movement_modifiers(event)
	
		
func _physics_process(_delta):
		
	if(_motion_type == CROUCH and !_full_body_is_on_ceiling and !Input.is_action_pressed("Crouch")):
		_on_crouch_deactivate()
		if Input.is_action_pressed("Sprint"):
			_on_sprint_activte()
	
	var input_dir = Vector2(-horizontal.get_axis(),vertical.get_axis())
	input_dir = input_dir.normalized() if input_dir.length() > 1 else  input_dir
	
	var final_input = Vector3(input_dir.x, 0, input_dir.y) * _current_speed * transform.basis.inverse()
	
	velocity = final_input + Vector3(0, velocity.y ,0)
	if !is_on_floor():
		velocity.y -= GRAVITY * gravity_scale
	
	elif(Input.is_action_just_pressed("Jump")):
		velocity.y += jump_force
	
	if debug: print(_current_speed)
	move_and_slide()


func _on_crouch_activate():
	_motion_type = CROUCH
	
	$Camera3D.position.y -=crouch_height_reduction
	$CollisionShape3D.shape.height -=crouch_height_reduction
	$VisibleArea/CollisionShape3D.shape.height -= crouch_height_reduction		
	
func _on_crouch_deactivate():
	$Camera3D.position.y += crouch_height_reduction
	$CollisionShape3D.shape.height += crouch_height_reduction
	$VisibleArea/CollisionShape3D.shape.height += crouch_height_reduction 
	_motion_type = NONE

func _on_sprint_activte():
	_motion_type = SPRINT
	
func _on_sprint_deactivate():
	_motion_type = NONE
			
func _handle_movement_modifiers(event):
	##todo turn into generalized stack			
	#crouching dragon
	if event.is_action_pressed("Crouch"):
		if _motion_type == SPRINT:
			_on_sprint_deactivate()
		_on_crouch_activate()
		
	elif event.is_action_released("Crouch") and !_full_body_is_on_ceiling:
		_on_crouch_deactivate()
		if Input.is_action_pressed("Sprint"):
			_on_sprint_activte()
		
	
	#sprinting tiger
	if event.is_action_pressed("Sprint"):
		if(_motion_type == CROUCH):
			if(!_full_body_is_on_ceiling):
				_on_crouch_deactivate()
				_on_sprint_activte()
		else:
			_on_sprint_activte()

	if event.is_action_released("Sprint"):
		_on_sprint_deactivate()
		
		if Input.is_action_pressed("Crouch"):
			_on_crouch_activate()
		
	match _motion_type:
		NONE:
			_current_speed = speed
		CROUCH:
			_current_speed = speed * crouch_speed_reduction
		SPRINT:
			_current_speed = speed * sprint_speed_amplification

func _on_head_collision_detector_body_entered(body):
	print("body entered")
	_full_body_is_on_ceiling = true


func _on_head_collision_detector_body_exited(_body):
	print("body exited")
	_full_body_is_on_ceiling = false
