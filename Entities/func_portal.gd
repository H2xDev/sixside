@tool
class_name FuncPortal extends ValveIONode

@export var targetPortal: FuncPortal;

var material = load("res://Assets/Materials/portal.tres").duplicate();
var viewport = null;
var camera = null;
var texture: ViewportTexture;
var referenceTransform: Node3D;
var cameraRef: Node3D;

func _process(_dt):
	if not targetPortal:
		return;

	var mainCamera = get_viewport().get_camera() \
		if not Engine.is_editor_hint() \
		else EditorInterface.get_editor_viewport_3d(0).get_camera_3d();

	var lookerPosition = targetPortal.referenceTransform.basis * mainCamera.global_position;

	lookerPosition.y = -lookerPosition.y;
	cameraRef.position = -lookerPosition;

	var qa1 = referenceTransform.quaternion;
	var qa2 = targetPortal.referenceTransform.quaternion;

	var diff = qa1 * (qa2 * Quaternion.from_euler(Vector3(0, PI, 0))).inverse();
	cameraRef.quaternion = diff * mainCamera.quaternion;
	

	camera.global_transform = cameraRef.global_transform;

	# Viewport size
	var targetSize = mainCamera.get_viewport().size / 2;

	if not viewport:
		return;

	if targetSize.x != viewport.size.x or targetSize.y != viewport.size.y:
		viewport.size = targetSize;

	if mainCamera.fov != camera.fov:
		camera.fov = mainCamera.fov;

func _apply_viewport_texture():
	targetPortal = get_parent().get_node(entity.get("targetPortal", ""));

	if not targetPortal:
		return;

	cameraRef = $CameraTransform;

	referenceTransform = $ReferenceTransform;
	referenceTransform.rotation = convert_direction(entity.get("direction", Vector3(0, 0, 0)));

	camera = $SubViewport/Camera3D;
	viewport = $SubViewport;

	material.set_shader_parameter("viewport_texture", viewport.get_texture());

	$MeshInstance3D.set_surface_override_material(0, material);

func _apply_entity(e, c):
	super._apply_entity(e, c);

	set_timeout(_apply_viewport_texture, 1.0);

	$MeshInstance3D.set_mesh(get_mesh());
