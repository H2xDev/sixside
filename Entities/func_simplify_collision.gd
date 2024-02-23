@tool
class_name FuncSimplifyCollision extends ValveIONode

const FLAG_NO_COLLISION = 1;
const FLAG_DISABLE_SHADOWS = 2;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();
	var shape = mesh.create_convex_shape();

	$MeshInstance3D.cast_shadow = 0 if have_flag(FLAG_DISABLE_SHADOWS) else $MeshInstance3D.cast_shadow;
	$MeshInstance3D.set_mesh(mesh);


	if not have_flag(FLAG_NO_COLLISION):
		$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = shape;
