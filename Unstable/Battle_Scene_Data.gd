# class member variables go here, for example:
# Movement Turns
var arrBattleQueue = []
# List of enemies
var arrEnemyList = []
#List of possible Enemy spawn areas
var arrEnemySpawns = []
# Timer used to check movement order
var intCounter = 0

# Get player instance & Enemy to copy
onready var player = get_node("/root/Parent_Node/Player")
var PlayerProto = load("res://Player.tscn")
var EnemyProto = load("res://Enemy.tscn")

# Called when scene is ready
func _ready():
	self.set_process(true)
	# add player to this scene
	var BattlePlayer = PlayerProto.instance()
	BattlePlayer.get_node("TestCube/Camera").make_current()
	BattlePlayer.set_name(player.get_name() + "-Battle")
	BattlePlayer.set_translation(player.get_translation())
	BattlePlayer.set_rotation(player.get_rotation())
	add_child(BattlePlayer)
	# need to do this before make enemies
	arrEnemySpawns = get_node("./Map/EnemyAreas").get_children()
	makeEnemies()

# called each frame
func _process(delta):
	# Update timer for attack queue & check if someone needs to be added to Queue
	#print(get_tree().get_current_scene())
	intCounter += 1
	UpdateQueue()
	CheckQueue()

func makeEnemies():
	var thisPlayer = get_node("./Player-Battle")
	# get range from 0-2, then add one to make sure there is always an enemy
	var enemyNum = randi() % 3 + 1
	for i in range(enemyNum):
		# Make new instance of Enemy
		var newEnemy = EnemyProto.instance()
		# Move enemy to new Position
		var playerPos = thisPlayer.get_translation()
		
		newEnemy.set_translation(arrEnemySpawns[i].get_translation())
		#newEnemy.set_translation(playerPos + Vector3(10.0 + (1 * i), 0.0, 10.0 + (-1 * i)))
		# Change enemy Name
		newEnemy.set_name("Enemy-" + str(i))
		# Add new enemy to list
		arrEnemyList.append(newEnemy)
		add_child(newEnemy)
		
# updates the battle queue
func UpdateQueue():
	# Update Name based on object name? -> will allow for multiple players
	var thisPlayer = get_node("./Player-Battle")
	# always check player speed 1st. (Change for difficulty??)
	if(intCounter % thisPlayer.myStats.get_speed() == 0):
		arrBattleQueue.append(thisPlayer)
	
	#print(arrEnemyList)
	# check each enemy's speed
	for enemy in arrEnemyList:
		# if counter if even multiple of character speed,
		if(intCounter % enemy.myStats.get_speed() == 0):
			arrBattleQueue.append(enemy)
			
# checks to see if anyone is ready to attack
func CheckQueue():
	if(arrBattleQueue.size() > 0):
		# Do attack dialog stuff
		arrBattleQueue[0].set_active()