package substates;

import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import openfl.system.System;
import sys.io.File;
import haxe.Json;
import openfl.Lib;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

/**
 * Pause Menu Data
 */
 typedef PauseData =
 {
	 var settings:Array<Dynamic>;
 }
class FAVIPauseSubState extends MusicBeatSubstate
{
	public static var toOptions:Bool = false;

	#if desktop
	public static var getPropertyFromDesktop = Sys.getEnv(Sys.systemName() == "Windows" ? "UserProfile" : "HOME") + "\\Desktop";
	public static var yourName = Sys.environment()["USERNAME"];
    #end

	var bg:FlxSprite;
	var levelInfo:FlxText;
	var menuItems:Array<String>;
	var funnyButton:FlxSprite;
	var curSelected:Int = 0;
	var buttonGroup:FlxTypedGroup<FlxSprite>;
	var songText:FlxSprite;
	var pauseMusic:FlxSound;
	var disc:FlxSprite;
	var songArt:FlxSprite;
	var songArtOutline:FlxSprite;
	public static var songName:FlxText;
	var countDown:FlxText;
	var hasResumed:Bool = false;
	var hasFinishedAnim:Bool = false;
	var pauseNameTxt:FlxText;
	var pauseSongStr:String;
	var satanTxt:FlxTypeText;
	var satanQuotes:Array<String> = [];

	var json:String = null;
	var array:Array<Dynamic>;
	var data:PauseData;

	var fuckingName:String;

