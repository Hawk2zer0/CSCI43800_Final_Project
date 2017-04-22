#extension varies based on the type of item implemented
extends RigidBody

#Macros for various speed and rotational items
var MoveSpeed = 5.0
var RotationDisplacement = PI/90
var jumpHeight = 12
var onFloor = false
var jumping = false
#Demo Walkthrough
var last_rotation = Vector3()

var moveAngle = 0
#Collision Boolean
var isColliding = false

const my_data = preload("Entity_Data.gd")
onready var myStats = my_data.new()

func _ready():
	myStats.set_My_Vals(-1, 100, 15, 10, 15, 10)
	self.set_process(true)
	
func _process(delta):
	# Check if hit every frame
	if(myStats._hit > 0):
		take_damage()
	
	if(Input.is_key_pressed(KEY_Z)):
		myStats._attacking = true
		
# Funciton to decrement HP
func take_damage(hit):
	myStats.decrement_HP(hit)
	print(myStats.get_cur_HP())
	if(myStats.get_cur_HP() <= 0):
		# Remove Self from Screen
		pass
	
func _integrate_forces(state):
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
	
	#Let's map our inputs 
	#forward
	if(Input.is_key_pressed(KEY_W)):
		if(!isColliding):
			var xDelta = (MoveSpeed) * sin(moveAngle)
			var zDelta = (MoveSpeed) * cos(moveAngle)
			
			direction.x = xDelta
			direction.z = zDelta
	
	#backward	
	if(Input.is_key_pressed(KEY_S)):
		if(!isColliding):
			var xDelta = (MoveSpeed) * sin(moveAngle)
			var zDelta = (MoveSpeed) * cos(moveAngle)
			
			
			direction.x = -xDelta
			direction.z = -zDelta
		
	#Jump
	if(Input.is_key_pressed(KEY_SPACE)):
		if(onFloor and !jumping):
			yVelocity = jumpHeight
			onFloor = false
			
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
	var Map= get_node("/root/Parent_Node/Map")
	
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
	
	var target_direction = (direction - up*direction.dot(up))
	
	lv = target_direction + up*yVelocity
	
	state.set_linear_velocity(lv)
	
	last_rotation = get_rotation()	