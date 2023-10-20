class_name Input_Pair
extends Node

var negative_input_name: String
var positive_input_name: String

var active_dir:int = 0

func _init(pos_in: String, neg_in: String):
	positive_input_name = pos_in
	negative_input_name = neg_in

func get_axis() -> float:
	var input_pair_name = [negative_input_name, positive_input_name]
	if Input.is_action_just_pressed(input_pair_name[(int)(!active_dir)]) or Input.is_action_just_released(input_pair_name[(int)(active_dir)]) && Input.is_action_pressed(input_pair_name[(int)(!active_dir)]):
		active_dir = !active_dir
		
	return Input.get_action_strength(input_pair_name[active_dir]) * ((active_dir * 2) -1 )
