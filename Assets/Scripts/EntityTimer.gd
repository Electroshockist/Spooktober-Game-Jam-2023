class_name EntityTimer
extends Timer

signal timeout_parent_id(id:int)

var id:int

func _ready():
	self.connect("timeout", on_timeout)


func on_timeout():
	# assumes 
	#	Enemy(id we want)
	#		    | (is a child of)
	#	  timer_container
	#		    |
	#		  Timer (self)
	timeout_parent_id.emit(id)
