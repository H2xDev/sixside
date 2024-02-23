class_name GameState
extends Node

static var NO_CALLBACK = func(): pass;
static var player: Player;
static var isUsingUI: bool:
	set(value):
		if value:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
			Events.emit_signal("usingUiChanged");
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
			Events.emit_signal("usingUiChanged");

	get:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			return true;
		else:
			return false;

static var instance: GameState;

func _init():
	instance = self;

static func EnableMouseLook():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

static func DisableMouseLook():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

static func ShowMessage(msg: String):
	Events.emit_signal("showMessage", msg);

