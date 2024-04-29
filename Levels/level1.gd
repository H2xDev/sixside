extends Node3D

func BeginWakeupAnimation():
	var model = $act1_wakeup;
	var anim = $act1_wakeup/AnimationPlayer;
	var camera = $act1_wakeup/Armature/Skeleton3D/BoneAttachment3D/Camera3D;
	var cameraFrom = ValveIONode.namedEntities['begincamera_1'].camera;
	var pcamera = Player.instance.camera;
	
	anim.current_animation = 'default';
	anim.seek(0.1, true);
	anim.pause();
	
	Player.instance.isFrozen = true;
	model.visible = true;
	Player.instance.call_deferred("ViewTransitionTo", camera, 0.5, func():
		camera.make_current();
		anim.play(), { "cameraFrom": cameraFrom });
	
	anim.animation_finished.connect(func(_anim):
		var offset = pcamera.global_position - camera.global_position;
		Player.instance.global_position -= offset;
		Player.instance.ViewTransitionTo(camera, -0.25, func(): 
			Player.instance.isFrozen = false;
			model.call_deferred("queue_free");
			Player.instance.ResetCamera();
		));
