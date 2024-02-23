@tool
class_name FuncPhysbox extends ValveIONode

var FLAG_IGNORE_PICKUP = 8192;
var FLAG_MOTION_DISABLED = 32768;

func EnableMotion(_param):
	$RigidBody3D.freeze = false;

func DisableMotion(_param):
	$RigidBody3D.freeze = true;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	$RigidBody3D.freeze = have_flag(FLAG_MOTION_DISABLED);

	$RigidBody3D/MeshInstance3D.set_mesh(get_mesh());
	$RigidBody3D/CollisionShape3D.shape = get_entity_shape();

