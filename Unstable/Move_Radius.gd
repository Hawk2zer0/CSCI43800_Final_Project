extends Area

var player
var CollShape

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#set_contact_monitor(true)
	#set_max_contacts_reported(5)
	connect("body_enter",self,"_on_body_enter")
	connect("body_exit", self, "_on_body_exit")
	set_process(true)
	# setting player doesn't work??
	#player = get_parent().get_parent().get_node("Player-Battle")
	print(get_translation())
	
	CollShape = get_child(0)

func _process(delta):
	#if(Input.is_key_pressed(KEY_T)):
	#	set_global_transform(player.get_global_transform())
	#	print(get_translation())
	pass

func Set_Origin(entity):
	set_global_transform(entity.get_global_transform())
	set_rotation(Vector3(PI/2,0,0))
	#get_global_transform().rotated(Vector3(1, 0 , 0), 90)
	#print(get_translation())

# dont really need this anymore
func _on_body_enter(body):
	if(body == get_parent().get_parent().get_node("Player-Battle")):
		if(body.myStats._active):
			#print(body.get_name(), " has entered the area!")
			pass

# only need to worry about this for player b/c AI will take care of enemy movement.
func _on_body_exit(body):
	if(body == get_parent().get_parent().get_node("Player-Battle")):
		if(body.myStats._active):
			#print(body.get_name(), " has exited the area!")
			body.Push_Back()
		
			#body.set_axis_velocity(Vector3(0,5,0))