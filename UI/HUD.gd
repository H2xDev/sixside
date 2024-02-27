class_name HUD extends Control

static var instance: HUD;

const MIN_INTERACTION_DISTANCE = 2.0;

var interactives = [];
var points = {};
var nodeToInteract = null;

@onready var pointRef = $InteractionPoint;

func _ready():
	HUD.instance = self;

func AppendInteractive(node: Node3D):
	if interactives.has(node):
		return;

	points[node.name] = pointRef.duplicate();
	points[node.name].visible = true;
	add_child(points[node.name]);
	interactives.append(node);

func RemoveInteractive(node: Node3D):
	if not interactives.has(node):
		return;

	points[node.name].queue_free();
	interactives.erase(node);
	points.erase(node.name);

func ProcessInteractionPoints():
	var p = Player.instance;
	var screenCenter = get_viewport().size / 2;

	nodeToInteract = interactives.filter(func(node):
		if not "forward" in node:
			return false;

		var d = node.global_position.distance_to(p.global_position);
		var playerSide = (node.global_position - p.camera.global_position).normalized();
		var cameraForward = -p.camera.global_transform.basis.z;
		var isPlayerAhead = node.forward.dot(playerSide) > 0.0;
		var isPlayerLooking = cameraForward.dot(playerSide) > 0.9;
		var isValid = d < MIN_INTERACTION_DISTANCE and isPlayerAhead and isPlayerLooking;

		points[node.name].modulate.a = 0.0;

		if isValid:
			points[node.name].position = p.camera.unproject_position(node.global_position);

		return isValid;
	).reduce(func(curr, node):
		var el = points[node.name];
		var currEl = points[curr.name] if curr != null else null;

		if not currEl:
			return node;

		var d1 = currEl.position.distance_to(screenCenter);
		var d2 = el.position.distance_to(screenCenter);

		return curr if d1 < d2 else node, null);

	if nodeToInteract:
		var el = points[nodeToInteract.name];
		el.modulate.a = 1.0;

func _process(_delta):
	ProcessInteractionPoints();	
