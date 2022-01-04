extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ammo

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func fire_weapon(space_state):
	if ammo > 0:
		ammo -= 1
		var result = space_state.intersect_ray(Vector2(0, 0), Vector2(50, 100))
		print(result)
	else:
		print("out of ammo")
		pass
	
func set_ammo(quantity):
	self.ammo = quantity
