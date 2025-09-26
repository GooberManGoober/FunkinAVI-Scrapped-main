package backend.data;

import flixel.input.keyboard.FlxKey;

class ClientPrefs 
{
	//Preferences
	public static var arrowAlpha:Float = 0.8;
	public static var holdAlpha:Float = 0.6;
	public static var splashAlpha:Float = 0.6;
	public static var songCards:Bool = true;
	public static var hideHud:Bool = false;
	public static var flashing:Bool = true;
	public static var epilepsy:Bool = true;
	public static var shaking:Bool = true;
	public static var camZooms:Bool = true;
	public static var scoreZoom:Bool = true;
	public static var healthBarAlpha:Float = 1;
	public static var showFPS:Bool = true;
	public static var debugInfo = false;
	public static var comboStacking = true;

	//Accessibility
	public static var controllerMode:Bool = false;
	public static var downScroll:Bool = false;
	public static var mechanics:Bool = true;
	public static var ghostTapping:Bool = true;
	public static var noReset:Bool = false;
	public static var autoPause = true;
	public static var pauseCountdown = false;
	public static var hitsoundVolume:Float = 0;
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	//Visuals
	public static var lowQuality:Bool = false;
	public static var globalAntialiasing:Bool = true;
	public static var shaders:Bool = true;
	public static var bloom:Bool = true;
	public static var useGPUCaching = false;
	public static var framerate:Int = 60;

