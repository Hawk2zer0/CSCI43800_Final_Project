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
# Bool to stop processing while waiting for timeout
var turnEnded = false

var lastPosition

# instance of Entity data class.
# figure out inheritance??
const my_data = preload("Entity_Data.gd")
onready var myStats = my_data.new()

func _ready():
	myStats.set_My_Vals(0, 50, 10, 5, 140, 4, "Crabbster")
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
	#set_transform(lastPosition)
	var thisDelta = state.get_step()
	
	# Dont need the 1st check...
	if(get_node("/root/SceneManager").getSceneID() == 1):
		MakeMove(state)
	if(get_node("/root/SceneManager").getSceneID() == 2):
		if(myStats._active):
			get_node("MeshInstance/Camera").make_current()
			if(myStats.get_type() == 0):
				if(!turnEnded):
					# Stall here??
					# Stall only works like this...
					# tried making Timer for whole script, but it didn't work....
					# Yield stops this thread from executing,
					# when it was before the new node was set (In Battle Scene), 
					# all the other variables were updated, but not who was active.
					# Got some weird flickering too.
					
					var myLoc = get_translation()
					var playerLoc = get_parent().get_node("Player-Battle").get_translation()
					
					var deltaX = myLoc.x - playerLoc.x
					var deltaZ = myLoc.z - playerLoc.z
					
					var angleTo = atan2(deltaZ,deltaX)
					# moveing away for some reason...
					angleTo += PI
					
					if(angleTo > (2*PI)):
						angleTo -= (2*PI)
					elif(angleTo < 0):
						angleTo += (2*PI)
						
					var moveVec = Vector3(0.0, 0.0, 0.0)
					moveVec.x = cos(angleTo)
					moveVec.z = sin(angleTo)
					
					var normMove = moveVec.normalized()
					
					var PlayerNode = get_parent().get_node("Player-Battle")
					var myAttackArea = self.get_node("AttackArea")
					# If player in attack area
					if(myAttackArea.get_overlapping_bodies().find(PlayerNode) != -1):
						myStats._attacking = true
						EndTurn()
					elif(myLoc.distance_to(OriginOfMove) < myStats.get_movement()):
						#print(myLoc.distance_to(OriginOfMove))
						var newMove = normMove * MoveSpeed
						#print(get_translation())
						#print(newMove)
						#print(get_translation())
						#print(newMove)
						set_linear_velocity(newMove)
						#print(get_translation())
					else:
						EndTurn()
					"""
					# This doesn't currently work. Thinking through it.
					var enemyLoc = get_transform()
					var playerLoc = get_parent().get_node("Player-Battle").get_transform()
					# ignore y since it won't change.
					var dot = enemyLoc.origin.x*playerLoc.origin.x + enemyLoc.origin.z*playerLoc.origin.z
					print(dot)
					if(dot > 100):
						var enemyDestination = enemyLoc.origin.linear_interpolate(playerLoc.origin, AIDelta)
						AIDelta += thisDelta
						enemyLoc.origin = enemyDestination
						set_transform(enemyLoc)
						print(dot)
					else:
						AIDelta = 0
						
					lastPosition = get_transform()
					
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
					"""
				
func EndTurn():
	if(!turnEnded):
		turnEnded = true;
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
		AIDelta = 0
		myStats._active = false
		myStats._speed_counter = 0
		
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

func Push_Back():
	# get difference between Origin and Current Location
	var oppositeLength = get_translation().z - OriginOfMove.z
	var adjacentLength = get_translation().x - OriginOfMove.x
	
	# calculate the angle
	var MoveAngle = atan2(oppositeLength, adjacentLength)
	#print("M: " + str(MoveAngle))
	
	# make sure angle is within range
	#change to while loops??
	if(MoveAngle > (2*PI)):
		MoveAngle -= (2*PI)
	elif(MoveAngle < 0):
		MoveAngle += (2*PI)
	
	# Prep to push in 180 deg
	var pushAngle = MoveAngle + PI
	# make sure push angle is valid
	if(pushAngle > 2*PI):
		pushAngle -= 2*PI
	#print("P: " + str(pushAngle))
	
	# get Push Vec components
	var xPush = cos(pushAngle)
	var zPush = sin(pushAngle)
	
	# push back set amount.
	var pushVec = Vector3(xPush, 0, zPush)
	#print(pushVec)
	
	set_translation(get_translation() + pushVec)