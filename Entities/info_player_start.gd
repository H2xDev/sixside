@tool
class_name InfoPlayerStart extends ValveIONode

func _apply_entity(e, c):
	super._apply_entity(e, c);

	var player = get_tree().get_edited_scene_root().get_node(NodePath('Player'));

	if not player:
		return;

	player.global_position = global_position;
