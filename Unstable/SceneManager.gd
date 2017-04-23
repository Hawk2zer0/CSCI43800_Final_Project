extends Node

#Keep Track of our current Scene
var currentScene = null

#Scene Values
#Main Scene = 1
#BattleScene Alpha = 2
#BattleScene Beta = 3

var sceneID = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	currentScene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	
func setScene(scene,integer):
	#clean our current Scene
	currentScene.queue_free()
	
	setSceneID(integer)
	
	#load our scene file
	var s = ResourceLoader.load(scene)
	
	#create instance of our scene
	currentScene = s.instance()
	
	#add scene to root
	get_tree().get_root().add_child(currentScene)	

func setSceneID(integer):
	sceneID = integer
	
func getSceneID():
	return sceneID