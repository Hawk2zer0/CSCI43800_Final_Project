extends Node

# class member variables go here, for example:
var _enemyNodeA_Active = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func setNodeA_Activity(state):
	_enemyNodeA_Active = state
	print("State now set to ", _enemyNodeA_Active)
	
func getNodeA_Activity():
	return _enemyNodeA_Active
