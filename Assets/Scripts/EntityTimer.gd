class_name EntityTimer
extends Node

signal timeout(id:int)
signal refill(id:int)

enum TimerProcessCallback{
	TIMER_PROCESS_PHYSICS,
	TIMER_PROCESS_IDLE
}

enum COUNTING{
	UP = -1,
	SAME = 0,
	DOWN = 1
}

@export var process_callback = TimerProcessCallback.TIMER_PROCESS_IDLE
@export var wait_time: float = 1
@export var one_shot: bool = true
@export var autostart: bool = true
var running: bool = false
var stopped: bool = false
var time_left: float
var time_scale: float = COUNTING.DOWN

var id:int

func _enter_tree():
	if autostart:
		count_down()

func _init(_id:int, _wait_time:float = 1, _one_shot:bool = true, _autostart:bool = true):
	id = _id
	wait_time = _wait_time
	one_shot = _one_shot
	autostart = _autostart

func _physics_process(delta: float):
	if (process_callback == TimerProcessCallback.TIMER_PROCESS_PHYSICS):
		_update_timer(delta)

func _process(delta: float):
	if (process_callback == TimerProcessCallback.TIMER_PROCESS_IDLE):
		_update_timer(delta)

func _update_timer(delta: float):
	if running and time_scale != 0:
		time_left -= delta * time_scale
		time_left = clamp(time_left, 0, wait_time)
		if time_left == 0:
			stop()
			stopped = true
			timeout.emit(id)
		elif time_left == wait_time:
			stop()
			stopped = true
			refill.emit(id)

func set_count_direction(dir:COUNTING):
	if dir != COUNTING.SAME:
		time_scale = dir * absf(time_scale)

func count_down(time_sec:float = -1):
	start(time_sec, COUNTING.DOWN)

func count_up(time_sec:float = -1):
	start(time_sec, COUNTING.UP)

func start(time_sec:float = -1, dir:COUNTING = COUNTING.SAME): 
	if time_sec > 0: wait_time = time_sec
	set_count_direction(dir)
	
	if time_scale >= 0:
		time_left = wait_time
	else:
		time_left = 0
	
	running = true
	stopped = false

func stop():
	running = false
