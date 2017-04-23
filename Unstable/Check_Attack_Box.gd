# This script will alwasy be attached to an Area Node, which will be a direct child of The Body attacking.

# gets the physics type and all that
extends Area

func _ready():
	# Called every time the node is added to the scene.
	# set _process to be called each frame
	self.set_process(true)
	
func _process(delta):
	var attackableBodies = get_overlapping_bodies()
	var arrIgnoredBodies = []
	var Map = get_node("/root/Parent_Node/Map")
	arrIgnoredBodies.append(Map)
	
	for child in Map.get_children():
		arrIgnoredBodies.append(child)
	
	arrIgnoredBodies.append(self)
	arrIgnoredBodies.append(self.get_parent())
	
	#print(arrIgnoredBodies)
	if(self.get_parent().myStats._attacking):
		for body in attackableBodies:
			# If the body is not in the ignore array
			if(arrIgnoredBodies.find(body) == -1):
				# set the body's damage Taken value to This object's Attack Value
				# Add defense considerations later.
				# Get path to checked node, the set Hit value.
				get_node(body.get_path()).myStats._hit = self.get_parent().myStats.get_attack()
		self.get_parent().myStats._attacking = false
