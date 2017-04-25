#extension varies based on the type of item implemented
extends RigidBody

#Macros for various speed and rotational items
const MoveSpeed = 10.0
const RotationDisplacement = PI/90
const jumpHeight = 10
const heightOffset = 1.5

var onFloor = false
var jumping = false
var landingFlag = false
#Demo Walkthrough
var last_rotation = Vector3()

var moveAngle = 0
#Collision Boolean
var isColliding = false

# Origin for Battle
var OriginOfMove

# instance of data class
const my_data = preload("Entity_Data.gd")
onready var myStats = my_data.new()

func _ready():
	myStats.set_My_Vals(-1, 100, 15, 10, 15, 4)
	self.set_process(true)
	
func _process(delta):
	pass
		
	update_hud();
	
# Funciton to decrement HP
func take_damage():
	myStats.decrement_HP()
	print(myStats.get_cur_HP())
	if(myStats.get_cur_HP() <= 0):
		# DIE -> Game over scene?
		pass
		
func set_hit(intEnemyAttackAmt):
	myStats._hit = intEnemyAttackAmt
	# can asses Defense stuff here
	take_damage()
	
func set_active():
	myStats._active = true
	
func set_origin(vecOriginalPos):
	OriginOfMove = vecOriginalPos

func update_hud():
	# Player HP label update
	get_node("TestCube/Camera/Player_HP_Bar").set_value(float(myStats.get_cur_HP()))
	get_node("TestCube/Camera/Player_HP").set_text(str(myStats.get_cur_HP()))
	
	
	# Player Attack Speed label update
	get_node("TestCube/Camera/Player_Atk_Spd").set_text(str(myStats.get_speed()))

	# Enemy HP label update
	if(get_node("/root/SceneManager").getSceneID() > 1):
		var scene = SceneManager.getCurrentScene()
		if(scene != null):
			#for i in range(get_node("root/BattleNode").arrEnemyList.size()):
				#get_node("TestCube/Camera/Enemy_HP_Bar" + str(i)).show()
				#get_node("TestCube/Camera/Enemy_HP").set_text("Enemy" + str(i + 1))
				#get_parent().get_node("Enemy").get_cur_HP()
				get_node("TestCube/Camera/Battle_Menu").show()	
	
func _integrate_forces(state):
	#reset rotation
	# Required Every Frame
	set_rotation(last_rotation)
	
	if(get_node("/root/SceneManager").getSceneID() == 1):
		CheckKeys(state)
	if(get_node("/root/SceneManager").getSceneID() == 2):
		if(myStats._active):
			CheckKeys(state)
			if(TakeAction()):
				myStats._active = false
				
# Boolean function used to determine what (if) an action was take
func TakeAction():
	# Attack
	if(Input.is_key_pressed(KEY_Z)):
		myStats._attacking = true
		return true
	# TEMP: Take damage
	elif(Input.is_key_pressed(KEY_O)):
		set_hit(10);
		return true
	# Pass
	elif(Input.is_key_pressed(KEY_P)):
		return true
	else:
		return false

