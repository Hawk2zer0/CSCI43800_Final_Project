# class member variables go here, for example:
# Movement Turns
var arrBattleQueue = []
# List of enemies
var arrEnemyList = []
# Timer used to check movement order
var intCounter = 0

# Get player instance & Enemy to copy
onready var player = get_node("/root/Parent_Node/Player")
var EnemyProto = load("res://Enemy.tscn")

# Called when scene is ready
func _ready():
	self.set_process(true)
	populateEnemyList()

# called each frame
func _process(delta):
	# Update timer for attack queue & check if someone needs to be added to Queue
	intCounter += 1
	UpdateQueue()
	CheckQueue()

func populateEnemyList():
	# get range from 0-2, then add one to make sure there is always an enemy
	var enemyNum = randi() % 3 + 1
	for i in range(enemyNum):
		# Make new instance of Enemy
		var newEnemy = EnemyProto.instance()
		# Move enemy to new Position
		var playerPos = player.get_global_pos()
		newEnemy.set_global_position(playerPos + Vector3(10.0 * i, 0.0, 10.0 * -i))
		# Change enemy Name
		newEnemy.name = "Enemy-" + i
		# Add new enemy to list
		arrEnemyList.append(newEnemy)
		add_child(newEnemy)
		
# updates the battle queue
func UpdateQueue():
	# always check player speed 1st. (Change for difficulty??)
	if(intCounter % player.myStats.speed == 0):
		arrBattleQueue.append(player)
	
	# check each enemy's speed
	for enemy in arrEnemyList:
		# if counter if even multiple of character speed,
		if(intCounter % enemy.myStats.speed == 0):
			arrBattleQueue.append(enemy)
			
# checks to see if anyone is ready to attack
func CheckQueue():
	if(arrBattleQueue.size() > 0):
		# Do attack dialog stuff