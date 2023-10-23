class_name Enemy
extends CharacterBody3D

@export var debug:bool = false

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
@export var notice_speed:float = 2.5
var targets:Array = []
var noticed_targets:Array = []
var notice_timers:Dictionary = {}
var current_target_id = null
var timer_container:Node
var player_in_view:bool = false

#Navigation
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

#Locomotion
@onready var GRAVITY : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var gravity_scale = 1
@export var speed:float = 2
@export var lateral_drag:float = 0.2
@export var terminal_velocity:float = 10
@export var speed_deadzone:float = 0.05

#Callbacks
func _ready():
	init_sight()

func _process(delta):
	update_notice_ui()

func _physics_process(delta):
	state_match(delta)

func _on_view_enter(area: Area3D):
	# assumes that the Team component has its default name
	var area_team = area.get_owner().find_child("Team")
	
	var target_id:int = area.get_owner().get_instance_id()
	
	if globals.player_id == target_id:
		if debug: print("Entity[", self.get_instance_id(), "]: Player entered view")
		player_in_view = true
	
	if not team.same_team(area_team):
		if targets.has(target_id):
			notice_timers[target_id].set_count_direction(EntityTimer.Direction.DOWN)
		else:
			add_target(target_id)
			notice_timers[target_id].start()
	else: # same team
		pass #todo

func _on_view_exit(area: Area3D):
	var target_id = area.get_owner().get_instance_id()
	
	if target_id == globals.player_id:
		player_in_view = false
	
	if targets.has(target_id):
		
		if target_id == current_target_id:
			current_target_id = null
		
		if not notice_timers[target_id].stopped:
			notice_timers[target_id].set_count_direction(EntityTimer.Direction.UP)
		else:
			notice_timers[target_id].count_up()

#functions

#state functions
func state_match(delta):
	match state:
		State.GUARD:
			guard(delta)
		State.CHASE:
			chase(delta)
		_:
			pass
	all_states(delta)

func all_states(delta):
	var next_pos = nav_agent.get_next_path_position()
	var look_pos = next_pos
	look_pos.y = global_position.y
	
	if !nav_agent.is_target_reached():
		var dir = (next_pos - global_position).normalized()
		velocity.x = dir.x*speed
		velocity.z = dir.z*speed
	else:
		velocity.x = 0
		velocity.z = 0

	#gravity
#	if not is_on_floor():
#		velocity.y -= GRAVITY * gravity_scale
	
	if look_pos != global_position:
		look_at(look_pos, Vector3.UP, true)
	
	#clamp velocity
	var unclamped_speed = velocity.length()
	if unclamped_speed > terminal_velocity:
		velocity *= terminal_velocity/unclamped_speed
	elif unclamped_speed < speed_deadzone:
		velocity = Vector3.ZERO
	
	#move
	move_and_slide()

func guard(delta):
	if current_target_id == null:
		pass
	else:
		state = State.CHASE

func chase(delta):
	if current_target_id != null:
		nav_agent.target_position = instance_from_id(current_target_id).global_position
	else:
		state = State.GUARD

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
	var notice_timer:EntityTimer = EntityTimer.new(id, notice_speed, EntityTimer.RepeatMode.ONE_SHOT)
	timer_container.add_child(notice_timer)
	notice_timer.connect("timeout", _alert_on)
	notice_timer.connect("refill", _forget_target)
	notice_timers.merge({id: notice_timer})
	
func _forget_target(id:int):
	targets.erase(id)
	notice_timers[id].stop()
	notice_timers[id].queue_free()
	notice_timers[id] = null
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

func update_current_target():
	if noticed_targets.size() > 0:
		current_target_id = noticed_targets[0]
	else:
		current_target_id = null

#notice ui function(s)
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

#func print_target_data():
#	prints("Targets:", targets)
#	print_notice_timers()
#	prints("Current Target:", current_target_id)
#
#func print_notice_timers():
#	var msg:String = ""
#	for key in notice_timers:
#		msg += str(key, ": ", notice_timers[key].time_left, ", ")
#	msg += "}"
#	print("Target Notice Timers: { ", msg, "}")
