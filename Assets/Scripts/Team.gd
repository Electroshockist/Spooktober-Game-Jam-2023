extends Node

class_name Team
@export var team_name: String = ""

func same_team(team: Team):
	if self.team_name and team.team_name:
		return self.team_name == team.team_name
	else:
		return false
