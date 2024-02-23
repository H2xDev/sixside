@tool
extends ValveIONode

@onready var mi = $MeshInstance3D;

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var uv0 = convert_vector(e.uv0);
	var uv1 = convert_vector(e.uv1);
	var uv2 = convert_vector(e.uv2);
	var uv3 = convert_vector(e.uv3);
	
	var normal = convert_vector(e.BasisNormal);
	var material = VMTManager.importMaterial(e.material);

	rotation = (e.angles if "angles" in e else Vector3.ZERO) / 180 * PI;

	if normal != Vector3.UP and normal != Vector3.DOWN:
		rotation += Basis.looking_at(normal, Vector3.UP).get_euler();
		rotation.x += PI / 2;
		rotation.y += PI;

	if normal == Vector3.DOWN:
		rotation.x += PI;

	global_transform.origin += normal * 0.01;
	
	var mesh = ArrayMesh.new();
	var surface = [];
	var verts = [uv0, uv1, uv2, uv3];
	var uvs = [
		Vector2(0, 1),
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
	];

	if normal.y == -1:
		uvs = [
			Vector2(1, 0),
			Vector2(1, 1),
			Vector2(0, 1),
			Vector2(0, 0),
		];

	var normals = [
		normal, normal, normal, normal,
	];
	var indices = [
		0, 1, 2,
		0, 2, 3,
	];;
	
	surface.resize(Mesh.ARRAY_MAX);
	surface[Mesh.ARRAY_VERTEX] = PackedVector3Array(verts);
	surface[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs);
	surface[Mesh.ARRAY_NORMAL] = PackedVector3Array(normals);
	surface[Mesh.ARRAY_INDEX] = PackedInt32Array(indices);

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface);
	mesh.surface_set_material(0, material);
	mi.set_mesh(mesh);
	scale = Vector3.ONE * c.importScale;
	
