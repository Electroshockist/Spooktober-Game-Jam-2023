class_name Enemy
extends CharacterBody3D

const debug:bool = false

# State Management
@export var init_state: State = State.GUARD
enum State{
	SEARCH,
	WANDER,
	GUARD,
	PATROL,
	CHASE}
var state: State = init_state

@onready var team: Team = $Team

# Sight Management
@onready var sight: Sight = $Sight
var can_see: bool = false
#var is_blinded: bool = false

#Targeting
@onready var notice_ui: Label3D = $Label3D
const notice_speed:float = 5
var targets:Array = []
var notice_timers:Dictionary = {}
var current_target = null
var timer_container: Node
var can_see_player:bool= false

#Navigation
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

#Callbacks
func _ready():
	init_sight()

func _process(delta):
	if notice_ui: #if enemy has notice_ui
		if can_see_player: #if player is in sights
			if current_target and current_target == PlayerInfo.id:
				notice_ui.text = "!"
			else:
				notice_ui.text = str(snapped(notice_timers[PlayerInfo.id].get_time_left(), 0.01))
		else:
			notice_ui.text = str(0)

func _physics_process(delta):
	state_match(delta)

#Signal Functions
func _on_frustum_area_enter(area: Area3D):
	#assumes the area is a direct child of the "master" object
	# and that the Team component has its default name
	var area_team = area.get_parent().find_child("Team")
	if !team.same_team(area_team):
		
		#assumes player in scene
		var target_id:int = area.get_parent().get_instance_id()
		
		if PlayerInfo.id == target_id:
			can_see_player = true
			if debug: print("player entered view")
		
		targets.push_back(target_id)
		var notice_timer:EntityTimer = EntityTimer.new()
		notice_timer.wait_time = notice_speed
		notice_timer.one_shot = true
		notice_timer.autostart = true
		notice_timer.id = target_id
		
		timer_container.add_child(notice_timer)
		notice_timer.connect("timeout_parent_id", on_notice_timer_timeout)
		
		notice_timers.merge({target_id: notice_timer})
	else: # same team
		pass #todo

func _on_frustum_area_exit(area: Area3D):
	#assumes master node is direct parent
	var true_player_id = PlayerInfo.id
	var target_id = area.get_parent().get_instance_id()
	
	if true_player_id == target_id:
		can_see_player = false
		if debug: print("player was forgotten")
	
	if targets.has(target_id):
		targets.erase(target_id)
		notice_timers[target_id].stop()
		notice_timers[target_id].queue_free()
		notice_timers.erase(target_id)
		update_current_target()

func on_notice_timer_timeout(id:int):
	if can_see_player and id == PlayerInfo.id:
		if debug: print("player was noticed")
		update_current_target()

#functions
func state_match(delta):
	all_states(delta)
	match state:
		State.GUARD:
			guard(delta)
		_:
			pass

func all_states(delta):
	pass

func guard(delta):
	pass

func init_sight():
	if(sight != null):
		can_see = true	#default is false
		sight.connect("frustum_area_enter", _on_frustum_area_enter)
		sight.connect("frustum_area_exit", _on_frustum_area_exit)
	
	timer_container = Node.new()
	add_child(timer_container)

func start_notice_target():
	pass

func update_current_target():
	if targets.size() > 0:
		current_target = targets[0]
	else:
		current_target = null

func print_target_data():
	prints("Targets:", targets)
	print_notice_timers()
	prints("Current Target:", current_target)
	
func print_notice_timers():
	var msg:String = ""
	for key in notice_timers:
		msg += str(key, ": ", notice_timers[key].time_left, ", ")
	msg += "}"
	print("Target Notice Timers: { ", msg, "}")
