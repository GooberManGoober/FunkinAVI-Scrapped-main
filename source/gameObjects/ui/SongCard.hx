package gameObjects.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flash.display.BlendMode;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import haxe.Json;
import states.PlayState;
import sys.FileSystem;
import sys.io.File;

using flixel.util.FlxSpriteUtil;

typedef SongCardData =
{
	// Font Settings
	var font:String;
	var fontSize:Array<Int>;
	var fontColor:Array<Float>;
	var fontScale:Array<Float>;
	var fontAlpha:Array<Float>;
	var fontAlignType:String;
	var fontOffset:Array<Float>;

	// Base Settings
	var customArt:String;
	var playerIcon:String;
	var dadIcon:String;

	// Animation Settings
	var isAnimated:Bool;
	var animName:String;
	var animFramerate:Int;
	var isLooped:Bool;

	// Icon Settings
	var playerOffset:Array<Float>;
	var dadOffset:Array<Float>;
	var playerScale:Array<Float>;
	var dadScale:Array<Float>;
	var playerAlpha:Array<Float>;
	var dadAlpha:Array<Float>;

	// Extra Settings
	var cardAlpha:Array<Float>;
	var cardScale:Array<Float>;
	var cardOffsets:Array<Float>;
	var isScreenCenter:Bool;

	// Tween Settings
	var tweenIn:String;
	var tweenOut:String;
	var cardMoveIntro:Array<Float>;
	var cardMoveOutro:Array<Float>;
	var playerMoveIntro:Array<Float>;
	var playerMoveOutro:Array<Float>;
	var oppMoveIntro:Array<Float>;
	var oppMoveOutro:Array<Float>;
	var fontMoveIntro:Array<Float>;
	var fontMoveOutro:Array<Float>;

	// Special FX Settings
	var cardShader:String;
	var playerShader:String;
	var dadShader:String;
	var cardBlend:String;
	var playerBlend:String;
	var dadBlend:String;
}

@:deprecated("SongCard is no longer used/supported!")
class SongCard extends FlxSpriteGroup
{	
	// Pre-made Text
	public var composer:String = FreeplayState.getArtistName();
	public var songTitle:String = PlayState.SONG.song;

	// JSON Var Helpers
	public var fontStuff:String = "vcr";
	public var artFile:String = "test";
	public var fileName:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
	public var pIconName:String = PlayState.boyfriend.healthIcon;
	public var oIconName:String = PlayState.dad.healthIcon;
	public var fontColor:FlxColor = FlxColor.WHITE;
	public var fontSize:Int = 42;
	public var fontOffsetX:Float = 0;
	public var fontOffsetY:Float = 0;
	public var cardScaleX:Float = 1;
	public var cardScaleY:Float = 1;
	public var animName:String = "card";
	public var animFPS:Int = 24;
	public var alignString:String = "center";
	public var fontScaleX:Float = 1;
	public var fontScaleY:Float = 1;
	public var tweenInVal:String = "linear";
	public var tweenOutVal:String = "linear";
	public var cardIntroPosX:Float = 0;
	public var cardIntroPosY:Float = 0;
	public var playerIntroPosX:Float = 0;
	public var playerIntroPosY:Float = 0;
	public var oppIntroPosX:Float = 0;
	public var oppIntroPosY:Float = 0;
	public var fontIntroPosX:Float = 0;
	public var fontIntroPosY:Float = 0;
	public var cardOutroPosX:Float = 0;
	public var cardOutroPosY:Float = 0;
	public var playerOutroPosX:Float = 0;
	public var playerOutroPosY:Float = 0;
	public var oppOutroPosX:Float = 0;
	public var oppOutroPosY:Float = 0;
	public var fontOutroPosX:Float = 0;
	public var fontOutroPosY:Float = 0;
	public var cardShader:FlxRuntimeShader;
	public var cardShaderName:String = "vhs";
	public var playerShader:FlxRuntimeShader;
	public var pShaderName:String = "vhs";
	public var dadShader:FlxRuntimeShader;
	public var oShaderName:String = "vhs";
	public var cardBlend:String = "normal";
	public var playerBlend:String = "normal";
	public var dadBlend:String = "normal";
	
	// Card Data Categories
	public var cardData:SongCardData;
	public var cardAdvanced:SongCardData;
	public var cardAnimation:SongCardData;
	public var cardIcons:SongCardData;
	public var cardFont:SongCardData;
	public var cardTween:SongCardData;
	public var cardFX:SongCardData;

	// Base Card Setup
	public var cardTxt:FlxText;
	public var cardSprite:FlxSprite;

	// A bit of Decoration
	public var musicNoteIcon:FlxSprite;

	// Health Icons
	public var dadIcon:HealthIcon;
	public var playerIcon:HealthIcon;

