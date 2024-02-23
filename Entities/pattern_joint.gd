@tool
class_name PatternJoint extends ValveIONode

@export var forwards: Vector3 = Vector3(0, 0, 0);
@export var busy: bool = false;

func _apply_entity(e, c):
	super._apply_entity(e, c);
	var _basis = Basis.from_euler(convert_direction(e.angles if "angles" in e else Vector3(0, 0, 0)));

	forwards = -_basis.z;

	rotation = _basis.get_euler();

