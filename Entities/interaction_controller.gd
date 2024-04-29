@tool
extends ValveIONode

var camera = null;
var isActive = false;
var currentEntity = 0;
var entities = [];

var ent:
	get:
		if entities.size() == 0:
			return null;
		return entities[currentEntity];

func Begin(_param):
	var p = Player.instance;
	if not p: return;

	if not camera:
		camera = get_target(entity.camera);

	if not camera: return;

	p.isFrozen = true;
	p.ViewTransitionTo(camera.camera, 0.5, _OnBeginTweenEnd, {
		"trans": Tween.TRANS_SINE,
		"ease": Tween.EASE_IN_OUT,
	});

func Finish(_param):
	var p = Player.instance;
	if not p: return;

	p.ViewTransitionTo(camera.camera, -0.5, _OnFinishTweenEnd, {
		"trans": Tween.TRANS_SINE,
		"ease": Tween.EASE_IN_OUT,
	});

func _OnBeginTweenEnd():
	camera.SetOn(null);
	isActive = true;

func _OnFinishTweenEnd():
	var p = Player.instance;
	if not p: return;

	p.isFrozen = false;
	isActive = false;

func _process(dt):
	if not isActive:
		return;

	var p = Player.instance;
	if not p:
		return;

	if Input.is_action_just_pressed("left"):
		currentEntity -= 1;
		if currentEntity < 0:
			currentEntity = entities.size() - 1;
		return;

	if Input.is_action_just_pressed("right"):
		currentEntity += 1;
		if currentEntity > entities.size() - 1:
			currentEntity = 0;
		return;

	if Input.is_action_just_pressed("cancel"):
		Finish(null);
		return;

	if Input.is_action_just_pressed("interact"):
		TriggerInput();
		return;

	MoveCamera(dt);

func TriggerInput():
	if not ent:
		return;

	if not entity.inputName in ent: return;
		
	ent.call(entity.inputName, entity.param);

func MoveCamera(dt):
	if not ent: 
		return;

	var targetLook = ent.global_position - camera.global_position;
	var b = Basis.looking_at(targetLook, Vector3.UP);

	camera.camera.global_transform.basis = camera.camera.global_transform.basis.slerp(b, 10 * dt);

func _entity_ready():
	for i in range(1, 9):
		var prop = "ent" + str(i);
		if not prop in entity:
			continue;

		var _e = get_target(entity[prop]);
		if not _e:
			continue;

		entities.append(_e);
