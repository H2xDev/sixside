@tool
class_name PointTeleport extends ValveIONode

func Teleport(_param = null):
	var target = get_target(entity.target);
	target.global_transform = global_transform;
	target.rotation.y = convert_direction(entity.angles).y - PI / 2.0;

