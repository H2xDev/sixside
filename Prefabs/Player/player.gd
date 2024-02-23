class_name Player extends CharacterBody3D

static var instance: Player = null;

signal ladderExited;
signal ladderEntered;
signal waterEntered;
signal waterExited;
signal wallRunStart;

enum Abilities {
	NONE,
	FLASHLIGHT,
	JETPACK,
}

@onready var head = $Head;
@onready var camera = $Head/Camera3D as Camera3D;
@onready var shape = $CollisionShape3D as CollisionShape3D;
@onready var capsule = $CollisionShape3D.shape;
@onready var audioPlayer = $AudioPlayer as AudioStreamPlayer3D;
@onready var headPosition: Vector3 = head.transform.origin;
@onready var world = get_world_3d();
@onready var waterPostprocess = %WaterPostprocess;

@export_category("Options")
@export_range(0.1, 1, 0.1) var mouseSensitivity: float = 0.1;
@export var viewBobbing: bool = true;
@export var fov: float = 80;

@export_category("Movement")
@export var jumpHeight: float = 1;
@export var acceleration: float = 40.0;
@export var maxSpeed: float = 10.0;
@export var frictionGround: float = 30.0;
@export var frictionAir: float = 0.0;
@export var ladderSpeed: float = 200.0;
@export var sprintRate: float = 1.5;
@export var crouchRate: float = 0.7;
@export var crouchHeightRate: float = 0.5;
@export var waterFriction: float = 5.0;
@export var waterRate: float = 0.5;
@export var canWalljump: bool = false;
@export var canDoubleJump: bool = false;
@export var wallJumpForwardStrength: float = 1.5;
@export var wallJumpUpStrength: float = 1.0;
@export var wallJumpSideStrength: float = 4.0;
@export var wallRunningGravityAffection = 8.0;

# Default values
@onready var capsuleHeight = capsule.height;
@onready var headHeight = head.position.y;

# Other variables
var waterAABB: AABB;

# Physics vars
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var bobbingTime: float = 0.0;
var moveRate: float = 1.0;
var movementVector: Vector3 = Vector3.ZERO;

# View bobbing vars
var collectedLandingImpact: float = 0.0;
var landingImpact: float = 0.0;
var smoothedLandingImpact: float = 0.0;
var cameraRecoil: Vector3 = Vector3.ZERO;
var crouchOffset: Vector3 = Vector3.ZERO;
var wallJumpCooldown: float = 0.0;
var isDoubleJumped: bool = false;
var shake = 0.0;
const COOLDOWN_WALLJUMP = 0.25;

var noclip: bool = false;
var isOnLadder: bool = false;
var isInWater: bool = false;

var isObsacleAboveHead:
	get:
		return not not Utils \
				.Raycast(world, head.global_position, Vector3.UP, 1.0, [self]);

var isCrouching: bool = false:
	set(value):
		if isCrouching == value:
			return;
		
		if not value and isObsacleAboveHead:
			return;

		isCrouching = value;
		AnimateCrouch(value);
	get:
		return isCrouching;

var _footstepPlayed = false;

var isControlsDisabled: bool:
	get:
		return not camera.current \
				or GameState.isUsingUI;

var headOffset:
	get:
		return head.global_transform.origin - global_transform.origin;

var forwardVector:
	get:
		return -global_transform.basis.z;

var forwardHead: Vector3:
	get:
		return -head.global_transform.basis.z;

var rightHead: Vector3:
	get:
		return head.global_transform.basis.x;

var rightVector:
	get:
		return global_transform.basis.x;

var isGrabbingLadder:
	get:
		var origin = global_transform.origin + Vector3.UP * 0.01;
		return not not Utils.Raycast(world, origin, forwardVector, 1.0, [self]);

var aheadFloorPoint:
	get:
		if Utils.Raycast(world, global_transform.origin + Vector3.UP * 0.1, forwardVector, 1.0, [self]):
			return null;

		var origin = global_transform.origin + forwardVector * 0.5;
		var result = Utils.Raycast(world, origin, Vector3.DOWN, 1.0, [self]);

		return result.position if result else null;

var jumpForce:
	get:
		return sqrt(jumpHeight * gravity * 2);

var smoothTilt: float = 0.0;
var tilt: float:
	get:
		if not canWalljump or is_on_floor() or wallJumpCooldown > 0.0:
			return 0.0;

		var origin = global_transform.origin + Vector3.UP * 0.1;

		var resultRight = Utils.Raycast(world, origin, -rightVector, 0.5, [self]);
		var resultLeft = Utils.Raycast(world, origin, rightVector, 0.5, [self]);

		if not resultRight and not resultLeft:
			return 0.0;

		if not resultRight:
			return -1.0;
		
		return 1.0;

