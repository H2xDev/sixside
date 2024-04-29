extends VBoxContainer

func _ready():
	var fadeBox = owner.get_node_or_null('FadeBox');
	var mPlayer = owner.get_node_or_null('AudioStreamPlayer');
	
	var showTween = create_tween();
	showTween.tween_property(fadeBox, 'modulate', Color(0, 0, 0, 0), 0.5);
	showTween.play();
	
	$Begin.pressed.connect(func():
		var tween = create_tween();
		tween.tween_property(fadeBox, 'modulate', Color(0, 0, 0, 1.0), 0.5);
		tween.parallel().tween_property(mPlayer, 'volume_db', linear_to_db(0.2), 0.5);
		
		tween.finished.connect(func():
			get_tree().change_scene_to_file('res://Scenes/Gameplay.tscn'));
		tween.play());
		
	$Graphics.pressed.connect(func():
		GraphicsSettings.instance.OpenSettings());
	$Quit.pressed.connect(func():
		get_tree().quit());
