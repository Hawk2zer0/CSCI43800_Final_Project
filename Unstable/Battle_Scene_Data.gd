# class member variables go here, for example:
# Movement Turns
var arrBattleQueue = []
# List of enemies
var arrEnemyList = []
#List of possible Enemy spawn areas
var arrEnemySpawns = []
# Timer used to check movement order
var intCounter = 0
# Bool to track if an action has been taken
var boolWasActive = false

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
	BattlePlayer.set_rotation(player.last_rotation)
	add_child(BattlePlayer)
	# set AFTER Added to tree
	BattlePlayer.myStats._cur_HP = player.myStats.get_cur_HP()
	# need to do this before make enemies
	arrEnemySpawns = get_node("./Map/EnemyAreas").get_children()
	makeEnemies()
	#get_node("./Map/MoveRadius").Set_Player()

# called each frame
func _process(delta):
	# Update timer for attack queue & check if someone needs to be added to Queue
	#print(get_tree().get_current_scene())
	intCounter += 1
	CheckDeaths()
	UpdateQueue()
	CheckQueue()

func CheckDeaths():
	var outCounter = arrEnemyList.size() - 1
	while(outCounter >= 0):
		if(arrEnemyList[outCounter].myStats.get_cur_HP() <= 0):
			var counter = arrBattleQueue.size() - 1
			while(counter >= 0):
				if(arrEnemyList[outCounter] == arrBattleQueue[counter]):
					arrBattleQueue.remove(counter)
				counter -= 1
			arrEnemyList[outCounter].queue_free()
			remove_child(arrEnemyList[outCounter])
			arrEnemyList.remove(outCounter)
		outCounter -= 1
	if(arrEnemyList.size() == 0):
		print("VICTORY")


func makeEnemies():
	var thisPlayer = get_node("./Player-Battle")
	# get range from 0-2, then add one to make sure there is always an enemy
	randomize()
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
		if(arrBattleQueue.size() < 10):
			arrBattleQueue.append(thisPlayer)
	
	#print(arrEnemyList)
	# check each enemy's speed
	for enemy in arrEnemyList:
		# if counter if even multiple of character speed,
		if(intCounter % enemy.myStats.get_speed() == 0):
			if(arrBattleQueue.size() < 10):
				arrBattleQueue.append(enemy)
			else:
				# reset intCounter when queue is full to avoid overflow errors.
				intCounter = 0
			
# checks to see if anyone is ready to attack
func CheckQueue():
	if(arrBattleQueue.size() > 0):
		# If the 1st element is not active
		if(!arrBattleQueue[0].myStats._active):
			#if(arrBattleQueue[0].myStats.get_cur_HP() <= 0):
			#print(arrBattleQueue[0])
			# if the 1st element WAS active
			if(boolWasActive):
				arrBattleQueue.pop_front()
				boolWasActive = false
				# move Area After turn
				get_node("./Map/MoveRadius").Set_Origin(get_node("./Map"))
			# if this is the 1st time the element is being made active
			else:
				# Do attack dialog stuff
				print(arrBattleQueue[0].get_name() + "'s Turn")
				arrBattleQueue[0].set_active()
				boolWasActive = true
				arrBattleQueue[0].set_origin(arrBattleQueue[0].get_translation())
				get_node("./Map/MoveRadius").Set_Origin(arrBattleQueue[0])
				get_node("./Map/MoveRadius/CollisionShape").get_shape().set_radius(arrBattleQueue[0].myStats.get_movement())