var _isWallRunning = false;
var isWallRunning:
	get:
		if not canWalljump:
			return false;

		var runVelocity = Vector2(velocity.x, velocity.z).length();
		var newState = abs(tilt) > 0.0 and runVelocity > maxSpeed * 0.7;

		if newState != _isWallRunning:
			_isWallRunning = newState;

			if newState:
				emit_signal('wallRunStart');

		return newState;

func ProcessFov(delta):
	var multiplier = 0.9 + moveRate / 10;
	camera.fov = lerp(camera.fov, fov * multiplier, delta * 7);

func ProcessMouseLook(event):
	if (isControlsDisabled):
		return;

	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity));
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSensitivity));
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89));

func DoJump():
	isDoubleJumped = false;

	velocity.y = jumpForce if not isWallRunning else jumpForce * 0.5;
	wallJumpCooldown = 0.2;

	SoundManager.PlayRandomSound(global_position + Vector3.UP * 0.1, SoundManager.FootstepsSounds.GROUND, 0.1, 1.0, "footstep");

func DoWallJump():
	if not canWalljump:
		return;

	velocity.y = jumpForce * wallJumpUpStrength;
	velocity += forwardVector * wallJumpForwardStrength;
	velocity += rightHead * tilt * wallJumpSideStrength;
	isDoubleJumped = false;
	wallJumpCooldown = COOLDOWN_WALLJUMP;

	PlayLandingSound();


func DoDoubleJump():
	if not canDoubleJump:
		return;

	if wallJumpCooldown > 0:
		return;

	if isDoubleJumped:
		return;

	velocity = forwardVector * jumpForce * 4.0;
	velocity.y = jumpForce;
	isDoubleJumped = true;

	SoundManager.PlaySound(global_position + Vector3.UP * 0.1, SoundManager.JETPACK, 0.1, 1.0);

func ProcessCooldowns(delta):
	wallJumpCooldown = wallJumpCooldown - delta if wallJumpCooldown > 0 else 0;
	shake = lerp(shake, 0.0, delta * 5);

func ProcessJump(): 
	if noclip:
		return;

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			DoJump();
		else: if isWallRunning:
			DoWallJump();
		else:
			DoDoubleJump();

func PlayLandingSound():
	var p = global_position + Vector3.UP * 0.1;

	SoundManager.PlayRandomSound(p, SoundManager.FootstepsSounds.GROUND, 0.1, 1.0, "footstep");
	Anime.Animate(0.05, Anime.NO_FUNC_CB, func():
		SoundManager.PlayRandomSound(p, SoundManager.FootstepsSounds.GROUND, 0.1, 1.0, "footstep"));

func ProcessGravity(delta):
	if noclip or isInWater:
		return;

	var gravityRate = 0.0 if isWallRunning else 1.0;

	if not is_on_floor():
		velocity.y -= gravity * delta * gravityRate;
		if velocity.y < 0:
			collectedLandingImpact = -velocity.y;
	else:
		if collectedLandingImpact > 0:
			if (collectedLandingImpact > 2):
				PlayLandingSound();
			landingImpact = collectedLandingImpact;
			collectedLandingImpact = 0;


func ProcessNoclip():
	if Input.is_action_just_pressed("noclip"):
		noclip = not noclip;
		shape.disabled = noclip;
		GameState.ShowMessage("Noclip enabled" if noclip else "Noclip disabled");

func ProcessCameraRecoil(delta):
	cameraRecoil = lerp(cameraRecoil, Vector3.ZERO, delta * 10);

func ProcessSurfaceMovement(delta: float, inputDir: Vector2):
	var isSprinting = true;
	var targetRate = 1.0 if not isSprinting else sprintRate;
	
	moveRate = lerp(moveRate, targetRate, delta * 4);

	var isFrictionAllowed = is_on_floor();

	var currentFriction = frictionGround if isFrictionAllowed else frictionAir;
	var frictionFactor = 1 / (1 + currentFriction * delta);

	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized() * moveRate;
	var computedAcceleration = ((maxSpeed / delta) / frictionFactor - (maxSpeed / delta)) / 2.0;
	var currentAcceleration = computedAcceleration if is_on_floor() else 0.0;

	movementVector = direction * currentAcceleration;
	movementVector.y = 0;

	velocity += movementVector * delta;
	velocity.x *= frictionFactor;
	velocity.z *= frictionFactor;

