@tool
class_name TriggerPush extends TriggerBase;

@onready var area = $Area3D;

var bodies = [];
@export var acceleration = Vector3.ZERO;

func _entity_ready():
	area.body_entered.connect(func(node):
		if "velocity" in node and not bodies.has(node):
			bodies.append(node);
	);
	
	area.body_exited.connect(func(node):
		if bodies.has(node):
			bodies.erase(node);
	);

func _process(delta):
	if Engine.is_editor_hint(): return;
	if not enabled: return;
	
	for body in bodies:
		body.velocity -= acceleration * delta;

func _apply_entity(e, c):
	super._apply_entity(e, c);
	
	acceleration = e.speed * get_movement_vector(e.pushdir) * config.import.scale;

	apply_shape_to(e, $Area3D/SolidCast);
