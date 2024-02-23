@tool
class_name FuncDynamicMaterial extends ValveIONode

@export var spawnAlbedoColor: Color = Color(1, 1, 1, 1);
@export var targetAlbedoColor: Color = Color(1, 1, 1, 1);
@export var material: BaseMaterial3D = null;

func InterpolateForward(time):
	time = float(time);

	Anime.Animate(time, ProcessInterpolation);

func InterpolateBackward(time):
	time = float(time);

	Anime.Animate(time, ProcessInterpolation, Anime.NO_FUNC, true);

func ProcessInterpolation(percent, _backwards = false):
	var tcolor = spawnAlbedoColor.lerp(targetAlbedoColor, percent);

	material.emission = tcolor;

func _entity_ready():
	$MeshInstance3D.mesh.surface_set_material(0, material);

func _apply_entity(e, c):
	super._apply_entity(e, c);
	spawnAlbedoColor = Color8(int(e.spawnAlbedoColor.x), int(e.spawnAlbedoColor.y), int(e.spawnAlbedoColor.z), 255);
	targetAlbedoColor = Color8(int(e.targetAlbedoColor.x), int(e.targetAlbedoColor.y), int(e.targetAlbedoColor.z), 255);

	$MeshInstance3D.set_mesh(get_mesh())
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = get_entity_shape();

	# NOTE: Make able to edit the material separately from other instances using the same material
	material = $MeshInstance3D.mesh.surface_get_material(0).duplicate();
	material.emission = spawnAlbedoColor;
