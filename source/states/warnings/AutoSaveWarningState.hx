package states.warnings;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.ui.AutoSaveLogo;

class AutoSaveWarningState extends FlxState
{
	var warningText:FlxText;

	var doofinschmirtzFactinator:Array<String> = [
		"This update took almost 2 years to develop!",
		"I bet nobody's reading this...",
		"This mod contains 40k+ lines of code.",
		"The update wasn't suppose to be nearly 3 hours long at first.",
		"This mod runs on Another Engine that isn't Psych Engine now!",
		"This mod was made by a group of 50 people!",
		"Malfunction was originally NEVER suppose to be in the game.",
		"Some characters showcased in the game are in fact original ideas!",
		"You are delusional.",
		"No facts for now :)",
		"We kicked out 30 members throughout development.",
		"This mod has about 200+ messages on the title and menu screens!"
	];

	var saveDetectorImage:AutoSaveLogo;

	public static function load()
	{
		GameData.loadShit(); // Collect Any Data
		CoolUtil.createCoreFile();
		#if windows
		CppAPI.darkMode();
		#end

		ClientPrefs.loadDefaultKeys();
		FlxG.save.bind('funkin', CoolUtil.getSavePath());

        PlayerSettings.init();
		ClientPrefs.loadPrefs();
		Highscore.load();
	}

	override function create()
	{
		CoolUtil.createCoreFile();

		super.create();

		#if windows
		CppAPI.darkMode();
		#end

		#if DISCORD_RPC
		DiscordClient.changePresence("FUN FACT:", doofinschmirtzFactinator[FlxG.random.int(0, doofinschmirtzFactinator.length - 1)], 
			'icon', 'mouse');
		#end

		openfl.Lib.application.window.title = "Funkin.avi: Scrapped - The Show Will Begin Shortly...";

		GameData.loadShit(); // Collect Any Data

		warningText = new FlxText(0, 0, FlxG.width,
			'WARNING:\nThis game contains an auto save system.\nIf you see this logo right below\n^DON\'T TURN OFF THE DEVICE!^', 44);
		warningText.setFormat(Paths.font('vcr.ttf'), 37, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		warningText.screenCenter().y -= 40;
		warningText.alpha = 0;
		warningText.applyMarkup(warningText.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, true), '^')]);
		add(warningText);

		FlxTween.tween(warningText, {alpha: 1, y: warningText.y + 40}, 2, {ease: FlxEase.quadInOut});

		if (!ClientPrefs.lowQuality)
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
		}

		saveDetectorImage = new AutoSaveLogo('Funkin_avi/autoSave', FlxG.width * 0.78, FlxG.height * 0.69); // funny number
		add(saveDetectorImage);

		new FlxTimer().start(10, _ ->
		{
			FlxTween.tween(saveDetectorImage, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
			FlxTween.tween(warningText, {alpha: 0, y: warningText.y + 100}, 2, {
				ease: FlxEase.quadInOut,
				onComplete: __ ->
				{
					if (GameData.hasSeenWarning)
						MusicBeatState.switchState(new TitleState());
					else
						MusicBeatState.switchState(new WarningState());
				}
			});
		});
	}
}
