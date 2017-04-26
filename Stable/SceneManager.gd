extends Node

#Keep Track of our current Scene
var currentScene = null

#Scene Values
#Main Scene = 1
#BattleScene Alpha = 2
#BattleScene Beta = 3

var sceneID = 1

# Store all needed Player Vars to pass between scences Here
# EXPECTED FORMAT:
	# Current HP, Location, Rotation, Move Angle
var _playerVars = [100, Vector3(38.0, 48.0, 0), Vector3(0.0, 0.0, 0.0), 0]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	currentScene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	
func setScene(scene,integer):
	#clean our current Scene
	currentScene.queue_free()
	
	#load our scene file
	var s = ResourceLoader.load(scene)
	
	#create instance of our scene
	currentScene = s.instance()
	
	#add scene to root
	get_tree().get_root().add_child(currentScene)	
	
	setSceneID(integer)

func setSceneID(integer):
	sceneID = integer
	
func getSceneID():
	return sceneID
	
func getCurrentScene():
	return currentScene
	
# Pass in all required Variables. These will be stored here, 
# and a function in Player will be called to set them in the new scene
func pass_scene_vars(playerHP, playerLoc, playerRot, playerDir):
	_playerVars[0] = playerHP
	_playerVars[1] = playerLoc
	_playerVars[2] = playerRot
	_playerVars[3] = playerDir
	
func get_scene_vars():
	return _playerVars