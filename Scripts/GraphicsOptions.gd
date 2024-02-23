class_name GraphicsSettings extends VBoxContainer

static var instance = null;

var isVisible = false:
	get:
		return get_parent().get_parent().visible;

	set(value):
		get_parent().get_parent().visible = value;

var params = {
	"Resolution Scale": [
		"100%",
		"75%",
		"50%",
		"33%",
	],

	"VSync": [
		"Disabled",
		"Adaptive",
		"Enabled"
	],

	"Max FPS": [
		"60",
		"120",
		"144",
	],

	"Antialiasing": [
		"Off",
		"MXAA 2x",
		"MXAA 4x",
		"MXAA 8x",
		"FXAA",
		"TAA",
	],

	"SSAO": [
		"Very Low",
		"Low",
		"Medium",
		"High",
		"Ultra",
	],

	"Global Illumination": [
		"Full",
		"Half Resolution",
	],

	"Shadow Quality": [
		"Very Low",
		"Low",
		"Medium",
		"High",
		"Ultra"
	],
}

var panels = {};

var config = {};
var DEFAULTS = {
	"Resolution Scale": 1,
	"Fullscreen": 1,
	"VSync": 1,
	"Max FPS": 0,
	"Antialiasing": 5,
	"SSAO": 3,
	"Global Illumination": 1,
	"Texture Quality": 3,
	"Shadow Quality": 3,
	"Post Processing": 3
}


func LoadConfig():
	if FileAccess.file_exists("user://config.json"):
		var file = FileAccess.open("user://config.json", FileAccess.READ);
		var contents = file.get_as_text();
		file.close();
		config = JSON.parse_string(contents);
		ValidateConfig();
	else:
		config = DEFAULTS;
		SaveConfig();

func SaveConfig():
	var file = FileAccess.open("user://config.json", FileAccess.WRITE);
	file.store_string(JSON.stringify(config));
	file.close();

func OutputSettings():
	for param in params.keys():
		var split = HSplitContainer.new();
		add_child(split);

		var label = Label.new();
		label.text = param;
		label.size_flags_horizontal = SIZE_EXPAND_FILL;
		label.add_theme_font_size_override("font_size", 30);
		split.add_child(label);

		if typeof(params[param]) == TYPE_ARRAY:
			var menu = MenuButton.new();
			menu.text = params[param][0];
			menu.size_flags_horizontal = SIZE_EXPAND_FILL;
			menu.alignment = 0;
			menu.add_theme_font_size_override("font_size", 30);
			split.add_child(menu);

			panels[param] = menu;

			var popup = menu.get_popup();
			popup.index_pressed.connect(func(index): 
				config[param] = index;
				ApplyLabels();
			);

			for option in params[param]:
				popup.add_check_item(option);

func ApplyLabels():
	for key in panels.keys():
		var panel = panels[key];
		panel.text = params[key][config[key]];

func ValidateConfig():
	for key in DEFAULTS.keys():
		config[key] = config[key] if key in config else DEFAULTS[key];

func ApplyConfig():
	var scale = int(config["Resolution Scale"]) + 1;
	var viewport = get_viewport();
	viewport.scaling_3d_scale = 1.0 / scale;

	# V sync
	var vsync = [DisplayServer.VSYNC_DISABLED, DisplayServer.VSYNC_ADAPTIVE, DisplayServer.VSYNC_ENABLED][config["VSync"]]
	DisplayServer.window_set_vsync_mode(vsync);
	
	# Max FPS
	Engine.max_fps = [60, 120, 144][config["Max FPS"]];

	# Antialiasing
	var aa = config["Antialiasing"];

	if aa == 0:
		viewport.msaa_3d = Viewport.MSAA_DISABLED;
		viewport.use_taa = false;
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED;
	else:
		if aa < 4:
			viewport.msaa_3d = [
				Viewport.MSAA_DISABLED,
				Viewport.MSAA_2X,
				Viewport.MSAA_4X,
				Viewport.MSAA_8X,
			][aa];

		elif aa == 4:
			viewport.screen_space_aa = 1;
		elif aa == 5:
			viewport.msaa_3d = Viewport.MSAA_2X;
			viewport.use_taa = 1;

	# SSAO
	RenderingServer.environment_set_ssao_quality(config["SSAO"], true, 0.5, 2, 50, 300)

	# Shadows
	SetShadowsSettings(config["Shadow Quality"]);

	# SDFGI
	var sdfgi = config["Global Illumination"];

	if sdfgi == 1: # Low
		RenderingServer.gi_set_use_half_resolution(true);
	if sdfgi == 0: # High
		RenderingServer.gi_set_use_half_resolution(false);

	SaveConfig();

func SetShadowsSettings(index):
	RenderingServer.directional_soft_shadow_filter_set_quality(index);
	RenderingServer.positional_soft_shadow_filter_set_quality(index);

	if index == 0: # Very Low
		RenderingServer.directional_shadow_atlas_set_size(1024, true);
	if index == 1: # Low
		RenderingServer.directional_shadow_atlas_set_size(2048, true);
	if index == 2: # Medium (default)
		RenderingServer.directional_shadow_atlas_set_size(4096, true);
	if index == 3: # High
		RenderingServer.directional_shadow_atlas_set_size(8192, true);
	if index == 4: # Ultra
		RenderingServer.directional_shadow_atlas_set_size(16384, true);

func CloseSettings():
	isVisible = false;

func OpenSettings():
	isVisible = true;

func _ready():
	%Apply.pressed.connect(func():
		ApplyConfig();
		CloseSettings());
	%Close.pressed.connect(CloseSettings);
	CloseSettings();

	GraphicsSettings.instance = self;

	LoadConfig();
	ApplyConfig();
	OutputSettings();
	ApplyLabels();
