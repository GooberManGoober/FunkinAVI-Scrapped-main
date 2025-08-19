package states.menus;

import backend.discord.Discord;
//import base.dependency.FeatherDeps.ScriptHandler;
import backend.Paths;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import backend.menu.MusicBeatState;
import flixel.addons.display.FlxRuntimeShader;

using StringTools;

class SexState extends MusicBeatState
{
    
    var youGetNoBitches:FlxSprite;

    var background:FlxSprite;

    var noBitchCam:FlxCamera;
    var bgCam:FlxCamera;

    var upText:FlxText;
    var megaText:FlxText;
    var downText:FlxText;

    var monitor:FlxRuntimeShader;
    var bloom:FlxRuntimeShader;

    override function create() {

        noBitchCam = new FlxCamera();
        bgCam = new FlxCamera();
        bgCam.bgColor.alpha = 0;

        FlxG.cameras.reset(noBitchCam);
        FlxG.cameras.add(bgCam, false);
        FlxG.cameras.setDefaultDrawTarget(noBitchCam, true);

        super.create();

        bloom = new FlxRuntimeShader(Shaders.bloom, null, 120);
        monitor = new FlxRuntimeShader(Shaders.monitorFilter, null, 140);

        if (ClientPrefs.bloom)
        {
            noBitchCam.setFilters([
                new openfl.filters.ShaderFilter(bloom),
                new openfl.filters.ShaderFilter(monitor)
            ]);
        }
        else
        {
            noBitchCam.setFilters([
                new openfl.filters.ShaderFilter(monitor)
            ]);
        }

        background = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1000, FlxColor.BLACK);
        background.scale.set(5, 5);
        background.cameras = [bgCam];

        var eyes:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/HahaSadBoi'));
        eyes.scrollFactor.set(0, 0);
        eyes.screenCenter();
        eyes.updateHitbox();
        eyes.antialiasing = true;
        add(eyes);

        upText = new FlxText(0, 20, 0, 'Lmao, you thought this was on Psych Engine?', 32);
        upText.setFormat(Paths.font('DisneyFont.ttf'), 50, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        upText.screenCenter(X);
        add(upText);

        downText = new FlxText(0, 560, 0, 'Man, these psych kids be so down bad rn lmfao.\n(Press ESC to leave)', 32);
        downText.setFormat(Paths.font('DisneyFont.ttf'), 50, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        downText.screenCenter(X);
        add(downText);

        var scratch:FlxSprite = new FlxSprite();
        scratch.frames = Paths.getSparrowAtlas('Funkin_avi/filters/scratchShit');
        scratch.animation.addByPrefix('idle', 'scratch thing 1', 24, true);
        scratch.animation.play('idle');
        scratch.screenCenter();
        scratch.scale.x = 1.1;
        scratch.scale.y = 1.1;
        add(scratch);

        var grain:FlxSprite = new FlxSprite();
        grain.frames = Paths.getSparrowAtlas('Funkin_avi/filters/Grainshit');
        grain.animation.addByPrefix('idle', 'grains 1', 24, true);
        grain.animation.play('idle');
        grain.screenCenter();
        grain.scale.x = 1.1;
        grain.scale.y = 1.1;
        add(grain);

    }

    override function update(elapsed:Float) {

        if (controls.BACK)
		{
			lime.app.Application.current.window.alert('Bro think there was sex', 'L moment');
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
    }
}