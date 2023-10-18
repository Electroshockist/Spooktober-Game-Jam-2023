extends Enemy
class_name TestEnemy

#component references
var team: Team
var sight: Sight

func _ready():
	#get components
	team = $Team
	sight = $Sight

func _process(delta):
	pass

func _physics_process(delta):
	pass
