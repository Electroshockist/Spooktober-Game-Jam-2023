extends CharacterBody3D

@export var speed : float = 100
@export var rotation_sensitvity: float = 1

var horizontal : Input_Pair
var vertical : Input_Pair

var input_dir: Vector3 = Vector3.ZERO

func _ready():
	horizontal = $Horizontal
	vertical = $Vertical

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:		
		self.rotate_y(-event.relative.x * rotation_sensitvity * get_process_delta_time())

func _physics_process(_delta):
	input_dir = Vector3(
			horizontal.calculated_input,
			0,
			vertical.calculated_input
		)
	input_dir = input_dir.normalized() if input_dir.length() > 1 else  input_dir
	
	velocity =  input_dir * speed * transform.basis.inverse()

	move_and_slide()
