@tool
extends ValveIONode


func _apply_entity(e, c):
	super._apply_entity(e, c);

	var scene = get_tree().get_edited_scene_root();
	var aabb = get_mesh().get_aabb();
	
	$VoxelGI.size = aabb.size;
	$VoxelGI.data.interior = e.interior if "interior" in e else null;
	$VoxelGI.subdiv = e.resolution if "resolution" in e else 1;

	var new = $VoxelGI.duplicate();

	if scene.get_node_or_null(NodePath(name)):
		scene.remove_child(scene.get_node(NodePath(name)));

	new.name = name;
	new.global_position = global_position;
	
	scene.add_child(new);
	new.set_owner(scene);
	new.bake();

	queue_free();
