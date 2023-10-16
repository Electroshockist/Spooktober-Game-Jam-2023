extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if(event.is_action_pressed("Menu")):	
		invert_mouse_capture()

func invert_mouse_capture():
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:	
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
