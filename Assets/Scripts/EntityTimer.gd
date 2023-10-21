class_name EntityTimer
extends Node

signal timeout(value)
signal refill(value)

enum TimerProcessCallback{
	TIMER_PROCESS_PHYSICS,
	TIMER_PROCESS_IDLE
}

enum Direction{
	UP = -1,
	DOWN = 1,
	SAME,
	OPPOSITE
}

enum RepeatMode{
	WRAP,
	ONE_SHOT,
	PING_PONG
}

@export var debug = false

@export var process_callback = TimerProcessCallback.TIMER_PROCESS_IDLE
@export var wait_time: float = 1
@export var repeat_mode: RepeatMode = RepeatMode.WRAP
@export var autostart: bool = false
@export var start_dir:Direction = Direction.DOWN

# i wanted the value to be of ambiguous type so you can
# give the timer any value to hold on to. It really
# should be exposed in the editor but if you want to
# expose this you have to hint its type
var value = null

var running: bool = false
var stopped: bool = false
var time_left: float
var time_scale: float = 1

func _ready():
	set_count_direction(start_dir)
	if autostart:
		start()

func _init(_value = value, _wait_time:float = wait_time, _repeat_mode:RepeatMode = repeat_mode, _autostart:bool = autostart, _start_dir:Direction = start_dir):
	value = _value
	wait_time = _wait_time
	repeat_mode = _repeat_mode
	autostart = _autostart
	start_dir = _start_dir

func _physics_process(delta: float):
	if (process_callback == TimerProcessCallback.TIMER_PROCESS_PHYSICS):
		_update_timer(delta)

func _process(delta: float):
	if (process_callback == TimerProcessCallback.TIMER_PROCESS_IDLE):
		_update_timer(delta)

func _update_timer(delta: float):
	if running and time_scale != 0:
		stopped = false
		time_left -= delta * time_scale
		time_left = clamp(time_left, 0, wait_time)
		
		if time_left == 0:
			stop()
			stopped = true
			timeout.emit(value)
			if debug: print("timer timeout")
			repeat()
		elif time_left == wait_time:
			stop()
			stopped = true
			refill.emit(value)
			if debug: print("timer refill")
			repeat()

func repeat():
	match repeat_mode:
		RepeatMode.WRAP:
			start(-1, Direction.SAME)
		RepeatMode.PING_PONG:
			start(-1, Direction.OPPOSITE)

func set_count_direction(dir:Direction):
	if dir != Direction.SAME:
		if dir == Direction.OPPOSITE:
			time_scale *= -1
		else:
			time_scale = dir * absf(time_scale)

func count_down(time_sec:float = -1):
	start(time_sec, Direction.DOWN)

func count_up(time_sec:float = -1):
	start(time_sec, Direction.UP)

func start(time_sec:float = -1, dir:Direction = Direction.SAME): 
	if time_sec > 0: wait_time = time_sec
	set_count_direction(dir)
	
	if time_scale >= 0:
		time_left = wait_time
	else:
		time_left = 0
	
	running = true
	if debug: prints("starting timer", name)

func stop():
	running = false
