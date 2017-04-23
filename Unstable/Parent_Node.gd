extends Node

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.set_process(true)
	
func _process(delta):
	checkKeys()
	
func checkKeys():
	if(Input.is_key_pressed(KEY_X)):
		get_node("/root/SceneManager").setScene("res://BattleNodeAlpha.tscn", 2)