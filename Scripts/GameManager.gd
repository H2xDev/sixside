class_name GameManager 
extends Node3D

static var instance: GameManager;

signal levelLoaded(levelName);

@onready var thread = Thread.new();
@export var startLevel: String = "level0";

var isActive = false;
var loadedLevel = null;
var loadedLevelName = '';

func _ready():
	GameManager.instance = self;

	LoadLevel(startLevel);
	PlaceLoadedLevel(Vector3.ZERO);

func LoadLevelThreaded(levelName: String):
	thread.start(LoadLevel.bind(levelName));
	
func LoadLevel(levelName: String):
	loadedLevelName = levelName;
	loadedLevel = load("res://Levels/" + levelName + '.tscn');
	call_deferred('emit_signal', 'levelLoaded', levelName);

func FreeLevel(levelName: String):
	var root = get_tree().get_root().get_node(NodePath('Gameplay'));
	var levelNode = root.get_node_or_null(levelName);

	if levelNode:
		levelNode.queue_free();

func PlaceLoadedLevel(origin: Vector3):
	if loadedLevel:
		var node = loadedLevel.instantiate();
		node.name = loadedLevelName;
		node.global_position = origin;
		add_child(node);
