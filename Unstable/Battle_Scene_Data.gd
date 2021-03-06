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
var PlayerProto = load("res://Player.tscn")
var EnemyProto = load("res://Crabbster.tscn")
var BattlePlayer = PlayerProto.instance()
# Called when scene is ready
func _ready():
	self.set_process(true)
	# add player to this scene
	var PlayerVars = SceneManager.get_scene_vars()
	BattlePlayer.get_node("Player/Camera").make_current()
	BattlePlayer.set_name("Player-Battle")
	add_child(BattlePlayer)
	# set AFTER Added to tree
	# b/c Stats class waits for player to be ready before it is made.
	BattlePlayer.recieve_scene_vars(PlayerVars)
	# need to do this before make enemies
	arrEnemySpawns = get_node("./Map/EnemyAreas").get_children()
	makeEnemies()
	#get_node("./Map/MoveRadius").Set_Player()
	BattlePlayer.setArray(arrEnemyList)
	

# called each frame
func _process(delta):
	# Update timer for attack queue & check if someone needs to be added to Queue
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
		var thisPlayer = get_node("./Player-Battle")
		SceneManager.pass_scene_vars(thisPlayer.myStats.get_cur_HP(), thisPlayer.get_translation(), thisPlayer.last_rotation, thisPlayer.moveAngle)
		get_node("/root/SceneManager").setScene("res://Parent_Node.tscn", 1)
		


func makeEnemies():
	# get range from 0-2, then add one to make sure there is always an enemy
	randomize()
	var enemyNum = randi() % 3 + 1
	for i in range(enemyNum):
		# Make new instance of Enemy
		var newEnemy = EnemyProto.instance()
		
		newEnemy.set_translation(arrEnemySpawns[i].get_translation())
		newEnemy.set_rotation(Vector3(0, 3, 0))
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
	if(thisPlayer.myStats.get_speed() <= thisPlayer.myStats.get_speed_counter()):
		# if player not in queue
		if(arrBattleQueue.find(thisPlayer) == -1):
			arrBattleQueue.append(thisPlayer)
	else:
		# Counter is reset in player.takeAction function
		thisPlayer.myStats.increment_speed_counter()
	
	#print(arrEnemyList)
	# check each enemy's speed
	for enemy in arrEnemyList:
		# if counter if even multiple of character speed,
		if(enemy.myStats.get_speed() <= enemy.myStats.get_speed_counter()):
			# if enemy not in queue
			if(arrBattleQueue.find(enemy) == -1):
				enemy.turnEnded = false
				arrBattleQueue.append(enemy)
		else:
			enemy.myStats.increment_speed_counter()
	#print(arrBattleQueue)
# checks to see if anyone is ready to attack
func CheckQueue():
	if(arrBattleQueue.size() > 0):
		# If the 1st element is not active
		if(!arrBattleQueue[0].myStats._active):
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
				#print("here")
				arrBattleQueue[0].set_origin(arrBattleQueue[0].get_translation())
				get_node("./Map/MoveRadius").Set_Origin(arrBattleQueue[0])
				get_node("./Map/MoveRadius/CollisionShape").get_shape().set_radius(arrBattleQueue[0].myStats.get_movement())
		else:
			#print(arrBattleQueue[0].get_translation())
			pass
	else:
		# if battle queue is empyt, make plater camera the active one.
		get_node("./Player-Battle/Player/Camera").make_current()
