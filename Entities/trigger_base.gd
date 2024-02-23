@tool
class_name TriggerBase extends ValveIONode

func apply_shape_to(ent: Dictionary, cshape: CollisionShape3D):
	var use_convex_shape = ent.solid is Dictionary;

	if use_convex_shape:
		cshape.shape = get_entity_convex_shape();
	else:
		cshape.shape = get_entity_trimesh_shape();
