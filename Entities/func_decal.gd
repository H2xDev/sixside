@tool
extends ValveIONode

@export var material: ShaderMaterial = null;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var mesh = get_mesh();
	var aabb = mesh.get_aabb();

	var texture = load('res://Assets/Materials/' + entity.texture + '.png');

	if not texture:
		texture = load('res://Assets/Materials/' + entity.texture + '.jpg');

	$MeshInstance3D.set_mesh(BoxMesh.new());
	$MeshInstance3D.scale = aabb.size;

	material = $MeshInstance3D.get_surface_override_material(0).duplicate();
	$MeshInstance3D.set_surface_override_material(0, material);

	var rot = (entity.direction / 180 * PI) + Vector3(0, 0, -PI / 2);
	material.set_shader_parameter('texture_albedo', texture);
	material.set_shader_parameter('rotation', rot);