func CheckKeys(state):
	# Check keys & Update position/rotation
	
	# we only care about movement if keys are pressed that respond to movement
	var lv = state.get_linear_velocity() #Entity Linear Velocity
	var delta = state.get_step() #Frame Rate
	var gravity = state.get_total_gravity() #gravitational force applied on entity
	
	if(!onFloor):
		lv += gravity * delta
	
	var up = -gravity.normalized() # Normal against gravity
	
	var yVelocity = up.dot(lv) #Vertical Velocity only (Y-axis)
	
	var direction = Vector3() #Where does the player intend to walk to
	
	# Reset movespeed every frame to allow for running
	MoveSpeed = 10.0
	
	# Check for runnung.
	if(Input.is_key_pressed(KEY_SHIFT)):
		MoveSpeed = 20.0
	#Let's map our inputs 
	#forward
	if(Input.is_key_pressed(KEY_W)):
		if(!landingFlag):
			if(!isColliding):
				var xDelta = (MoveSpeed) * sin(moveAngle)
				var zDelta = (MoveSpeed) * cos(moveAngle)
				
				direction.x = xDelta
				direction.z = zDelta
				
		else:
			landingFlag = false
	
	#backward	
	if(Input.is_key_pressed(KEY_S)):
		if(!landingFlag):
			if(!isColliding):
				var xDelta = (MoveSpeed) * sin(moveAngle)
				var zDelta = (MoveSpeed) * cos(moveAngle)
				
				
				direction.x = -xDelta
				direction.z = -zDelta
		
		else:
			landingFlag = false
			
	#Jump
	if(Input.is_key_pressed(KEY_SPACE)):
		if(get_node("/root/SceneManager").getSceneID() == 1):
			if(onFloor and !jumping):
				yVelocity = jumpHeight
				onFloor = false
				jumping = true
			
	if(Input.is_key_pressed(KEY_A)):
		var playerLoc = get_transform()
		
		moveAngle += RotationDisplacement
		if(moveAngle > 2*PI):
			moveAngle -= 2*PI
		
		var xLookDelta = sin(moveAngle)
		var zLookDelta = cos(moveAngle)
		
		var offsetVector = Vector3(xLookDelta, 0, zLookDelta)
		
		var targetLoc = playerLoc.origin - offsetVector
		
		var increment = 1
		
		var rotationTransform = playerLoc.looking_at(targetLoc,Vector3(0,1,0))
		
		var thisRotation = Quat(playerLoc.basis).slerp(rotationTransform.basis,increment)
			
		set_transform(Transform(thisRotation,playerLoc.origin))
		
	if(Input.is_key_pressed(KEY_D)):
		var playerLoc = get_transform()
		
		moveAngle -= RotationDisplacement
		
		if(moveAngle < 0):
			moveAngle += 2*PI
		
		var xLookDelta = sin(moveAngle)
		var zLookDelta = cos(moveAngle)
		
		var offsetVector = Vector3(xLookDelta, 0, zLookDelta)
		
		var targetLoc = playerLoc.origin - offsetVector
		
		var increment = 1
		
		var rotationTransform = playerLoc.looking_at(targetLoc,Vector3(0,1,0))
		
		var thisRotation = Quat(playerLoc.basis).slerp(rotationTransform.basis,increment)
			
		set_transform(Transform(thisRotation,playerLoc.origin))	
		
	#Collision Detection and handling
	var Map = get_parent().get_node("Map")
	
	#check what we are colliding with
	var collidingBodies = get_colliding_bodies()
	#print(collidingBodies)
	
	for body in collidingBodies:
		#we won't care about the map collision, as that is normal
		if (body != Map):
			isColliding = true
			var collidingObjectPosition = body.get_global_transform()
			var playerPosition = get_global_transform()

			#we need to consider if it is on top of it
			var objectTop = collidingObjectPosition.origin.y
			
			if((playerPosition.origin.y - heightOffset < objectTop && jumping)):
				
				#calculate and apply collision pushback
				var oppositeLength = abs(collidingObjectPosition.origin.x - playerPosition.origin.x)
				var adjacentLength = abs(collidingObjectPosition.origin.z - playerPosition.origin.z)
				
				#calculate angle to object
				var angleToObject = atan2(oppositeLength,adjacentLength)
				
				if(angleToObject > (2*PI)):
					angleToObject -= (2*PI)
				elif(angleToObject < 0):
					angleToObject += (2*PI)
				
				#determine offset of the player's actual angle and the angle of the object
				var offset = angleToObject - moveAngle
				
				#determine push away angle			
				var pushAngle = (angleToObject-PI) + offset
				
				#calculate direction vectors as if we are to move to it
				var xToObject = MoveSpeed * sin(pushAngle)
				var zToObject = MoveSpeed * cos(pushAngle)
				
				#apply pushback force
				direction.x = xToObject
				direction.z = zToObject
			else:
				isColliding = false
				onFloor = true
				if(jumping):
					jumping = false
			
		else:
			if(body == Map):
				if(collidingBodies.size() == 1):
					isColliding = false
				onFloor = true
				if(jumping):
					jumping = false
					landingFlag = true
		
	var target_direction = (direction - up*direction.dot(up))
	
	lv = target_direction + up*yVelocity
	
	state.set_linear_velocity(lv)
	
	last_rotation = get_rotation()

# Pushes in opposite directon of movement.
# Figure out a way to make it predictive??
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