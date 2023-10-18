extends Node

class_name Team
@export var team_name: String = "" : set = set_team_name

func same_team(team: Team):
	if self.team_name and team.team_name:
		return self.team_name == team.team_name
	else:
		return false

func set_team_name(name: String):
	team_name = name.to_lower()
