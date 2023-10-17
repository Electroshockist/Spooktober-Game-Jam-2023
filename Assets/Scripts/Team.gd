extends Node

class_name Team
@export var team_name: String = ""

func sameTeam(team_name: String):
	if self.team_name and team_name:
		return self.team_name == team_name
	else:
		return false
