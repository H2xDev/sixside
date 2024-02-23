@tool
extends ValveIONode;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();
	$MeshInstance3D.set_mesh(mesh);
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = mesh.create_convex_shape();

