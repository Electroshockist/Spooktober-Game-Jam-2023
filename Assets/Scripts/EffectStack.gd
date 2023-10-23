class_name Effect_Stack
extends Node

var _input_list = []
var _active_input_stack = []

func _init(inputs):
	_input_list = inputs

func push_input(name: String):
	_input_list.push_back(name)
	
func erase_input(name: String):
	_input_list.erase(name)

func get_axis():
	for input in _input_list:
		if Input.is_action_pressed(input) and !_active_input_stack.has(input):
			_active_input_stack.push_front(input)
	
	for input in _active_input_stack:
		if Input.is_action_just_released(input):
			_active_input_stack.erase(input)
			
	if _active_input_stack.size() == 0:
		return ""
	return _active_input_stack[0]
