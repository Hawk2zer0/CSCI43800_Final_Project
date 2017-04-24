# Variable needed by ALL Entities
var _type = 0 # Type Flag: -1:player ; 0:static Enemy ; 1:Melee enemy ; 2:Flying enemy
var _max_HP = 100 
var _cur_HP = 100
var _attack = 10
var _defense = 10
# How What the battle bar will have to reach before you can attack.
# it is updated every frame, so make this a multiple of 60
var _speed = 10
# how far the entity can move
# Good Values between 2 & 4
var _movement = 2.5
# Amount of damage Taken
var _hit = 0
var _attacking = false
# Is active -> used for BattleScene
var _active = false

func set_My_Vals(type, HP, atk, def, spd, mov):
	_type = type
	_max_HP = HP
	_cur_HP = _max_HP
	_attack = atk
	_defense = def
	_speed = spd
	_movement = mov
	_active = false
	
func get_type():
	return _type
	
func get_max_HP():
	return _max_HP
	
func get_cur_HP():
	return _cur_HP

func get_attack():
	return _attack
	
func get_defense():
	return _defense

func get_speed():
	return _speed
	
func get_movement():
	return _movement
	
func decrement_HP():
	_cur_HP -= _hit
	_hit = 0	