	var creepyRed = new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, true, false, FlxColor.fromRGB(46, 0, 0)), '*');

	public function new(x:Float, y:Float, ?itemStack:Array<String>)
	{
		super();

		if (itemStack == null)
		{
			switch (PlayState.SONG.song)
			{
				case 'War Dilemma': itemStack = ['wd-continue', 'wd-restart', 'wd-settings', 'wd-escape'];
				case 'Malfunction': itemStack = ['mal-continue', 'mal-restart', 'mal-settings', 'rage'];
				case 'Birthday': itemStack = ['continue', 'restart', 'settings', 'leave'];
				default: itemStack = ['continue', 'restart', 'settings', 'escape'];
			}
		}

		PlayState.windowTimer.active = false;

		Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
		Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
		});
	

		// cool stuff
		toOptions = false;
		menuItems = itemStack;

		// Will use your discord username if you're connected while playing lmao
		if (DiscordClient.isInitialized && DiscordClient.discordName != "None")
			yourName = DiscordClient.discordName;

		satanQuotes = [
			"No, it is forbidden...",
			"You can't leave now...",
			"You're not going anywhere...",
			"You've come too far to leave now...",
			"The fun has just begun...",
			"Don't be afraid of a little mouse...",
			"Stay right where you are, " + yourName + "...",
			"He's already died many times...",
			"What difference will you leaving do?",
			"Leaving so soon?",
			"Something wrong, " + yourName + "?",
			"Are you scared?",
			"You've seen too much, I won't let you go yet...",
			"Do you know who I am?",
			"You're a coward, " + yourName + "...",
			"Not so fast, friend...",
			"Not so fast, " + yourName + "...",
			"Why leave so soon? You'll be back. *And we'll be waiting...*"
		];

		var randomPauseSong:String = "";
		var randomizer:Int = FlxG.random.int(1, 3);

		switch (randomizer)
		{
			case 1: 
				randomPauseSong = "shipTheFartYayHoorayv3v";
				pauseSongStr = "Ship The Fart Hooray < 3 (Distant Stars)";
			case 2: 
				randomPauseSong = "somberNight";
				pauseSongStr = "Ahh The Scary (Somber Night)";
			case 3: 
				randomPauseSong = "theWretchedTilezones";
				pauseSongStr = "The Wretched Tilezones (Simple Life)";
		}

		fuckingName = (PlayState.useFakeDeluName ? "Regret" : PlayState.SONG.song);

		var pauseArtAsset:String = CoolUtil.spaceToDash(fuckingName.toLowerCase());

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music("aviOST/pause/" + randomPauseSong), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		data = jsonStuff();

		if (data != null)
		{
			array = data.settings;
			//trace("Current Song: " + PlayState.SONG.song + " / Info Text: " + array[0] + " / Offsets : [" + array[1] + ", " + array[2] + "]");
		}
		else
		{
			//trace("Current Song: " + PlayState.SONG.song + " / DATA FILE MISSING! - USING PLACEHOLDER VARIABLES!");
			array = ["PLACEHOLDER\nCREDIT\nTEXT", 0, 0];
		}

		// all variable initial setups
		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		levelInfo = new FlxText(FlxG.width * 0.75 + array[2], 100, 0, "", 32);
		songArt = new FlxSprite(780, 110);
		songArtOutline = new FlxSprite(songArt.x - 20, songArt.y - 20 /*POV: you're lazy to do the math yourself*/).makeGraphic(890, 890, FlxColor.BLACK);
		disc = new FlxSprite(songArt.x + 75, songArt.y - 12).loadGraphic(Paths.image('Funkin_avi/pause/disc'));
		songName = new FlxText(FlxG.width * 0.78 + array[1], 10, 0, (PlayState.useFakeDeluName ? "Regret" : PlayState.SONG.song), 32);
		countDown = new FlxText(0, 0, 1280, "", 0);
		satanTxt = new FlxTypeText(0, 25, 1280, "");
		pauseNameTxt = new FlxText(5, 700, 1280, "Now Playing: " + pauseSongStr + " - ForFurtherNotice");

		// text stuff
		// I'M NOT DELUSIONAL, YOU'RE DELUSIONAL !!!!!!
		levelInfo.setFormat(Paths.font("disneyFreeplayFont.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songName.setFormat(Paths.font("disneyFreeplayFont.ttf"), 46, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		countDown.setFormat(Paths.font("disneyFreeplayFont.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		satanTxt.setFormat(Paths.font("disneyFreeplayFont.ttf"), 32, FlxColor.fromRGB(255, 117, 107), CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.fromRGB(92, 0, 26));
		satanTxt.borderSize = 2;
		pauseNameTxt.setFormat(Paths.font("disneyFreeplayFont.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		songArt.loadGraphic(Paths.imageAlbum(pauseArtAsset));

		// scales
		bg.scale.set(FlxG.width * 4, FlxG.height * 4);
		disc.scale.set(0.28, 0.28);
		songArt.scale.set(0.29, 0.29);
		songArtOutline.scale.set(0.29, 0.29); // this was easier for me to scale it off the ORIGINAL image size instead of just trying to get the exact graphic size of the song art being SCALED

		levelInfo.text = array[0];

		for (obj in [levelInfo, bg, songName, countDown])
			obj.scrollFactor.set();

		countDown.screenCenter();

		satanTxt.screenCenter(X);

		// alpha value setup
		for (obj in [bg, levelInfo, songName, pauseNameTxt])
			obj.alpha = 0.0001;

		countDown.visible = false;

		// fuck it. add everything
		for (obj in [bg, songName, levelInfo, pauseNameTxt, disc, songArtOutline, songArt])
			add(obj);

		// menu buttons
		buttonGroup = new FlxTypedGroup<FlxSprite>();
		add(buttonGroup);

		for (i in 0...menuItems.length)
		{
			songText = new FlxSprite(0, (10 * i) + 30).loadGraphic(Paths.image('Funkin_avi/pause/menuButtons/${menuItems[i]}'));
			songText.alpha = 0;
			buttonGroup.add(songText);
			FlxTween.tween(songText, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		}

		add(satanTxt);
		add(countDown);

		// tweens (bruh moment)
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartOut, onComplete: 
			function(twn:FlxTween)
				{
					hasFinishedAnim = true;
				}
			});
		FlxTween.tween(levelInfo, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(songName, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2});
		FlxTween.tween(disc, {x: disc.x - 300}, 0.8, {ease: FlxEase.quartOut});
		FlxTween.tween(disc, {angle: 360}, 2, {type: LOOPING});
		FlxTween.tween(songArt, {x: songArt.x - 110}, 0.8, {ease: FlxEase.quartOut});
		FlxTween.tween(songArtOutline, {x: songArtOutline.x - 110}, 0.8, {ease: FlxEase.quartOut});
		FlxTween.tween(pauseNameTxt, {alpha: 1}, 1, {ease:FlxEase.quartOut});

		var skinDirectory:String = 'Funkin_avi/pause/selectorSkin/';

		funnyButton = new FlxSprite(0, 0);
		switch (PlayState.SONG.song)
		{
			case 'War Dilemma':
				funnyButton.loadGraphic(Paths.image(skinDirectory + 'wd-selector'));
			case 'Malfunction':
				funnyButton.loadGraphic(Paths.image(skinDirectory + 'mal-selector'));
			default:
				funnyButton.loadGraphic(Paths.image(skinDirectory + 'select'));
		}
		add(funnyButton);

		funnyButton.alpha = 0;

		FlxTween.tween(funnyButton, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});

		changeSelection();
		lime.app.Application.current.window.title += " - {Paused}";
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		switch (menuItems[curSelected])
		{
			case 'continue':
				funnyButton.x = songText.x + 300;
				funnyButton.y = 120;
			case 'restart':
				funnyButton.x = songText.x + 310;
				funnyButton.y = 265;
			case 'settings':
				funnyButton.x = songText.x + 540;
				funnyButton.y = 420;
			case 'escape':
				funnyButton.x = songText.x + 300;
				funnyButton.y = 580;
			case 'leave':
				funnyButton.x = songText.x + 530;
				funnyButton.y = 580;
			case 'wd-continue':
				funnyButton.x = songText.x + 430;
				funnyButton.y = 124;
			case 'wd-restart':
				funnyButton.x = songText.x + 370;
				funnyButton.y = 280;
			case 'wd-settings':
				funnyButton.x = songText.x + 720;
				funnyButton.y = 430;
			case 'wd-escape':
				funnyButton.x = songText.x + 570;
				funnyButton.y = 585;
			case 'mal-continue':
				funnyButton.x = songText.x + 410;
				funnyButton.y = 104;
			case 'mal-restart':
				funnyButton.x = songText.x + 420;
				funnyButton.y = 250;
			case 'mal-settings':
				funnyButton.x = songText.x + 770;
				funnyButton.y = 410;
			case 'rage':
				funnyButton.x = songText.x + 960;
				funnyButton.y = 570;
		}

		updateSelection();

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (!hasResumed && hasFinishedAnim)
		{
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);
			if (accepted)
			{
				var daSelected:String = menuItems[curSelected];

				switch (daSelected)
				{
					case "continue" | 'wd-continue' | 'mal-continue':
						resumeGame();
					case "restart" | 'wd-restart' | 'mal-restart':
						remove(disc);
						restartSong();
					case "Back to Charter":
						remove(disc);
						MusicBeatState.switchState(new states.editors.ChartingState());
					case "Leave Charter Mode":
						remove(disc);
						PlayState.chartingMode = false;
						restartSong();
					case "settings" | 'wd-settings' | 'mal-settings':
						remove(disc);
						if (PlayState.useFakeDeluName)
							PlayState.useFakeDeluName = false;
						PlayState.pauseCountEnabled = false;
						toOptions = true;
						FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
						FlxG.mouse.visible = true;
						MusicBeatState.switchState(new states.options.OptionsState());
						FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
					case "escape" | 'wd-escape' | 'rage' | 'leave':
						switch (PlayState.SONG.song.toLowerCase())
						{
							case 'delusional':
								songText.shake(0.5, 1, 1);
								satanTxt.applyMarkup(satanQuotes[FlxG.random.int(0, satanQuotes.length - 1)], [creepyRed]);
								satanTxt.start(0.02, true);
							case 'birthday':
								remove(disc);
								MusicBeatState.switchState(new states.ManIHateYouSoMuchYouMadeMuckneySad()); // grah
							default:
								remove(disc);
								if (PlayState.useFakeDeluName)
									PlayState.useFakeDeluName = false;
								if (PlayState.pauseCountEnabled)
									PlayState.pauseCountEnabled = false;
								PlayState.seenCutscene = false;
								Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
								Lib.application.window.onClose.add(function() {
									DiscordClient.shutdown();
								});
								PlayState.cancelMusicFadeTween();
								PlayState.changedDifficulty = false;
								PlayState.chartingMode = false;
								PlayState.deathCounter = 0;

								if (PlayState.isStoryMode)
								{
									MusicBeatState.switchState(new StoryMenu());
									FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
								}
								else
								{
									switch (CoolUtil.dashToSpace(PlayState.SONG.song))
									{
										case "Rotten Petals" | "Curtain Call" | "Am I Real?" | "Your Final Bow" | "Seeking Freedom" | "Ahh the Scary (Somber Night)" | "Ship the Fart Yay Hooray <3 (Distant Stars)" | "The Wretched Tilezones (Simple Life)" | "A True Monster":
											FreeplayState.freeplayMenuList = 3;
											MusicBeatState.switchState(new FreeplayState());
										case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Delusional':
											states.menus.FreeplayState.freeplayMenuList = 0;
											MusicBeatState.switchState(new states.menus.FreeplayState());
										default:
											states.menus.FreeplayState.freeplayMenuList = (PlayState.SONG.song.toLowerCase().endsWith('legacy') || PlayState.SONG.song == "Isolated Beta" || PlayState.SONG.song == "Isolated Old") ? 2 : 1;
											MusicBeatState.switchState(new states.menus.FreeplayState()); // yeah, there's no way I'm making a case for EVERY fucking song in that menu, too much work!
									}
									FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
								}
								FlxG.mouse.load(Paths.image('UI/funkinAVI/mouses/Hand').bitmap);
						}
				}
			}
		}

		if (pauseMusic != null && pauseMusic.playing)
		{
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.1 * elapsed;
		}
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);

		if (menuItems != null)
			curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		var bullShit:Int = 0;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		if (PlayState.useFakeDeluName)
			PlayState.useFakeDeluName = false;
		if (PlayState.pauseCountEnabled)
			PlayState.pauseCountEnabled = false;
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;
		PlayState.instance.bf_vocals.volume = 0;
		PlayState.instance.opp_vocals.volume = 0;
		Lib.application.window.onClose.removeAll(); // goes back to normal hopefully
		Lib.application.window.onClose.add(function() {
			DiscordClient.shutdown();
		});

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	function resumeGame()
	{
		hasResumed = true;
		songName.alpha = 0;
		levelInfo.alpha = 0;
		satanTxt.text = "";
		if (PlayState.pauseCountEnabled)
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.6);
			FlxTween.tween(disc, {x: disc.x + 800}, 0.8, {ease: FlxEase.quartOut});
			FlxTween.tween(songArt, {x: songArt.x + 510}, 0.8, {ease: FlxEase.quartOut});
			FlxTween.tween(songArtOutline, {x: songArtOutline.x + 510}, 0.8, {ease: FlxEase.quartOut});
			FlxTween.tween(pauseNameTxt, {alpha: 0}, 0.75, {ease: FlxEase.quartOut});

			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
				countDown.visible = true;
				countDown.text = "3";
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
					countDown.text = "2";
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
						countDown.text = "1";
						FlxTween.tween(bg, {alpha: 0}, 1.2, {ease: FlxEase.quartInOut});
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'), 0.6);
							countDown.text = "Go!";
							FlxTween.tween(countDown, {alpha: 0}, 0.4);
							new FlxTimer().start(0.55, function(tmr:FlxTimer)
							{
								close();
								remove(disc);
								lime.app.Application.current.window.title = PlayState.windowName;
								PlayState.windowTimer.active = true;
							});
						});
					});
				});
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.6);
			FlxTween.tween(disc, {x: disc.x + 800}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(songArt, {x: songArt.x + 510}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(songArtOutline, {x: songArtOutline.x + 510}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
			FlxTween.tween(pauseNameTxt, {alpha: 0}, 0.04, {ease: FlxEase.quartOut});

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				close();
				remove(disc);
				lime.app.Application.current.window.title = PlayState.windowName;
				PlayState.windowTimer.active = true;
			});
		}
	}
	
	function updateSelection()
	{
		if (hasFinishedAnim)
		{
			buttonGroup.forEach(function(spr:FlxSprite)
			{
				spr.alpha = hasResumed ? 0 : 0.45;
			});
		
			if (buttonGroup.members[curSelected].alpha == 0.45)
				buttonGroup.members[curSelected].alpha = hasResumed ? 0 : 1;
		}
	}

	function jsonStuff()
	{
		switch (fuckingName)
		{
			case "Devilish Deal": json = CreditsData.devilishDeal;
			case "Isolated": json = CreditsData.isolated;
			case "Lunacy": json = CreditsData.lunacy;
			case "Delusional": json = CreditsData.delusional;
			case "Regret": json = CreditsData.regret;
			case "Hunted": json = CreditsData.hunted;
			case "Laugh Track": json = CreditsData.laughTrack;
			case "Bless": json = CreditsData.bless;
			case "Don't Cross!": json = CreditsData.dontCross3;
			case "War Dilemma": json = CreditsData.warDilemma;
			case "Twisted Grins": json = CreditsData.twistedGrins;
			case "Mercy": json = CreditsData.mercy;
			case "Cycled Sins": json = CreditsData.cycledSins;
			case "Malfunction": json = CreditsData.malfunction;
			case "Birthday": json = CreditsData.birthday;
		}
	
		if (json != null && json.length > 0)
			return cast Json.parse(json);
		else 
			return null;
	}
}