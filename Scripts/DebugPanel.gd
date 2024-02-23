extends MarginContainer

var sceneRoot;
var values = {
	"Player speed": func():
		var p = Player.instance;
		if not p:
			return 0;

		return Vector2(p.velocity.x, p.velocity.z).length(),

	"isWallRunning": func():
		var p = Player.instance;
		if not p:
			return false;

		return p.isWallRunning,

	"runVelocity": func():
		var p = Player.instance;
		var movementVector = p.movementVector;
		var runVelocity = Vector2(movementVector.x, movementVector.z).length();
		return runVelocity,

	"tilt": func(): return Player.instance.tilt,
		
}

var nodes = {};

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in values.keys():
		var label = Label.new();
		label.name = key;
		nodes[key] = label;
		$VBoxContainer.add_child(label);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for key in values.keys():
		nodes[key].text = key + ": " + str(values[key].call());
