extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
	if(Input.is_key_pressed(KEY_R)):
		SceneManager.setScene("res://Parent_Node.tscn", 1)