	//Other
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];

	//Unused Vars
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var noteOffset:Int = 0;
	
	public static var checkForUpdates:Bool = true;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];
	public static var comboOffset:Array<Int> = [0, 0, 0, 0];

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	public static function saveSettings() {
		var settings:FlxSave = new FlxSave();
		settings.bind('settings', CoolUtil.getSavePath());

		settings.data.downScroll = downScroll;
		settings.data.middleScroll = middleScroll;
		settings.data.opponentStrums = opponentStrums;
		settings.data.showFPS = showFPS;
		settings.data.flashing = flashing;
		settings.data.globalAntialiasing = globalAntialiasing;
		settings.data.lowQuality = lowQuality;
		settings.data.shaders = shaders;
		settings.data.bloom = bloom;
		settings.data.framerate = framerate;
		settings.data.pauseCountdown = pauseCountdown;
		settings.data.camZooms = camZooms;
		settings.data.songCards = songCards;
		settings.data.noteOffset = noteOffset;
		settings.data.hideHud = hideHud;
		settings.data.arrowHSV = arrowHSV;
		settings.data.ghostTapping = ghostTapping;
		settings.data.scoreZoom = scoreZoom;
		settings.data.noReset = noReset;
		settings.data.healthBarAlpha = healthBarAlpha;
		settings.data.arrowAlpha = arrowAlpha;
		settings.data.holdAlpha = holdAlpha;
		settings.data.splashAlpha = splashAlpha;
		settings.data.comboOffset = comboOffset;
		settings.data.useGPUCaching = useGPUCaching;
		settings.data.achievementsMap = Achievements.achievementsMap;
		settings.data.henchmenDeath = Achievements.henchmenDeath;

		settings.data.ratingOffset = ratingOffset;
		settings.data.debugInfo = debugInfo;
		settings.data.sickWindow = sickWindow;
		settings.data.goodWindow = goodWindow;
		settings.data.badWindow = badWindow;
		settings.data.safeFrames = safeFrames;
		settings.data.gameplaySettings = gameplaySettings;
		settings.data.controllerMode = controllerMode;
		settings.data.hitsoundVolume = hitsoundVolume;
		settings.data.checkForUpdates = checkForUpdates;
		settings.data.comboStacking = comboStacking;
		settings.data.autoPause = autoPause;
	
		settings.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls', CoolUtil.getSavePath()); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Controls saved!");
	}

	public static function loadPrefs() {
		var settings:FlxSave = new FlxSave();
		settings.bind('settings', CoolUtil.getSavePath());
		
		if(settings.data.downScroll != null) {
			downScroll = settings.data.downScroll;
		}
		if(settings.data.middleScroll != null) {
			middleScroll = settings.data.middleScroll;
		}
		if(settings.data.opponentStrums != null) {
			opponentStrums = settings.data.opponentStrums;
		}
		if(settings.data.showFPS != null) {
			showFPS = settings.data.showFPS;
			if(Main.infoCounter != null) {
				Main.infoCounter.visible = showFPS;
			}
		}
		if(settings.data.flashing != null) {
			flashing = settings.data.flashing;
		}
		if(settings.data.debugInfo != null) {
			debugInfo = settings.data.debugInfo;
		}
		if(settings.data.autoPause != null) {
			autoPause = settings.data.autoPause;
		}
		if(settings.data.globalAntialiasing != null) {
			globalAntialiasing = settings.data.globalAntialiasing;
		}
		if(settings.data.lowQuality != null) {
			lowQuality = settings.data.lowQuality;
		}
		if(settings.data.pauseCountdown != null) {
			pauseCountdown = settings.data.pauseCountdown;
		}
		if(settings.data.shaders != null) {
			shaders = settings.data.shaders;
		}
		if(settings.data.bloom != null) {
			bloom = settings.data.bloom;
		}
		if(settings.data.framerate != null) {
			framerate = settings.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if(settings.data.camZooms != null) {
			camZooms = settings.data.camZooms;
		}
		if(settings.data.songCards != null) {
			songCards = settings.data.songCards;
		}
		if(settings.data.hideHud != null) {
			hideHud = settings.data.hideHud;
		}
		if(settings.data.noteOffset != null) {
			noteOffset = settings.data.noteOffset;
		}
		if(settings.data.arrowHSV != null) {
			arrowHSV = settings.data.arrowHSV;
		}
		if(settings.data.ghostTapping != null) {
			ghostTapping = settings.data.ghostTapping;
		}
		if(settings.data.scoreZoom != null) {
			scoreZoom = settings.data.scoreZoom;
		}
		if(settings.data.noReset != null) {
			noReset = settings.data.noReset;
		}
		if(settings.data.healthBarAlpha != null) {
			healthBarAlpha = settings.data.healthBarAlpha;
		}
		if(settings.data.arrowAlpha != null) {
			arrowAlpha = settings.data.arrowAlpha;
		}
		if(settings.data.holdAlpha != null) {
			holdAlpha = settings.data.holdAlpha;
		}
		if(settings.data.splashAlpha != null) {
			splashAlpha = settings.data.splashAlpha;
		}
		if(settings.data.comboOffset != null) {
			comboOffset = settings.data.comboOffset;
		}
		
		if(settings.data.ratingOffset != null) {
			ratingOffset = settings.data.ratingOffset;
		}
		if(settings.data.sickWindow != null) {
			sickWindow = settings.data.sickWindow;
		}
		if(settings.data.goodWindow != null) {
			goodWindow = settings.data.goodWindow;
		}
		if(settings.data.badWindow != null) {
			badWindow = settings.data.badWindow;
		}
		if(settings.data.useGPUCaching != null) {
			useGPUCaching = settings.data.useGPUCaching;
		}
		if(settings.data.safeFrames != null) {
			safeFrames = settings.data.safeFrames;
		}
		if(settings.data.controllerMode != null) {
			controllerMode = settings.data.controllerMode;
		}
		if(settings.data.hitsoundVolume != null) {
			hitsoundVolume = settings.data.hitsoundVolume;
		}
		if(settings.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = settings.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		// flixel automatically saves your volume!
		if(settings.data.volume != null)
		{
			FlxG.sound.volume = settings.data.volume;
		}
		if (settings.data.mute != null)
		{
			FlxG.sound.muted = settings.data.mute;
		}
		if (settings.data.checkForUpdates != null)
		{
			checkForUpdates = settings.data.checkForUpdates;
		}
		if (settings.data.comboStacking != null)
			comboStacking = settings.data.comboStacking;

		var save:FlxSave = new FlxSave();
		save.bind('controls', CoolUtil.getSavePath());
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
