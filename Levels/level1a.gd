extends Node3D

func PlayFallingAnimation():
	var tcamera = $act1_fall/Armature/Skeleton3D/BoneAttachment3D/Camera3D;
	var anim = $act1_fall/AnimationPlayer;
	anim.current_animation = "Armature|urdf_fbxAction|Base Layer";
	anim.seek(0.1, true);
	anim.pause();
	Player.instance.isFrozen = true;
	
	Player.instance.call_deferred("ViewTransitionTo", tcamera, 0.25, func():
		$walkwayAnimation.play("fallenWalkway");
		anim.play();
		$act1_fall.visible = true;
		$act1_fall/Armature/Skeleton3D/BoneAttachment3D/Camera3D.make_current();
	);

func PlaySpawnAnimation():
	var node = $act1_portalFall;
	var tcamera = $act1_portalFall/Armature/Skeleton3D/BoneAttachment3D/Camera3D;
	var pcamera = Player.instance.camera;
	var anim = $act1_portalFall/AnimationPlayer;

	anim.current_animation = "Armature|mixamo_com|Layer0";
	node.visible = true;
	tcamera.make_current();

	Player.instance.isFrozen = true;

	anim.animation_finished.connect(
		func(_name):
			var offset = pcamera.global_position - tcamera.global_position;
			Player.instance.isFrozen = false;
			Player.instance.global_position -= offset;

			Player.instance.call_deferred("ViewTransitionTo", tcamera, -0.5, func():
				node.visible = false;
				pcamera.make_current();
			);
	)

