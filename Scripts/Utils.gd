class_name Utils

static func DeleteChildrenInside(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

static func DeleteNode(node: Node):
	if node != null:
		node.get_parent().remove_child(node)
		node.queue_free()

static func Raycast(world: World3D, origin: Vector3, direction: Vector3, maxDist = 1.0, exclude: Array[RID] = [], mask = 1):
	var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * maxDist, mask, exclude)
	var result = world.direct_space_state.intersect_ray(query);
	if result:
		return result
	return null

static func PlaySound(player: AudioStreamPlayer3D, stream, volume = 0, pitch = 1.0, separately = false):
	if separately:
		var p = player.get_parent();
		player = player.duplicate()
		p.add_child(player)

	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch
	player.play();

static func PlayRandomSound(player: AudioStreamPlayer3D, streams, volume = 0, pitch = 1.0):
	player.stream = streams[randi() % streams.size()]
	player.set_volume_db(volume)
	player.pitch_scale = pitch
	player.play();
