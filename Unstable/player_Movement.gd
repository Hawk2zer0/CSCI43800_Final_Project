#extension varies based on the type of item implemented
extends RigidBody

#Macros for various speed and rotational items
var MoveSpeed = 5.0
var RotationDisplacement = PI/180
var jumpHeight = 10
var onFloor = false
var jumping = false
#Demo Walkthrough
var last_ground_velocity = Vector3()

var moveAngle = 0
#Collision Boolean
var isColliding = false

func _ready():
	self.set_process(true)
	
func _process(delta):
	
	checkCollisions()
	#checkKeys(delta)

func checkCollisions():
	#Obtain our Map
	var Map= get_node("/root/Parent_Node/Map")
	
	#check what we are colliding with
	var collidingBodies = get_colliding_bodies()
	
	for body in collidingBodies:
		#we won't care about the map collision, as that is normal
		if (body != Map):
			isColliding = true
		elif (body == Map):
			onFloor = true
			if(jumping):
				jumping = false

func checkKeys(delta):
	#with A and D keys, we want to rotate 
	#rotate Left	
	if(Input.is_key_pressed(KEY_A)):
		var playerLoc = get_translation()
		
		moveAngle += RotationDisplacement
		
		#look location offset
		var xLookDelta = sin(moveAngle)
		var zLookDelta = cos(moveAngle)
		
		look_at(Vector3(playerLoc.x - xLookDelta, playerLoc.y, playerLoc.z - zLookDelta), Vector3(0,1,0))

		if(moveAngle > 2*PI):
			moveAngle -= 2*PI
	
	#rotate Right
	if(Input.is_key_pressed(KEY_D)):
		var playerLoc = get_translation()
		
		moveAngle -= RotationDisplacement
		
		#look location offset
		var xLookDelta = sin(moveAngle)
		var zLookDelta = cos(moveAngle)
		
		look_at(Vector3(playerLoc.x - xLookDelta, playerLoc.y, playerLoc.z - zLookDelta), Vector3(0,1,0))
		
		if(moveAngle < 0):
			moveAngle += 2*PI

func _integrate_forces(state):
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
		var xDelta = (MoveSpeed) * sin(moveAngle)
		var zDelta = (MoveSpeed) * cos(moveAngle)
		direction.x = xDelta
		direction.z = zDelta
	
	#backward	
	if(Input.is_key_pressed(KEY_S)):
		var xDelta = (MoveSpeed) * sin(moveAngle)
		var zDelta = (MoveSpeed) * cos(moveAngle)
		direction.x = -xDelta
		direction.z = -zDelta
		
	#Jump
	if(Input.is_key_pressed(KEY_SPACE)):
		print(onFloor)
		if(onFloor and !jumping):
			yVelocity = jumpHeight
			onFloor = false
			
	if(Input.is_key_pressed(KEY_A)):
		var playerLoc = get_transform()
		
		moveAngle += RotationDisplacement
		
		var xLookDelta = sin(moveAngle)
		var zLookDelta = cos(moveAngle)
		
		var offsetVector = Vector3(xLookDelta, 0, zLookDelta)
		
		var targetLoc = playerLoc.origin - offsetVector
		
		var increment = 1
		
		var rotationTransform = playerLoc.looking_at(targetLoc,Vector3(0,1,0))
		
		var thisRotation = Quat(playerLoc.basis).slerp(rotationTransform.basis,increment)
			
		set_transform(Transform(thisRotation,playerLoc.origin))
		
		print(get_rotation())
		
	if(Input.is_key_pressed(KEY_D)):
		var playerLoc = get_transform()
		
		moveAngle -= RotationDisplacement
		
		var xLookDelta = sin(moveAngle)
		var zLookDelta = cos(moveAngle)
		
		var offsetVector = Vector3(xLookDelta, 0, zLookDelta)
		
		var targetLoc = playerLoc.origin - offsetVector
		
		print(targetLoc)
		
		var increment = 1
		
		var rotationTransform = playerLoc.looking_at(targetLoc,Vector3(0,1,0))
		
		var thisRotation = Quat(playerLoc.basis).slerp(rotationTransform.basis,increment)
			
		set_transform(Transform(thisRotation,playerLoc.origin))
		
		
		
	var target_direction = (direction - up*direction.dot(up))
	
	lv = target_direction + up*yVelocity
	
	state.set_linear_velocity(lv)
	
	#print(lv)
	
	

func resetLinearVelocity():
	set_linear_velocity(Vector3(0,0,0))