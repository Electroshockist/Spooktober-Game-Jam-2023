class_name Player
extends CharacterBody3D

#Camera controls
@export var rotation_sensitvity: float = 4
@export var min_pitch: = -30
@export var max_pitch = 85

#Movement variables
@export var speed : float = 10
@export var jump_force : float = 150
@export var gravity_scale : float = 1
@onready var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

#Input data
@onready var horizontal : Input_Pair = Input_Pair.new("Move Right", "Move Left")
@onready var vertical : Input_Pair = Input_Pair.new("Move Forward", "Move Backward")

var input_dir: Vector2 = Vector2.ZERO

func _ready():
	globals.player_id = get_instance_id()

func _input(event):	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var rot: Vector2 = Vector2(event.relative.y * rotation_sensitvity * 0.001, -event.relative.x * rotation_sensitvity * 0.001)
		
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x - rot.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		rotate_y(rot.y)

func _physics_process(_delta):
	input_dir = Vector2(
		-horizontal.get_axis(),
		vertical.get_axis()
	)
	input_dir = input_dir.normalized() if input_dir.length() > 1 else  input_dir
	
	var final_input = Vector3(input_dir.x, 0, input_dir.y) * speed * transform.basis.inverse()
	
	velocity = final_input + Vector3(0, velocity.y ,0)
	if !is_on_floor():
		velocity.y -= GRAVITY * gravity_scale
		
	elif(Input.is_action_just_pressed("Jump")):
		velocity.y += jump_force

	move_and_slide()
