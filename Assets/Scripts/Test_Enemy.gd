extends Enemy

class_name Test_Enemy

var team: Team
var viewshape: Area3D

func _ready():
	#not working yet
	viewshape = Area3D.new()
	var shape = ConvexPolygonShape3D.new().set
	viewshape.CollisionShape3D.shape = shape
	team = $Team

func _physics_process(delta):
	pass
