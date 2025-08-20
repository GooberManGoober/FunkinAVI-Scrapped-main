package states.menus;

import flash.text.TextField;
import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import sys.thread.Mutex;
import sys.thread.Thread;
import openfl.media.Sound;
import backend.data.ClientPrefs;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	var curSongPlaying:Int = -1;
	private static var lastDifficultyName:String = '';

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var path:String = 'Funkin_avi/freeplay';

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var songDisplay:Array<FlxText> = [];
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var bg:Null<FlxSprite>;

	var camGame:FlxCamera; // Main camera (including shaders n shit)
	var camHUD:FlxCamera; // Objects
	var camOther:FlxCamera; // Gameplay Changers + Fade transitions

	var defaultCamZoom:Float = 1;
	var camZoomTween:FlxTween;

	var defaultShader2:FlxRuntimeShader;
	var smilesShader:FlxRuntimeShader;
	var mercyShader:FlxRuntimeShader;
	var mercyShader2:FlxRuntimeShader;	
	var getBlessed:FlxRuntimeShader;
	var glitchyStuff:FlxRuntimeShader;
	var chromAberration:FlxRuntimeShader;
	var urFucked:FlxRuntimeShader;
	var pixelShader:FlxRuntimeShader;
	var shaderTime:Float = 0;

	public static var freeplayMenuList = 0;

	public static var difficultyRank:String = 'HARD';
	public static var songArtist:String = "Unknown";

	var intendedColor:Int;
	var colorTween:FlxTween;
	var crossRandom:Int = FlxG.random.int(1, 11);

	var songText2:FlxText;
	var songText:Alphabet;

	// making this a public static var so the disc just doesn't stop moving at all when going in and out of this menu
	public static var bpm:Float = 1;

	public static var songInstPlaying:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Setting Up Category...";

		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

		/**
		 * how addSong() function works here:
		 * 
		 * Song Name - Week ID - Freeplay Icon Name - BG Color - Composer Name - Rank Name - Rank Color - Freeplay Icon Offset (only applies in the new menu UI, gimmicks description)
		 */

		// Categories, Shaders, and Songlist Setup
		switch (freeplayMenuList)
		{
			case 0: // Story Songs Menu
			{
				chromAberration = new FlxRuntimeShader(Shaders.aberration, null, 150);
				chromAberration.setFloat('aberration', 0.07);
				chromAberration.setFloat('effectTime', 0.005);

				addSong('Devilish Deal', 3, 'satanddNEW', FlxColor.fromRGB(65, 88, 94), 'obscurity', 'EASY', FlxColor.WHITE, [25, -18], "None");
				addSong('Isolated', 3, 'avier', FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [15, 0], "Modcharts that move notes on occasion.");
				addSong('Lunacy', 3, 'lunaavier', FlxColor.fromRGB(69, 54, 54), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), [15, 0], "Modcharts that may cause visual distortion.");
				addSong('Delusional', 3, 'deluavier', FlxColor.fromRGB(79, 32, 32), 'FR3SHMoure', 'INSANE', FlxColor.fromRGB(255, 110, 110), [15, 0], "Modcharts that may cause visual distortion");
			}
			case 1: // Extras Menu
			{		
				getBlessed = new FlxRuntimeShader(Shaders.bloom_alt, null, 120);
				glitchyStuff = new FlxRuntimeShader(Shaders.vignetteGlitch, null, 130);
				chromAberration = new FlxRuntimeShader(Shaders.aberration, null, 150);
				chromAberration.setFloat('aberration', 0.07);
				chromAberration.setFloat('effectTime', 0.005);
				mercyShader = new FlxRuntimeShader(Shaders.vhsFilter, null, 130);
				mercyShader2 = new FlxRuntimeShader(Shaders.cameraMovement, null, 150);
				urFucked = new FlxRuntimeShader(Shaders.theBlurOf87, null, 150);
				urFucked.setFloat('amount', 1);
				smilesShader = new FlxRuntimeShader(Shaders.tvStatic, null, 120);
				pixelShader = new FlxRuntimeShader(Shaders.unregisteredHyperCam2Quality, null, 140);
				pixelShader.setFloat('size', 7.5);

				addSong('Hunted', 3, (GameData.huntedLock != 'unlocked' && GameData.huntedLock != 'beaten' ? 'mysteryfp' : 'goofy'), FlxColor.fromRGB(94, 28, 35), 'JBlitz', 'NORMAL', FlxColor.fromRGB(255, 220, 220), (GameData.huntedLock == "beaten" || GameData.huntedLock == "unlocked" ? [24, -8] : [25, 0]), "Modcharts that may cause visual distortion.");
				addSong('Laugh Track', 3, (GameData.rickyLock != 'unlocked' && GameData.rickyLock != 'beaten' ? 'mysteryfp' : 'ricky'), FlxColor.fromRGB(181, 0, 0), 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.rickyLock == "beaten" || GameData.rickyLock == "unlocked" ? [20, -15] : [25, 0]), "None");
				addSong('Bless', 3, (GameData.blessLock != 'unlocked' && GameData.blessLock != 'beaten' ? 'mysteryfp' : 'noise'), FlxColor.WHITE, 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.blessLock == "beaten" || GameData.blessLock == "unlocked" ? [30, -10] : [25, 0]), "None");
				addSong("Don't Cross!", 3, (GameData.crossinLock != 'unlocked' && GameData.crossinLock != 'beaten' ? 'mysteryfp' : 'cross'), FlxColor.fromRGB(255, 0, 0), 'PualTheUnTruest', 'GOOD LUCK', FlxColor.fromRGB(201, 0, 0), (GameData.crossinLock == "beaten" || GameData.crossinLock == "unlocked" ? [23, -10] : [25, 0]), "Chart is randomized every attempt.");
				addSong('War Dilemma', 3, (GameData.warLock != 'unlocked' && GameData.warLock != 'beaten' ? 'mysteryfp' : 'ethernalg'), FlxColor.fromRGB(204, 41, 103), 'Sayan Sama & obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.warLock == "beaten" || GameData.warLock == "unlocked" ? [24, 1] : [25, 0]), "Modcharts that may cause visual distortion.");
				addSong('Twisted Grins', 3, (GameData.tgLock != 'unlocked' && GameData.tgLock != 'beaten' ? 'mysteryfp' : 'smile'), FlxColor.fromRGB(54, 38, 38), 'PualTheUnTruest', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.tgLock == "beaten" || GameData.tgLock == "unlocked" ? [25, -10] : [25, 0]), "Scroll speed changes & Modcharts that may cause visual distortion");
				addSong('Mercy', 3, (GameData.mercyLock != 'beaten' && GameData.mercyLock != 'beaten' ? 'mysteryfp' : 'walt'), FlxColor.fromRGB(176, 169, 116), 'Ophomix24', 'INSANE', FlxColor.fromRGB(255, 110, 110), (GameData.mercyLock == "beaten" || GameData.mercyLock == "unlocked" ? [27, -20] : [25, 0]), "Drains your health until death. Utilizes the mechanic keybind, highly recommend checking your controls setting before playing.");
				addSong('Cycled Sins', 3, (GameData.sinsLock != 'unlocked' && GameData.sinsLock != 'beaten' ? 'mysteryfp' : 'relapseNEW-pixel'), FlxColor.fromRGB(105, 30, 30), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187), (GameData.sinsLock == "beaten" || GameData.sinsLock == "unlocked" ? [24, -21] : [25, 0]), "Dodge Relapse Mouse's gunshots. Utilizes the mechanic keybind, highly recommend checking your controls setting before playing."); //messing with the saves for this later
				
				if (GameData.canAddMalfunction)
				{
					addSong('Malfunction', 3, (GameData.malfunctionLock != 'unlocked' && GameData.malfunctionLock != 'beaten' ? 'mysteryfp' : 'mal-pixel'), FlxColor.fromRGB(150, 149, 186), 'obscurity', null, FlxColor.WHITE, (GameData.malfunctionLock == "beaten" || GameData.malfunctionLock == "unlocked" ? [27, 0] : [25, 0]), "Contains extreme flashing lights, very unforgiving modcharts, life system & note gimmicks. Mechanics are enabled by default upon playing.\nGood luck."); // Because Malfunction is getting some major upgrades later
				}
				
				if ((GameData.birthdayLocky == 'beaten' || GameData.birthdayLocky == 'obtained') && GameData.birthdayLocky != "uninvited")
				{
					addSong('Birthday', 3, 'muckney', FlxColor.fromRGB(84, 255, 181), 'FR3SHMoure', 'PARTY', FlxColor.fromRGB(250, 234, 92), [15, -5], "Don't leave his party, you'll make him sad.");
				}
			}
			case 2: // Legacy Menu
			{
				addSong('Isolated Old', 3, (GameData.oldisolateLock != 'unlocked' && GameData.oldisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE, [0, 0], "");
				addSong('Isolated Beta', 3, (GameData.betaisolateLock != 'unlocked' && GameData.betaisolateLock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko', 'EASY', FlxColor.WHITE, [0, 0], "");
				addSong('Isolated Legacy', 3, (GameData.legacyILock != 'unlocked' && GameData.legacyILock != 'beaten' ? 'mysteryfp' : 'avierlegacy'), FlxColor.fromRGB(60, 60, 60), 'Toko & obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0], "");
				addSong('Lunacy Legacy', 3, (GameData.legacyLLock != 'unlocked' && GameData.legacyLLock != 'beaten' ? 'mysteryfp' : 'lunaold'), FlxColor.fromRGB(60, 60, 60), 'obscurity', 'NORMAL', FlxColor.fromRGB(255, 220, 220), [0, 0], "");
				addSong('Delusional Legacy', 3, (GameData.legacyDLock != 'unlocked' && GameData.legacyDLock != 'beaten' ? 'mysteryfp' : 'deluold'), FlxColor.fromRGB(60, 60, 60), 'FR3SHMoure', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
				addSong('Hunted Legacy', 3, (GameData.legacyHLock != 'unlocked' && GameData.legacyHLock != 'beaten' ? 'mysteryfp' : 'goofyold'), FlxColor.fromRGB(0, 60, 40), 'JBlitz', 'EASY', FlxColor.WHITE, [0, 0], "");
				addSong('Twisted Grins Legacy', 3, (GameData.legacyTLock != 'unlocked' && GameData.legacyTLock != 'beaten' ? 'mysteryfp' : 'smileold'), FlxColor.fromRGB(115, 86, 86), 'Sayan Sama', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
				addSong('Mercy Legacy', 3, (GameData.legacyWLock != 'unlocked' && GameData.legacyWLock != 'beaten' ? 'mysteryfp' : 'waltold'), FlxColor.fromRGB(153, 148, 112), 'obscurity', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
				addSong('Cycled Sins Legacy', 3, (GameData.legacySLock != 'unlocked' && GameData.legacySLock != 'beaten' ? 'mysteryfp' : 'relapseold-pixel'), FlxColor.fromRGB(115, 86, 86), 'JBlitz', 'HARD', FlxColor.fromRGB(255, 187, 187), [0, 0], "");
				addSong('Malfunction Legacy', 3, (GameData.legacyMLock != 'unlocked' && GameData.legacyMLock != 'beaten' ? 'mysteryfp' : 'mallegacy-pixel'), FlxColor.fromRGB(140, 120, 180), 'obscurity', 'INSANE', FlxColor.fromRGB(255, 110, 110), [0, 0], "");
			}
		}

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay Menu", "Loading Category...", "icon", "disc-player");
		#end

		mutex = new Mutex();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image(path + '/menuFreeplay'));
		add(bg);

		if (freeplayMenuList != 2)
		{
			AppIcon.changeIcon("newIcon");
		}

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			songText2 = new FlxText(0, 0, 570, songs[i].songName);
			songText = new Alphabet(100, (43 * i) + 120, songs[i].songName, true);
			
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);

			songText.isMenuItem = true;
			if (freeplayMenuList == 2)
				songText.screenCenter(X); 			
			songText.changeX = freeplayMenuList == 2 ? false : true;
			icon.sprTracker = songText;

			songText.targetY = 5;
			grpSongs.add(songText);

			songDisplay.push(songText2);
			add(songText2);

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
			
		// Basically an exact replica of the Funkin.avi V1 Freeplay Menu lol
		if (freeplayMenuList == 2)
		{
			AppIcon.changeIcon("legacyIcon");
		}
		
		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreBG.alpha = 0.6;
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		scoreText.cameras = [camHUD];
		scoreBG.cameras = [camHUD];
		diffText.cameras = [camHUD];
		add(scoreBG);
		add(diffText);
		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		//add(text);

		if(!ClientPrefs.lowQuality)
			{
				var scratchStuff:FlxSprite = new FlxSprite();
				scratchStuff.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
				scratchStuff.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
				scratchStuff.animation.play('idle');
				scratchStuff.screenCenter();
				scratchStuff.scale.x = 1.1;
				scratchStuff.scale.y = 1.1;
				add(scratchStuff);
	
				var grain:FlxSprite = new FlxSprite();
				grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
				grain.animation.addByPrefix('idle', 'grains 1', 24, true);
				grain.animation.play('idle');
				grain.screenCenter();
				grain.scale.x = 1.1;
				grain.scale.y = 1.1;
				add(grain);
	
				scratchStuff.cameras = [camHUD];
				grain.cameras = [camHUD];
			}
		
		if (!songInstPlaying) 
			Conductor.bpm = 98;

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>, gimmick:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, composer, rankName, rankColor, iconOffset, gimmick));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenu.weekCompleted.exists(leWeek.weekBefore) || !StoryMenu.weekCompleted.get(leWeek.weekBefore)));
	}

	function changeBotPlay(){
		ClientPrefs.gameplaySettings["botplay"] = (ClientPrefs.gameplaySettings["botplay"] == true) ? false : true;
		
		return;
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var bf_vocals:FlxSound = null;
	public static var opp_vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Conductor.songPosition = FlxG.sound.music.time;

		var isDontCross:Bool = songs[curSelected].songName == "Don't Cross!";

		if (FlxG.keys.justPressed.B) {
			changeBotPlay();
		}

		if (ClientPrefs.shaders) // bye bye lag
		{
			if (freeplayMenuList == 1)
			{
				shaderTime = Conductor.songPosition / 1000;

				glitchyStuff.setFloat('time', shaderTime);
				glitchyStuff.setFloat('prob', shaderTime);

				mercyShader.setFloat('time', shaderTime);
				mercyShader2.setFloat('time', shaderTime);

				smilesShader.setFloat('iTime', shaderTime);
				smilesShader.setFloat('uTime', shaderTime);
			}
		}

		if(songs[curSelected].songName == "Don't Cross!" && grpSongs.members[6] != null && grpSongs.members[6].exists)
			iconArray[3].shake(4, 30, 0.1);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_UP || controls.UI_DOWN)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeSongPlaying();
				changeDiff();
			}
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			threadActive = false;
			FlxG.sound.playMusic(Paths.music('aviOST/seekingFreedom'));
			MusicBeatState.switchState(new GeneralMenu());
			FlxG.mouse.visible = true;
		}

		if (accepted)
		{
			songInstPlaying = false;
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			if (isDontCross) // I've been suffering trying to get the randomizer to work with hardcoded charts only to find out this piece of shit was causing the crash oh my FUCKING GOD I'M GONNA RIP MY FUCKING HEAD OFF!!!!! (don)
				songLowercase = "dont-cross";
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty); //fuck fuck fuck fuck fuck fuck
			trace(poop);

			threadActive = false;

			PlayState.SONG = Song.loadFromJson(poop, songLowercase, crossRandom);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}

			// ignore that im using the short "if" thing is for less code stuff due to lazyness lol
			FlxTween.tween(FlxG.camera, {zoom: freeplayMenuList == 2 ? 1 : 2.5}, freeplayMenuList == 2 ? 0.0001 : 1.5, {ease: FlxEase.expoInOut});
			new flixel.util.FlxTimer().start(freeplayMenuList == 2 ? 0.0001 : 0.7, function(e)
			{
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			});

			FlxG.sound.music.volume = 0;
		}

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();

		if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
		}
		super.update(elapsed);
	}

	function spawnMusicalNote()
		{
			final musicNote = new FlxSprite(800, 130, Paths.image('favi/ui/bdaynotes/note_${FlxG.random.int(1, 3)}', 'shared'));
			musicNote.scale.set(.65, .65);
			musicNote.updateHitbox();
			musicNote.antialiasing = ClientPrefs.globalAntialiasing;
			musicNote.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
			musicNote.cameras = [camHUD];
			add(musicNote);
	
			musicNote.alpha = 0;
			FlxTween.tween(musicNote, {alpha: 1}, .5, {ease: FlxEase.sineInOut});
	
			final randomTimer = FlxG.random.float(3.5, 7);
	
			musicNote.velocity.x = -FlxG.random.float(120, 230);
	
			FlxTween.tween(musicNote, {y: musicNote.y - 70}, FlxG.random.float(1, 4), {ease: FlxEase.sineInOut, type: 4});
			FlxTween.tween(musicNote, {alpha: 0}, randomTimer, {ease: FlxEase.sineInOut, startDelay: 1.5, onComplete: tweeeeeee -> {
				remove(musicNote);
				musicNote.destroy();
			}});
		}

	// i would remove this but too lazy to remove this function from other menus rn so I don't get any compiling errors lol
	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		if(bf_vocals != null) {
			bf_vocals.stop();
			bf_vocals.destroy();
		}
		if(opp_vocals != null) {
			opp_vocals.stop();
			opp_vocals.destroy();
		}
		vocals = null;
		bf_vocals = null;
		opp_vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		difficultyRank = songs[curSelected].rankName;
		diffText.color = songs[curSelected].rankColor;

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = 'RANK: ' + difficultyRank;// display the text
		positionHighscore();
	}

	override function beatHit() {
		super.beatHit();
	}

	var shittyTmr:FlxTimer;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.4);

		if (shittyTmr != null)
			shittyTmr.cancel();

		shittyTmr = new FlxTimer().start(0.88, function(tmr:FlxTimer) {
			shittyTmr = null;
		});

		if(ClientPrefs.flashing)
			FlxG.camera.flash(FlxColor.BLACK, 0.1);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var songName:String = songs[curSelected].songName;
		songArtist = songs[curSelected].composer;

		switch (freeplayMenuList)
		{
			case 0: 
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Story Menu- " + songName + ' - Composed by: ' + songArtist;
				}
			case 1:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Extras Menu - " + songName + " - Composed by: " + songArtist;
				}
			case 2:
				{
					lime.app.Application.current.window.title = "Funkin.avi - Freeplay: Legacy Menu - " + songName + " - Composed by: " + songArtist;
				}
		}

		#if DISCORD_ALLOWED
		#if DEV_BUILD
		DiscordClient.changePresence("Freeplay Menu", "It's a secret...", "icon", "disc-player");
		#else
		DiscordClient.changePresence("Freeplay Menu", "Picking Song: " + songs[curSelected].songName, "icon", "disc-player");
		#end
		#end
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (s in 0...songDisplay.length)
			songDisplay[s].alpha = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			
				item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		if (ClientPrefs.shaders) // to prevent lag
		{
			// ah yes, formatting made by vsc itself - jason
			switch (CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase()))
			{
				case 'bless':
					FlxG.camera.shake(0.01, 0.001);
					if(!ClientPrefs.lowQuality) {
						FlxG.camera.setFilters(
							[
								new ShaderFilter(getBlessed), 
								new ShaderFilter(defaultShader2)
							]);
					}

				case 'malfunction':
					if(!ClientPrefs.lowQuality) {
						FlxG.camera.setFilters(
							[
								new ShaderFilter(glitchyStuff), 
								new ShaderFilter(chromAberration),
								new ShaderFilter(defaultShader2)
							]);
					}
					FlxG.camera.shake(0.01, 0.001);

				case "don't-cross!":
					if(!ClientPrefs.lowQuality) {
						FlxG.camera.setFilters(
							[
								new ShaderFilter(chromAberration),
								new ShaderFilter(defaultShader2)
							]);
					}

					if(ClientPrefs.shaking)
					FlxG.camera.shake(0.015, FlxMath.MAX_VALUE_FLOAT);

				case 'scrapped':
					if(!ClientPrefs.lowQuality) {
						FlxG.camera.setFilters(
							[
								new ShaderFilter(smilesShader),
								new ShaderFilter(chromAberration),
								new ShaderFilter(defaultShader2)
							]);
					}
					FlxG.camera.shake(0.01, 0.001);

				case 'cycled-sins':
					if(!ClientPrefs.lowQuality) {
						FlxG.camera.setFilters(
							[
								new ShaderFilter(chromAberration),
								new ShaderFilter(mercyShader2),
								new ShaderFilter(defaultShader2)
							]);
					}

				case 'twisted-grins' | 'resentment' | 'mortiferum-risus':
					if(!ClientPrefs.lowQuality)
						FlxG.camera.setFilters(
							[
								new ShaderFilter(smilesShader),
								new ShaderFilter(defaultShader2)
							]);

				case 'mercy' | 'affliction':
					if(!ClientPrefs.lowQuality) {
					FlxG.camera.setFilters(
						[
							new ShaderFilter(mercyShader),
							new ShaderFilter(mercyShader2),
							new ShaderFilter(defaultShader2)
						]);
					}
				
				case 'birthday':
					if(!ClientPrefs.lowQuality)
						FlxG.camera.setFilters([new ShaderFilter(defaultShader2)]);
					FlxG.camera.shake(0.01, 0.001);
				
				case 'devilish-deal' | 'delusional':
					if(!ClientPrefs.lowQuality)
						FlxG.camera.setFilters([new ShaderFilter(chromAberration), new ShaderFilter(defaultShader2)]);
					FlxG.camera.shake(0.01, 0.001);

				default:
					if (freeplayMenuList != 2)
					{
						if(!ClientPrefs.lowQuality)
							FlxG.camera.setFilters([new ShaderFilter(defaultShader2)]);
					}
					FlxG.camera.shake(0.01, 0.001);
			}
		}

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = "Hard";
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		difficultyRank = songs[curSelected].rankName;
		diffText.color = songs[curSelected].rankColor;

		diffText.text = 'RANK: ' + difficultyRank;// display the text
		positionHighscore();

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		changeSongPlaying();
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	function getBPM():Float
	{
		switch (CoolUtil.spaceToDash(songs[curSelected].songName.toLowerCase()))
		{
			case 'devilish-deal': bpm = 90;
			case 'isolated' | 'isolated-legacy': bpm = 165;
			case 'lunacy': bpm = 188;
			case 'delusional' | 'bless' | 'birthday': bpm = 175;
			case 'hunted' | 'malfunction-legacy' | 'war-dilemma' | 'mercy' | 'mercy-legacy' | 'hunted-legacy': bpm = 160;
			case 'laugh-track': bpm = 180;
			case 'malfunction': bpm = 166;
			case 'twisted-grins': bpm = 390;
			case "don't-cross!": bpm = 140;
			case 'cycled-sins': bpm = 161;
			case 'isolated-beta' | 'isolated-old': bpm = 120;
		}
		return bpm;
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
						return;

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							var inst:Sound;

							if (songs[curSelected].songName == "Don't Cross!")
								inst = Paths.inst("dont-cross", CoolUtil.difficulties[curDifficulty]);
							else
								inst = Paths.inst(songs[curSelected].songName, CoolUtil.difficulties[curDifficulty]);

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
							}
						}
					}
				}
			});
		}
		songThread.sendMessage(curSelected);
	}

	public static function getDiffRank():String
		{
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				case 'devilish-deal' | 'hunted-legacy' | 'isolated-beta' | 'isolated-old': difficultyRank = 'EASY';
				case 'isolated' | 'neglection' | 'resentment' | 'lunacy-legacy' | 'hunted' | 'mortiferum-risus' | 'isolated-legacy': difficultyRank = 'NORMAL';
				case 'delusional' | 'mercy' | 'malfunction-legacy': difficultyRank = 'INSANE';
				case 'malfunction': difficultyRank = 'null';
				case "dont-cross": difficultyRank = 'GOOD LUCK';
				case 'birthday': difficultyRank = 'PARTY';
				case "rotten-petals" | "seeking-freedom" | "your-final-bow" | "curtain-call" |"am-i-real?" | "a-true-monster" | "ship-the-fart-yay-hooray-<3-(distant-stars)" | "ahh-the-scary-(somber-night)" | "the-wretched-tilezones-(simple-life)": difficultyRank = "MANIA";
				default: difficultyRank = 'HARD';
			}
			return difficultyRank;
		}

		public static function getArtistName():String
		{
			switch (PlayState.SONG.song)
			{
				case "Devilish Deal" | "Isolated" | "Lunacy" | "Malfunction" | "Lunacy Legacy" | "Malfunction Legacy" | "Mercy Legacy": songArtist = "obscurity.";
				case "Delusional" | "Birthday" | "Delusional Legacy" | "A True Monster": songArtist = "FR3SHMoure";
				case "Hunted" | "Hunted Legacy" | "Cycled Sins" | "Cycled Sins Legacy": songArtist = "JBlitz";
				case "Laugh Track" | "Dont Cross" | "Bless": songArtist = "PualTheUnTruest";
				case "Isolated Beta" | "Isolated Old" | "Rotten Petals" | "Seeking Freedom" | "Your Final Bow": songArtist = "Yama Haki/Toko";
				case "Twisted Grins Legacy" | "Curtain Call": songArtist = "Sayan Sama";
				case "Isolated Legacy": songArtist = "Toko & obscurity.";
				case "War Dilemma": songArtist = "Sayan Sama & obscurity.";
				case "Mercy": songArtist = "Ophomix24";
				case "Twisted Grins": songArtist = "ForFurtherNotice";
				case "Ship the Fart Yay Hooray <3 (Distant Stars)" | "Ahh the Scary (Somber Night)" | "The Wretched Tilezones (Simple Life)": songArtist = "ForFurtherNotice";
				default: songArtist = "Unknown";
			}
			return songArtist;
		}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var composer:String = "Unknown";
	public var rankName:String = "";
	public var rankColor:FlxColor = FlxColor.WHITE;
	public var iconOffset:Array<Int> = [0, 0];
	public var gimmicksTxt:String = "Unknown";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, composer:String, rankName:String, rankColor:FlxColor, iconOffset:Array<Int>, gimmicksTxt:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.composer = composer;
		this.rankName = rankName;
		this.rankColor = rankColor;
		this.iconOffset = iconOffset;
		this.gimmicksTxt = gimmicksTxt;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}