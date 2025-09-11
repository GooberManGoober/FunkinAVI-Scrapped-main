package gameObjects.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.PlayState;

class SongCard extends FlxSpriteGroup
{	
	// Pre-made Text
	public var composer:String = FreeplayState.getArtistName();
	public var songTitle:String = PlayState.SONG.song;

	// JSON Var Helpers
	public var fontStuff:String = "vcr";
	public var pIconName:String = PlayState.boyfriend.healthIcon;
	public var oIconName:String = PlayState.dad.healthIcon;
	
	// Base Card Setup
	public var cardTxt:FlxText;
	public var cardSprite:FlxSprite;

	// A bit of Decoration
	public var musicNoteIcon:FlxSprite;

	// Health Icons
	public var dadIcon:HealthIcon;
	public var playerIcon:HealthIcon;
  
  	function setupCardData()
  	{
		switch (PlayState.SONG.song)
		{
			case 'Devilish Deal' | 'Isolated' | 'Lunacy' | 'Hunted' | 'Hunted Legacy' | "Isolated Legacy" | 'Lunacy Legacy' | 'Delusional Legacy':
				fontStuff = "DisneyFont.ttf";
			case 'Delusional':
				fontStuff = "satanFont.ttf";
			case 'Bless':
				fontStuff = "MagicOwlFont.otf";
			case 'Birthday':
				fontStuff = "DisneyFont.ttf";
			case "Dont Cross":
				fontStuff = "PhantomMuff Full Letters 1.1.5.ttf";
			case 'Cycled Sins' | 'Cycled Sins Legacy':
				fontStuff = "calibri-regular.ttf";
			case 'Mercy' | 'Mercy Legacy':
				fontStuff = "splatter.otf";
			case 'Malfunction':
				fontStuff = "m40.ttf";
			default: 
				fontStuff = "vcr.ttf";
		}
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
}