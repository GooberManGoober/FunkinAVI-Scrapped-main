package states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.ShaderFilter;

using StringTools;

class EpicSelectorWOOO extends MusicBeatState {

	var freeplayCats:Array<String>;
	var grpCats:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var BG:FlxSprite;
	var defaultShader2:FlxRuntimeShader;
    override function create(){

		freeplayCats = ['Story', 'Extras', 'Legacy'];

        BG = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/freeplay/menuFreeplay'));
		BG.updateHitbox();
		BG.screenCenter();
		add(BG);

		 #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay Menu", "Choosing Category...", 'icon', 'disc-player');
		#end

		defaultShader2 = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

		if(!ClientPrefs.lowQuality) {
			FlxG.camera.setFilters(
			[
				new ShaderFilter(defaultShader2)
			]);
		}

		Application.current.window.title = "Funkin.avi: Scrapped - Freeplay: Category Menu";

        grpCats = new FlxTypedGroup<Alphabet>();
		add(grpCats);
        for (i in 0...freeplayCats.length)
        {
			var catsText:Alphabet = new Alphabet(90, 320, freeplayCats[i], true);
            catsText.targetY = i;
			catsText.isMenuItem = true;
			grpCats.add(catsText);
		}

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
		}

		changeSelection();
        super.create();
    }

	override public function update(elapsed:Float)
	{
		if (controls.UI_UP_P) 
			changeSelection(-1);
		
		if (controls.UI_DOWN_P) 
			changeSelection(1);

		if (controls.BACK) {
			Conductor.bpm = (50);
			FreeplayState.songInstPlaying = false;
			FlxG.sound.play(Paths.sound("cancelMenu"));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('aviOST/rottenPetals'));
		}

		if (controls.ACCEPT)
		{
            FreeplayState.freeplayMenuList = curSelected;
			MusicBeatState.switchState(new FreeplayState());
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) 
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = freeplayCats.length - 1;
		if (curSelected >= freeplayCats.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpCats.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

		FlxG.sound.play(Paths.sound('funkinAVI/menu/scrollSfx'));
	}
}