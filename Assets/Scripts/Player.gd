class_name Player
extends CharacterBody3D

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
var speed_effects = {}

var input_dir: Vector2 = Vector2.ZERO

func _ready():
	globals.player_id = get_instance_id()

func _input(event):	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var rot: Vector2 = Vector2(event.relative.y * rotation_sensitvity * 0.001, -event.relative.x * rotation_sensitvity * 0.001)
		
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x - rot.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		rotate_y(rot.y)
	
	#crouching dragon
	#todo turn into input pair
	
	if event.is_action_pressed("Crouch"):
		speed_effects["crouch_speed_reduction"] = crouch_speed_reduction
		$Camera3D.position.y -=crouch_height_reduction
		$CollisionShape3D.shape.height -=crouch_height_reduction
	elif event.is_action_released("Crouch"):# and !is_on_ceiling():#bug: can double cruch while under something
		speed_effects.erase("crouch_speed_reduction")
		$Camera3D.position.y += crouch_height_reduction		
		$CollisionShape3D.shape.height += crouch_height_reduction
	
	#sprinting tiger
	if !Input.is_action_pressed("Crouch"):
		if event.is_action_pressed("Sprint"):
			speed_effects["sprint_speed_amplification"] = sprint_speed_amplification
	if event.is_action_released("Sprint") or Input.is_action_pressed("Crouch"):
		speed_effects.erase("sprint_speed_amplification")
	
func _physics_process(_delta):	
	input_dir = Vector2(
		-horizontal.get_axis(),
		vertical.get_axis()
	)
	input_dir = input_dir.normalized() if input_dir.length() > 1 else  input_dir
	
	var current_speed: float = speed;

	for effect in speed_effects:
		current_speed *= speed_effects[effect]
	
	var final_input = Vector3(input_dir.x, 0, input_dir.y) * current_speed * transform.basis.inverse()
	
	velocity = final_input + Vector3(0, velocity.y ,0)
	if !is_on_floor():
		velocity.y -= GRAVITY * gravity_scale
	
	elif(Input.is_action_just_pressed("Jump")):
		velocity.y += jump_force
	
	move_and_slide()
