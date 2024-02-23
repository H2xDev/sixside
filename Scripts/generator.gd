@tool
extends Node3D

@export var folder = "res://GeneratorPatterns";

@export var _current_seed = 23123123;

var corridorPatterns = [];
var hubPatterns = [];
var trapPatterns = [];

var lastCreated: Node3D = null;

## Min and max corridor length
@export var corridorLength: Vector2 = Vector2(2, 4);

## Min and max hubs
@export var hubLength: Vector2 = Vector2(2, 4);

var needHub = true;
var currentCorridorLength = 0;
var currentHubLength = 0;
var randIndex = -1;

@export var generate = false:
	set(value):
		if not value:
			return;
		lastCreated = null;
		clear();
		preloadPatterns();
		_generate();
		generate = false;

func clear():
	randIndex = -1;
	currentCorridorLength = 0;
	currentHubLength = round(getRandomValue() * (hubLength.y - hubLength.x) + hubLength.x);

	for child in get_children():
		remove_child(child);
		child.queue_free();

func preloadPatterns():
	corridorPatterns.clear();
	hubPatterns.clear();
	trapPatterns.clear();

	var corridorFolder = folder + "/corridors";
	var hubFolder = folder + "/hubs";
	var trapFolder = folder + "/traps";

	for file in DirAccess.get_files_at(corridorFolder):
		if not file.ends_with('.tscn'):
			continue;
		corridorPatterns.append(load(corridorFolder + '/' + file));

	for file in DirAccess.get_files_at(hubFolder):
		if not file.ends_with('.tscn'):
			continue;
		hubPatterns.append(load(hubFolder + '/' + file));

	for file in DirAccess.get_files_at(trapFolder):
		if not file.ends_with('.tscn'):
			continue;
		trapPatterns.append(load(trapFolder + '/' + file));
	
func _generate(i = 0):
	var node = instantiatePattern();

	if (node == null):
		generateTraps();
		return;

	if lastCreated == null:
		lastCreated = node;
		_generate(i + 1);
		return;

	var isSuccess = attachPatternToLastCreatedPattern(node);

	if not isSuccess:
		_generate(i + 1);
		return;

	lastCreated = node;

	_generate(i + 1);

func generateTraps():
	var children = get_children();

	for child in children:
		var joints = getFreeJoints(child);

		if joints.size() == 0:
			continue;

		for joint in joints:
			var trap = instantiateRandomPattern(trapPatterns);
			var corridor = instantiateRandomPattern(corridorPatterns);

			attachPatternToLastCreatedPattern(corridor, child);
			attachPatternToLastCreatedPattern(trap, corridor);

func instantiateRandomPattern(patterns):
	var index = floor(getRandomValue() * patterns.size());
	var node = patterns[index].instantiate();
	add_child(node);
	node.set_owner(get_tree().get_edited_scene_root());

	return node;

func instantiatePattern():

	if needHub and currentHubLength < 0:
		return null;

	var patterns = hubPatterns if needHub else corridorPatterns;
	var node = instantiateRandomPattern(patterns);
	
	if needHub:
		currentHubLength -= 1;
		needHub = false;
		currentCorridorLength = round(getRandomValue() * (corridorLength.y - corridorLength.x) + corridorLength.x);
	else:
		currentCorridorLength -= 1;
		if currentCorridorLength <= 0:
			needHub = true;

	return node;

func attachPatternToLastCreatedPattern(node, _last = null):
	_last = _last if _last != null else lastCreated;

	var joint = getRandomJoint(_last);
	var joint2 = getRandomJoint(node);

	if joint == null or joint2 == null:
		return false;

	var jy = joint.global_transform.basis.get_euler().y;
	var j2y = joint2.global_transform.basis.get_euler().y;
	var deltaAngle = jy - j2y;

	node.rotation.y += deltaAngle + PI;

	var jp1 = joint.global_transform.origin;
	var jp2 = joint2.global_transform.origin;

	node.global_transform.origin += jp1 - jp2;

	node.get_node("Entities").remove_child(joint2);
	lastCreated.get_node("Entities").remove_child(joint);
	joint2.free();
	joint.free();

	return true;

func hasFreeJoints(node: Node3D):
	return getRandomJoint(node) != null;

func getRandomValue():
	if randIndex == -1:
		randIndex = _current_seed - 1;

	randIndex += 1;

	var value = sin(randIndex * 123.3123)\
		+ tan(randIndex * 1231.123)\
		+ cos(randIndex * sin(randIndex + 12344.3123))\
		+ tan(randIndex * sin(randIndex + 12341.3123));
	return value - floor(value);

func getFreeJoints(node: Node3D):
	return node.get_node("Entities")\
		.get_children()\
		.filter(func(n): return n.name.begins_with("pattern_joint") and !n.busy);

func getRandomJoint(node: Node3D):
	var joints = getFreeJoints(node);
  
	if joints.size() == 0:
		return null;

	var index = floor(getRandomValue() * joints.size());
  
	return joints[index];