	// For Special Anims or Effects
	public var isMalfunction:Bool = false;
	public var isBirthday:Bool = false;
	public var isCross:Bool = false;
  
  	function setupCardData()
  	{
		switch (PlayState.SONG.song)
		{
			case 'Isolated' | 'Lunacy' | 'Hunted' | 'Hunted Legacy' | "Isolated Legacy" | 'Lunacy Legacy' | 'Delusional Legacy':
				fontStuff = "DisneyFont.ttf";
			case 'Delusional':
				fontStuff = "satanFont.ttf";
			case 'Bless':
				fontStuff = "MagicOwlFont.otf";
			case 'Birthday':
				isBirthday = true;
				fontStuff = "DisneyFont.ttf";
			case "Dont Cross":
				isCross = true;
				fontStuff = "PhantomMuff Full Letters 1.1.5.ttf";
			case 'Cycled Sins' | 'Cycled Sins Legacy':
				fontStuff = "calibri-regular.ttf";
			case 'Mercy' | 'Mercy Legacy':
				fontStuff = "splatter.otf";
			case 'Malfunction':
				isMalfunction = true;
				fontStuff = "m40.ttf";
			default: 
				fontStuff = "vcr.ttf";
		}
		artFile = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
	}
	
	public function new()
	{
		super();

		setupCardData();

		cardSprite = new FlxSprite();

		dadIcon = new HealthIcon(oIconName, false);
		dadIcon.x = 260;
		dadIcon.y = 130;

		playerIcon = new HealthIcon(pIconName, true);
		playerIcon.x = 850;
		playerIcon.y = 460;

		cardSprite.makeGraphic(600, 350, 0xFF000000);
		cardSprite.screenCenter();

		cardTxt = new FlxText(cardSprite.x, cardSprite.y, 0, '- ${songTitle} -\nBy: ${composer}');
		cardTxt.setFormat(Paths.font('$fontStuff'), 42, FlxColor.WHITE, CENTER);
		cardTxt.screenCenter();

		cardSprite.alpha = 0.001;
		add(cardSprite);
		add(dadIcon);
		add(playerIcon);

		dadIcon.animation.curAnim.curFrame = 2;
		dadIcon.alpha = 0.001;

		playerIcon.animation.curAnim.curFrame = 2;
		playerIcon.alpha = 0.001;

		cardTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		cardTxt.alpha = 0.001;

		add(cardTxt);
		add(dadIcon);
		add(playerIcon);
	}
  
	// This is a function in case you want the card to show up later in the song instead of instantly
	public function playCardAnim(delaySet:Float = 0)
	{	
		FlxTween.tween(cardSprite, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: delaySet,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(cardSprite, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3.5});
			}
		});
		FlxTween.tween(dadIcon, {alpha: 1}, 2.2, {ease: FlxEase.sineInOut, startDelay: delaySet,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(dadIcon, {alpha: 0}, 2.2, {ease: FlxEase.sineInOut, startDelay: 3.5});
			}
		});
		FlxTween.tween(playerIcon, {alpha: 1}, 2.2, {ease: FlxEase.sineInOut, startDelay: delaySet,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(playerIcon, {alpha: 0}, 2.2, {ease: FlxEase.sineInOut, startDelay: 3.5});
			}
		});
		FlxTween.tween(cardTxt, {alpha: 1}, 2, {ease: FlxEase.sineInOut, startDelay: delaySet,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(cardTxt, {alpha: 0}, 2, {ease: FlxEase.sineInOut, startDelay: 3.5});
			}
		});
	}
  
  	override function add(Object:FlxSprite):FlxSprite
	{
		if (Std.isOfType(Object, FlxText))
			cast(Object, FlxText).antialiasing = ClientPrefs.globalAntialiasing;
		if (Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = ClientPrefs.globalAntialiasing;
		return super.add(Object);
	}

	public static function returnTweenEase(ease:String = '')
	{
		switch (ease.toLowerCase())
		{
			case 'linear':
				return FlxEase.linear;
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	public static function returnBlendMode(str:String):BlendMode
	{
		return switch (str)
		{
			case "normal": BlendMode.NORMAL;
			case "darken": BlendMode.DARKEN;
			case "multiply": BlendMode.MULTIPLY;
			case "lighten": BlendMode.LIGHTEN;
			case "screen": BlendMode.SCREEN;
			case "overlay": BlendMode.OVERLAY;
			case "hardlight": BlendMode.HARDLIGHT;
			case "difference": BlendMode.DIFFERENCE;
			case "add": BlendMode.ADD;
			case "subtract": BlendMode.SUBTRACT;
			case "invert": BlendMode.INVERT;
			case _: BlendMode.NORMAL;
		}
	}
}