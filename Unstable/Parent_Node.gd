extends Node

onready var player = get_node("Player")

onready var respawnThreshold = 900

#current timers for enemy nodes
var nodeA_Timer

# Enemies here
onready var enemyNodeA = get_node("BattleNodeA/Enemy")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	nodeA_Timer = 0
	
	# Grab the player's hp from the last battle scene
	#var battlePlayer = get_node("/root/BattleNode")
	var playerVars = SceneManager.get_scene_vars()
	player.recieve_scene_vars(playerVars)
	#player.myStats._cur_HP = playerVars[0]
	#player.set_translation(playerVars[1])
	#player.last_rotation = playerVars[2]
	
	# Set the current camera to the player's camera
	get_node("Player/TestCube/Camera").make_current()
	
	# If there was a battle, the player's hp needs to be updated
	#if(battlePlayer != null):
		#player.myStats._cur_hp = battlePlayer.myStats._cur_hp
	#	pass
	self.set_process(true)
	
func _process(delta):
	checkCollision()
	checkActive()
	checkTimers()
	
func checkCollision():
	
	var bodies = player.get_colliding_bodies()
	
	for body in bodies:
		if(body == enemyNodeA):
			if(Respawn_Controller.getNodeA_Activity() == true):
				enemyNodeA.set_translation(Vector3(0,0,0))
				SceneManager.pass_scene_vars(player.myStats.get_cur_HP(), player.get_translation(), player.last_rotation, player.moveAngle)
				SceneManager.setScene("res://BattleNodeAlpha.tscn", 2)
				Respawn_Controller.setNodeA_Activity(false)
			
func checkActive():
	if(Respawn_Controller.getNodeA_Activity() == false):
		enemyNodeA.set_hidden(true)
	else:
		enemyNodeA.set_hidden(false)
	
func checkTimers():
	var timer_step = float(1/60)
	print(nodeA_Timer)
	
	if(Respawn_Controller.getNodeA_Activity() == false):
		nodeA_Timer += 1
		if(nodeA_Timer > respawnThreshold):
			nodeA_Timer = 0
			Respawn_Controller.setNodeA_Activity(true)
	
		