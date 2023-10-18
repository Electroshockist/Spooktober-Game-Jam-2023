class_name Enemy
extends CharacterBody3D

const debug:bool = false

# State Management
enum State{
	SEARCH,
	WANDER,
	GUARD,
	PATROL,
	CHASE
}
@export var init_state: State = State.GUARD
var state: State = init_state

@onready var team: Team = $Team

# Sight Management
@onready var sight: Sight = $Sight
var can_see: bool = false

#Targeting
var targets:Array = []
var current_target = null

#Callbacks
func _ready():
	if(sight != null):
		can_see = true	
		sight.connect("frustum_area_enter", _on_frustum_area_enter)
		sight.connect("frustum_area_exit", _on_frustum_area_exit)

func _physics_process(delta):
	state_match(delta)

#Signal Functions
func _on_frustum_area_enter(area: Area3D):
	#assumes the area is a direct child of the "master" object
	var area_team = area.get_parent().find_child("Team")
	if !team.same_team(area_team):
		var target_id = area.get_parent().get_instance_id()
		targets.push_back(target_id)
		update_current_target()
	if debug: print_target_data()

func _on_frustum_area_exit(area: Area3D):
	var target_id = area.get_parent().get_instance_id()
	if targets.has(target_id):
		targets.erase(target_id)
		update_current_target()
	if debug: print_target_data()

#functions
func state_match(delta):
	match state:
		State.GUARD:
			guard(delta)
		_:
			pass

func guard(delta):
	pass

func update_current_target():
	if targets.size() > 0:
		self.current_target = targets[0]
	else:
		self.current_target = null

func print_target_data():
	prints("Targets:", self.targets)
	prints("Current Target:", self.current_target)
