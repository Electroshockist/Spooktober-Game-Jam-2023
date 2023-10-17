extends Node

class_name Input_Pair

@export var negative_input_name: String
@export var positive_input_name: String

var calculated_input: float = 0.0

var active_dir:int = 0
	
func _physics_process(_delta):
	var input_pair_name = [negative_input_name, positive_input_name]
	if Input.is_action_just_pressed(input_pair_name[(int)(!active_dir)]) :
		active_dir = !active_dir
	
	elif Input.is_action_just_released(input_pair_name[(int)(active_dir)]) && Input.is_action_pressed(input_pair_name[(int)(!active_dir)]):
		active_dir = !active_dir
		
	calculated_input = Input.get_action_strength(input_pair_name[active_dir]) * ((active_dir * 2) -1 )
