@tool
class_name InfoPlayerStart extends ValveIONode

static var spawned = false;

func _entity_ready():
	if spawned:
		queue_free();
		return;
	_TeleportPlayer();

func _TeleportPlayer(editor = false):
	var root = get_tree().get_edited_scene_root() if editor else get_tree().get_root().get_node(NodePath('Gameplay'));

	if not root:
		return;

	var player = root.get_node(NodePath('Player'));
	if not player:
		return;

	player.global_position = global_position;

	if not editor:
		InfoPlayerStart.spawned = true;


func _apply_entity(e, c):
	super._apply_entity(e, c);

	_TeleportPlayer(true);
