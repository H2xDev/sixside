# This plugin modifies instantiation of new nodes by
# placing them in front of the camera in the nearest
# collision point otherwise creates in 0,0

@tool
extends EditorPlugin

var selection: EditorSelection;
var selectedNodes = [];
var currentScene = null;
var camera = null;
var viewport = null;

func Raycast(origin: Vector3, direction: Vector3, maxDist = 1.0, exclude: Array[RID] = [], mask = 1):
	var world = get_tree().edited_scene_root.get_world_3d();
	var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * maxDist, mask, exclude)
	var result = world.direct_space_state.intersect_ray(query);
	if result:
		return result
	return null

func SetSelectionState(state = false):
	for node in selectedNodes:
		if "_editor_isSelected" in node:
			node._editor_isSelected = state;

func PlaceNodeToCameraLookPoint(node: Node):
	if "global_position" in node and node.global_position.length() > 0:
		return;

	if "get_world_3d" not in node:
		return;

	var world = node.get_world_3d();
	var collider = Raycast(camera.global_position, -camera.global_transform.basis.z, 1000, [node]);

	if collider.collider == node:
		return;

	if not collider:
		return;

	var pos = collider.position;
	node.global_transform.origin = pos;

func FindViewport(n: Node = null):
	var base = get_editor_interface().get_base_control() if n == null else n;

	if n == null:
		viewport = null;
		camera = null;

	if viewport != null:
		return;

	for node in base.get_children():
		if viewport != null:
			break;
		if node.get_class() == "Node3DEditorViewport":
			FindCamera(node);
			viewport = node;
		else:
			FindViewport(node);

func FindCamera(n: Node):
	for node in n.get_children():
		if camera != null:
			break;
		if node is Camera3D:
			camera = node;
			break;
		else:
			FindCamera(node);

func OnChildAdded(node: Node):
	var sceneTree = get_tree().edited_scene_root;

	if node.get_parent() == sceneTree:
		PlaceNodeToCameraLookPoint(node);

func OnSelectionChanged():
	SetSelectionState(false);
	selectedNodes = selection.get_selected_nodes();
	SetSelectionState(true);

func Refresh(_n = null):
	FindViewport();
	
	currentScene = get_tree().edited_scene_root;
	if not currentScene.child_entered_tree.is_connected(OnChildAdded):
		currentScene.child_entered_tree.connect(OnChildAdded);

	if selection and selection.selection_changed.is_connected(OnSelectionChanged):
		selection.selection_changed.disconnect(OnSelectionChanged);

	selection = get_editor_interface().get_selection();
	selection.selection_changed.connect(OnSelectionChanged);


func _enter_tree():
	Refresh();
	scene_changed.connect(Refresh);

func _exit_tree():
	if currentScene:
		currentScene.child_entered_tree.disconnect(OnChildAdded);

	if selection:
		selection.selection_changed.disconnect(OnSelectionChanged);

	scene_changed.disconnect(Refresh);
