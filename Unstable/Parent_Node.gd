extends Node

# Enemies here
onready var enemyNodeA = get_node("Enemy")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.set_process(true)
	
func _process(delta):
	checkKeys()
	checkCollision()
	
func checkCollision():
	var player = get_node("Player")
	
	var bodies = player.get_colliding_bodies()
	
	for body in bodies:
		if(body == enemyNodeA):
			get_node("/root/SceneManager").setScene("res://BattleNodeAlpha.tscn", 2)
	
func checkKeys():
	pass
		