@tool
class_name InfoPlayerStart extends ValveIONode

static var spawned = false;

func _entity_ready():
	if spawned:
		queue_free();
		return;
	_TeleportPlayer();

func _TeleportPlayer(editor = false):
	var root = get_tree().get_edited_scene_root() if editor else get_tree().get_root().get_node_or_null(NodePath('Gameplay'));

	if not root:
		return;

	var player = root.get_node_or_null(NodePath('Player'));
	if not player:
		return;

	player.global_position = global_position;
	player.global_rotation.y = convert_direction(entity.angles).y - PI / 2;

	if not editor:
		InfoPlayerStart.spawned = true;


func _apply_entity(e, c):
	super._apply_entity(e, c);

	_TeleportPlayer(true);
