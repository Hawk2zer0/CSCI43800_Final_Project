# class member variables go here, for example:
var arrBattleQueue = []
var arrEnemyList = []
var intCounter = 0

const ProtoEnemy = preload("enemy_Movement.gd")

func _ready():
	populateEnemyList()


func populateEnemyList():
	# get range from 0-2, then add one to make sure there is always an enemy
	var enemyNum = randi() % 3 + 1
	for i in range(enemyNum):
		arrEnemyList.append(ProtoEnemy.new())
		# Look how to add Scenes programatically
		
func _process(delta):
	# Update timer for attack queue.
	intCounter += 1
	