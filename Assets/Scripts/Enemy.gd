class_name Enemy
extends CharacterBody3D

const debug:bool = true

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
var noticed_targets:Array = []
var notice_timers:Dictionary = {}
var current_target = null
var timer_container:Node
var player_in_view:bool = false

#Navigation
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

#Callbacks
func _ready():
	init_sight()

func _process(delta):
	update_notice_ui()

func _physics_process(delta):
	state_match(delta)

#Signal Functions
func _on_view_enter(area: Area3D):
	#assumes the area is a direct child of the "master" object
	# and that the Team component has its default name
	var area_team = area.get_parent().find_child("Team")
	
	#assumes target direct parent of area
	var target_id:int = area.get_parent().get_instance_id()
	
	if globals.player_id == target_id:
		if debug: print("Entity[", self.get_instance_id(), "]: Player entered view")
		player_in_view = true
	
	if not team.same_team(area_team):
		if targets.has(target_id):
			notice_timers[target_id].set_count_direction(EntityTimer.COUNTING.DOWN)
		else:
			add_target(target_id)
	else: # same team
		pass #todo

func _on_view_exit(area: Area3D):
	#assumes master node is direct parent
	var target_id = area.get_parent().get_instance_id()
	
	if target_id == globals.player_id:
		player_in_view = false
	
	if targets.has(target_id):
		if not notice_timers[target_id].stopped:
			notice_timers[target_id].set_count_direction(EntityTimer.COUNTING.UP)
		else:
			notice_timers[target_id].count_up()



#functions

#state functions
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

#Sight functions

func init_sight():
	if(sight != null):
		can_see = true	#default is false
		sight.connect("frustum_area_enter", _on_view_enter)
		sight.connect("frustum_area_exit", _on_view_exit)
	
	timer_container = Node.new()
	add_child(timer_container)


#Targeting functions
func add_target(id:int):
	targets.push_back(id)
	var notice_timer:EntityTimer = EntityTimer.new(id, notice_speed, true, true)
	timer_container.add_child(notice_timer)
	notice_timer.connect("timeout", _alert_on)
	notice_timer.connect("refill", _forget_target)
	notice_timers.merge({id: notice_timer})
	
func _forget_target(id:int):
	targets.erase(id)
	notice_timers[id].stop()
	notice_timers[id].queue_free()
	notice_timers.erase(id)
	noticed_targets.erase(id)
	update_current_target()
	
	if debug:
		if id == globals.player_id: 
			print("Entity[", self.get_instance_id(), "]: Player was forgotten")
		else:
			print("Entity[", self.get_instance_id(), "]: Entity[", id, "] was forgotten")

func _alert_on(id:int):
	noticed_targets.append(id)
	update_current_target()
	if id == globals.player_id:
		if debug: print("Entity[", self.get_instance_id(), "]: Player was noticed")

func update_notice_ui():
	if notice_ui: #if enemy has notice_ui
		var player_id = globals.player_id
		if targets.has(player_id):
			if notice_timers[player_id] and notice_timers[player_id].running:
				notice_ui.text = str(snapped(notice_timers[globals.player_id].time_left, 0.01))
			elif noticed_targets.has(player_id) and player_in_view:
				notice_ui.text = "!"
			else: notice_ui.text = ""
		else:
			notice_ui.text = ""

func update_current_target():
	if noticed_targets.size() > 0:
		current_target = noticed_targets[0]
	else:
		current_target = null

#func print_target_data():
#	prints("Targets:", targets)
#	print_notice_timers()
#	prints("Current Target:", current_target)
#
#func print_notice_timers():
#	var msg:String = ""
#	for key in notice_timers:
#		msg += str(key, ": ", notice_timers[key].time_left, ", ")
#	msg += "}"
#	print("Target Notice Timers: { ", msg, "}")
