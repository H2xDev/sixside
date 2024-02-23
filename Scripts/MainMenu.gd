extends VBoxContainer

func _ready():
	$Graphics.pressed.connect(func():
		GraphicsSettings.instance.OpenSettings());
	$Quit.pressed.connect(func():
		get_tree().quit());