func ProcessLadderMovement(delta: float, inputDir: Vector2):
	var right = global_transform.basis.x;

	if not is_on_floor():
		velocity = Vector3.ZERO;
	velocity += Vector3.DOWN * inputDir.y * ladderSpeed * delta;
	velocity += right * inputDir.x * ladderSpeed * delta;

func ProcessNoclipMovement(delta: float, inputDir: Vector2):
	var d = inputDir * acceleration * sprintRate * delta;
	velocity += camera.global_transform.basis.z * d.y + camera.global_transform.basis.x * d.x;
	velocity *= 1 / (1 + 10 * delta);

func ProcessWaterMovement(delta: float, inputDir: Vector2):
	var d = inputDir * acceleration * waterRate * delta;

	velocity += camera.global_transform.basis.z * d.y + camera.global_transform.basis.x * d.x;
	velocity *= 1 / (1 + waterFriction * delta);

func ProcessMovement(delta: float):
	var inputDir = Input.get_vector("left", "right", "forward", "backward") if not isControlsDisabled else Vector2(0, 0);
	
	if not noclip and not isInWater:
		ProcessSurfaceMovement(delta, inputDir);

		if isOnLadder and isGrabbingLadder:
			ProcessLadderMovement(delta, inputDir);
	else:
		if noclip:
			ProcessNoclipMovement(delta, inputDir);

		if isInWater:
			ProcessWaterMovement(delta, inputDir);


func MoveAndSlide():
	move_and_slide();

func ProcessInteraction():
	if isControlsDisabled:
		return;

	if Input.is_action_just_pressed("interact"):
		var origin = head.global_transform.origin;
		var direction = -head.global_transform.basis.z;
		var result = Utils.Raycast(world, origin, direction, 2, [self]);

		if not result:
			return;

		if result.collider.has_signal("interact"):
			result.collider.emit_signal("interact");
		else:
			var _owner = result.collider.get_owner();
			if _owner and _owner.has_signal("interact"):
				_owner.emit_signal("interact");

func ProcessCrouch():
	isCrouching = Input.is_action_pressed("crouch");

func AnimateCrouch(forwards):
	var targetHeight = capsuleHeight * crouchHeightRate;
	var targetY = headHeight * (1 - crouchHeightRate);
	var currentEase = "EaseOutCircle" if forwards else "EaseInCircle";

	capsule.height = targetHeight if forwards else capsuleHeight;
	shape.position.y *= crouchHeightRate if forwards else 1 / crouchHeightRate;

	landingImpact += 5 if forwards else -5;

	var process = func(percent, _backwards):
		if forwards != isCrouching:
			return true;

		percent = Anime[currentEase].call(1 - percent);
		crouchOffset.y = -targetY * percent;

	Anime.Animate(0.5, process, Anime.NO_FUNC, forwards);

func ProcessViewBobbing(delta):
	smoothTilt = lerp(smoothTilt, tilt, delta * 10);

	if is_on_floor() or isWallRunning:
		var bobbingMultiplier = 0.9 + moveRate / 5;
		var wallrunningMultiplier = 1.25 if isWallRunning else 1.0;

		bobbingTime += delta * 4 * velocity.length() * wallrunningMultiplier;
		smoothedLandingImpact = lerp(smoothedLandingImpact, landingImpact, delta * 10);
		landingImpact = lerp(landingImpact, 0.0, delta * 10);
	
		var bobbingOffset = abs(sin(bobbingTime / 2) * 0.05 * bobbingMultiplier);
		var verticalOffset = bobbingOffset - smoothedLandingImpact / 20;
		var horizontalOffset = cos(bobbingTime / 2) * 0.025;

		var sndPos = global_position + Vector3.UP * 0.1 - rightHead * tilt;
	
		if bobbingOffset < 0.01 and not _footstepPlayed:
			SoundManager.PlayRandomSound(sndPos, SoundManager.FootstepsSounds.GROUND, 0.01, 1.0, "footstep");
			_footstepPlayed = true;
	
		if bobbingOffset > 0.04:
			_footstepPlayed = false;
		
		if viewBobbing:
			head.transform.origin = headPosition + Vector3(horizontalOffset, verticalOffset, 0) + cameraRecoil + crouchOffset;

	var cameraAdditionRotation = Vector3(
		-smoothedLandingImpact * 0.02,
		0.0,
		-smoothTilt * 0.2 + sin(Time.get_ticks_msec() / 75.0) * smoothedLandingImpact * 0.01);

	var shakeRotation = Vector3(
		sin(Time.get_ticks_msec() * 123.123),
		cos(Time.get_ticks_msec() * 435.345),
		sin(Time.get_ticks_msec() * 345.345)) * shake / 100.0;
	camera.rotation = cameraAdditionRotation + shakeRotation;

