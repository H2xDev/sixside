extends Camera3D

var startRot = Vector3(0,0,0);
var wiggleValue = Vector3(0,0,0);

@export var frequency = 0.5;
@export var amplitude = 0.1;

func _ready():
	startRot = rotation;

func ProcessWiggle(delta):
	var t = (Time.get_ticks_msec() / 1000.0) * frequency;
	var newWiggle = Vector3(
		sin(t * 123.2334) + cos(t * 423.124),
		sin(t * 234.2334) + cos(t * 523.124),
		sin(t * 345.2334) + cos(t * 623.124)
	) * amplitude;

	rotation = startRot + newWiggle;

func _process(delta):
	ProcessWiggle(delta);
