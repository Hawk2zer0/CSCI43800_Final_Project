#extension varies based on the type of item implemented
extends RigidBody

#Macros for various speed and rotational items
var MoveSpeed = 10.0
var RotationDisplacement = PI/90
var jumpHeight = 12

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

# instacne of data class
const my_data = preload("Entity_Data.gd")
onready var myStats = my_data.new()

func _ready():
	myStats.set_My_Vals(-1, 100, 15, 10, 15, 3)
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
	get_node("TestCube/Camera/Enemy_HP").set_text("Testing Enemy HP Value set.")
	
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
				var playerPosition = get_translation()
	
				#we need to consider if it is on top of it
				var objectTop = collidingObjectPosition.y + (collidingObjectScale.y/4)
				
				if((playerPosition.y < objectTop)):
					isColliding = true
					
					#calculate and apply collision pushback
					var oppositeLength = abs(collidingObjectPosition.x - playerPosition.x)
					var adjacentLength = abs(collidingObjectPosition.z - playerPosition.z)
					
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
# only kinda works.... 
func Push_Back():
	var oppositeLength = abs(get_translation().z - OriginOfMove.z)
	var adjacentLength = abs(get_translation().x - OriginOfMove.x)
	
	var MoveAngle = atan(oppositeLength/adjacentLength)
	
	var pushAngle = MoveAngle + PI
	
	#change to while loops??
	if(MoveAngle > (2*PI)):
		MoveAngle -= (2*PI)
	elif(MoveAngle < 0):
		MoveAngle += (2*PI)
	
	var xPush = cos(pushAngle)
	var zPush = sin(pushAngle)
	
	var pushVec = Vector3(xPush, 0, zPush) * 5
	
	set_translation(get_translation() + pushVec)