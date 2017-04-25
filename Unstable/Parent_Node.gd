extends Node

onready var player = get_node("Player")

# Enemies here
onready var enemyNodeA = get_node("Enemy")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	# Grab the player's hp from the last battle scene
	var battlePlayer = get_node("/root/BattleNode")
	
	# Set the current camera to the player's camera
	get_node("Player/TestCube/Camera").make_current()
	
	# If there was a battle, the player's hp needs to be updated
	if(battlePlayer != null):
		#player.myStats._cur_hp = battlePlayer.myStats._cur_hp
		pass
	self.set_process(true)
	
func _process(delta):
	checkKeys()
	checkCollision()
	
func checkCollision():
	
	var bodies = player.get_colliding_bodies()
	
	for body in bodies:
		if(body == enemyNodeA):
			get_node("/root/SceneManager").setScene("res://BattleNodeAlpha.tscn", 2)
	
func checkKeys():
	pass
		