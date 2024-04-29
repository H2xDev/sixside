@tool
class_name BulletEmitter extends ValveIONode

@export var bulletDirection: Vector3 = Vector3.ZERO;

var maxRecastCount = 10;

func calculatePath():
	var points: Array[Vector3] = [];

	for i in range(maxRecastCount):
		var res = Utils.Raycast(get_world_3d(), global_position, bulletDirection, 1000, [self]);
		if not res: break;

		points.append(res.position);

func _apply_entity(e, _c):
	bulletDirection = get_movement_vector(e.get("movedir", Vector3.ZERO));
