#extension varies based on the type of item implemented
extends RigidBody

#Macros for various speed and rotational items
var MoveSpeed = 5.0
var RotationDisplacement = PI/90
var jumpHeight = 12
var onFloor = false
#Demo Walkthrough
var last_rotation = Vector3()
var moveAngle = 0
#Collision Boolean
var isColliding = false
# Origin for Battle
var OriginOfMove
# step holder for enemy AI
var AIDelta = 0

var lastPosition

# instance of Entity data class.
# figure out inheritance??
const my_data = preload("Entity_Data.gd")
onready var myStats = my_data.new()

func _ready():
	myStats.set_My_Vals(0, 50, 10, 5, 140, 6, "Crabbster")
	self.set_process(true)
	lastPosition = get_transform()
	
func _process(delta):
	pass
		
# Funciton to decrement HP
func take_damage():
	myStats.decrement_HP()
	print(myStats.get_cur_HP())
		
func set_active():
	myStats._active = true
		
func set_hit(intEnemyAttackAmt):
	myStats._hit = intEnemyAttackAmt
	# can asses Defense stuff here
	take_damage()
	
func set_origin(vecOriginalPos):
	OriginOfMove = vecOriginalPos
	
func _integrate_forces(state):
	set_transform(lastPosition)
	var thisDelta = state.get_step()
	
	# Dont need the 1st check...
	if(get_node("/root/SceneManager").getSceneID() == 1):
		MakeMove(state)
	if(get_node("/root/SceneManager").getSceneID() == 2):
		if(myStats._active):
			get_node("MeshInstance/Camera").make_current()
			if(myStats.get_type() == 0):
				# Stall here??
				# Stall only works like this...
				# tried making Timer for whole script, but it didn't work....
				# Yield stops this thread from executing,
				# when it was before the new node was set (In Battle Scene), 
				# all the other variables were updated, but not who was active.
				# Got some weird flickering too.
				
				# This doesn't currently work. Thinking through it.
				var enemyLoc = get_transform()
				var playerLoc = get_parent().get_node("Player-Battle").get_transform()
				var dot = enemyLoc.origin.x*playerLoc.origin.x + enemyLoc.origin.y*playerLoc.origin.y + enemyLoc.origin.z*playerLoc.origin.z
				if(dot < 1500):
					var enemyDestination = enemyLoc.origin.linear_interpolate(playerLoc.origin, AIDelta)
					AIDelta += thisDelta
					enemyLoc.origin = enemyDestination
					set_transform(enemyLoc)
					print(dot)
				
				var t = Timer.new()
				t.set_wait_time(1.0)
				add_child(t)
				t.start()
				# timeout is a functoin built into the timer. It will release this blocked thread,
				# thereby setting active to false & allowing the camera to stay in this pos for a while.
				yield(t,"timeout")
				t.stop()
				# Should be removed from tree?
				# works the same, but may be adding a lot of cycles...
				remove_child(t)
				myStats._active = false
				myStats._speed_counter = 0
				lastPosition = get_transform()

func MakeMove(state):
	#reset rotation
	set_rotation(last_rotation)
	
	# we only care about movement if keys are pressed that respond to movement
	var lv = state.get_linear_velocity() #Entity Linear Velocity
	var delta = state.get_step() #Frame Rate
	var gravity = state.get_total_gravity() #gravitational force applied on entity
	
	if(!onFloor):
		lv += gravity * delta
	
	var up = -gravity.normalized() # Normal against gravity
	
	var yVelocity = up.dot(lv) #Vertical Velocity only (Y-axis)
	
	var direction = Vector3() #Where does the player intend to walk to
	
	"""
		PUT AI TYPE THINGS HERE
		-> HOW TO MOVE
		-> ROATATE TO SELECTED DIRECTION
		-> ACTUALLY MOVE
	"""
	
	# Might not need all this stuff?
	
	var scene = SceneManager.getCurrentScene()
	
	# make sure there is an active scene.
	if(scene != null):
		var Map = get_node("/root/" + scene.get_name() + "/Map")
	
		#check what we are colliding with
		var collidingBodies = get_colliding_bodies()
		#print(collidingBodies)
		for body in collidingBodies:
			#we won't care about the map collision, as that is normal
			if (body != Map):
				var collidingObjectPosition = body.get_translation()
				var collidingObjectScale = body.get_scale()
				var enemyPosition = get_translation()
	
				#we need to consider if it is on top of it
				var objectTop = collidingObjectPosition.y + (collidingObjectScale.y/4)
				
				if((enemyPosition.y < objectTop)):
					isColliding = true
									
					#calculate and apply collision pushback				
					var oppositeLength = abs(collidingObjectPosition.x - enemyPosition.x)
					var adjacentLength = abs(collidingObjectPosition.z - enemyPosition.z)
					
					#calculate angle to object
					var angleToObject = atan(oppositeLength/adjacentLength)
					
					if(angleToObject > (2*PI)):
						angleToObject -= (2*PI)
					elif(angleToObject < 0):
						angleToObject += (2*PI)
					
					#determine offset of the player's actual angle and the angle of the object
					var offset = angleToObject - moveAngle
					
					#determine push away angle			
					var pushAngle = (angleToObject-PI) + offset
					
					#calculate direction vectors as if we are to move to it
					var xToObject = sin(pushAngle)
					var zToObject = cos(pushAngle)
					
					#apply pushback force
					direction.x = xToObject
					direction.z = zToObject
				else:
					onFloor = true
					
	#maintain angle and position
	#last_rotation = get_rotation()