func ResetCamera():
	camera.make_current();

func MakeTransitionToCamera(
	targetCamera: Camera3D,
	onEnd: Callable = func(): pass,
	duration: float = 0.5,
	easeForwards: Callable = Anime.EaseOutCircle,
	easeBackwards: Callable = Anime.EaseInCircle,
):
		var startPos = camera.global_transform.origin;
		var startRot = camera.global_transform.basis;
		var startFov = camera.fov;

		var endPos = targetCamera.global_transform.origin;
		var endRot = targetCamera.global_transform.basis;
		var endFov = targetCamera.fov;

		var processAnimation = func(percent, backwards):
			var p = easeForwards.call(percent) if not backwards else easeBackwards.call(percent);

			targetCamera.global_transform.origin = lerp(startPos, endPos, p);
			targetCamera.global_transform.basis = startRot.slerp(endRot, p);
			targetCamera.fov = lerp(startFov, endFov, p);

		Anime.Animate(duration, processAnimation, onEnd);

		return func(_onEnd: Callable = func(): pass, newDuration = duration):
			Anime.Animate(
				newDuration,
				processAnimation,
				func():
					_onEnd.call();
					ResetCamera()
					targetCamera.global_transform.origin = endPos;
					targetCamera.global_transform.basis = endRot;
					targetCamera.fov = endFov,
				true
			);


func ApplyRotation(targetBasis: Basis):
	head.rotation.x = targetBasis.get_euler().x;
	rotation.y = targetBasis.get_euler().y;

func MoveTo(point: Vector3):
	var startPos = global_transform.origin;

	Anime.Animate(0.25, func (percent, _b):
		velocity = Vector3.ZERO;
		percent = Anime.EaseInOutCubic(percent);
		global_transform.origin = lerp(startPos, point, percent));

func ProcessWaterpostProcess():
	if not isInWater:
		return;

	var isCameraUnderwater = waterAABB.has_point(head.global_position - Vector3.UP * 0.1);

	if not waterPostprocess:
		return;

	if waterPostprocess.visible != isCameraUnderwater:
		waterPostprocess.visible = isCameraUnderwater;

func ApplyPostprocessWaterParams(sourceWaterMesh: MeshInstance3D):
	isInWater = true;

	if not waterPostprocess:
		return;
	
	waterAABB = sourceWaterMesh.get_aabb().abs();
	waterAABB.position += sourceWaterMesh.global_transform.origin;

	var sourceMaterial = sourceWaterMesh.get_surface_override_material(0);
	var sourceColor = sourceMaterial.get_shader_parameter("deepWaterColor");
	var sourceDepth = sourceMaterial.get_shader_parameter("depthFactor");

	waterPostprocess.material_override.set_shader_parameter("deepWaterColor", sourceColor);
	waterPostprocess.material_override.set_shader_parameter("depthFactor", sourceDepth);

# INPUTS

func EnableWalljumpAbility(_param = null):
	canWalljump = true;

func DisableWalljumpAbility(_param = null):
	canWalljump = false;

func EnableDoubleJumb(_param = null):
	canDoubleJump = true;

func DisableDoubleJump(_param = null):
	canDoubleJump = false;

func Shake(args):
	args = args.split(" ");
	var duration = float(args[0]);
	var amp = float(args[1]);

	Anime.Animate(duration, func(_a, _b): shake = amp);

func _input(event):
	ProcessMouseLook(event);

func _ready():
	Player.instance = self;
	ValveIONode.define_alias('!player', self);

	$Sprite3D.free();
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

	ladderEntered.connect(func ():
		isOnLadder = true);

	ladderExited.connect(func ():
		MoveTo(aheadFloorPoint) if aheadFloorPoint else null;
		isOnLadder = false);

	waterEntered.connect(ApplyPostprocessWaterParams);
	
	waterExited.connect(func ():
		isInWater = false);

	wallRunStart.connect(func ():
		velocity.y = 0.0);

func _process(delta):
	ProcessCrouch();
	ProcessInteraction();
	ProcessFov(delta);
	ProcessNoclip();
	ProcessWaterpostProcess();
	ProcessCooldowns(delta);

func _physics_process(delta):
	ProcessGravity(delta);
	ProcessJump();
	ProcessMovement(delta);
	ProcessViewBobbing(delta);
	MoveAndSlide();
