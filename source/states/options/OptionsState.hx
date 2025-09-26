package states.options;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Preferences', 'Accessibility', 'Visuals', 'Keybinds'];
	var optionsD:Array<String> = [
		"Define your Game Preferences, such as Note Skins or Judgements!", 
		"Make the game more accessible for yourself.", 
		"Define your Visuals.", 
		"Define your preferred keys for use during Gameplay."
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var infoText:FlxText;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Keybinds':
				openSubState(new states.options.ControlsSubState());
			case 'Visuals':
				openSubState(new states.options.GraphicsSettingsSubState());
			case 'Preferences':
				openSubState(new states.options.VisualsUISubState());
			case 'Accessibility':
				openSubState(new states.options.GameplaySettingsSubState());
		}
	}

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", "Changing settings...", "icon", "gear");
		#end

		if (ClientPrefs.shaders) {
			FlxG.camera.setFilters(
				[
					new openfl.filters.ShaderFilter(new FlxRuntimeShader(Shaders.grayScale, null, 140)),
					new openfl.filters.ShaderFilter(new FlxRuntimeShader(Shaders.monitorFilter, null, 140))
				]);
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Funkin_avi/menu/menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (125 * (i - Math.floor(options.length / 2)) + 75);
			grpOptions.add(optionText);
		}

		infoText = new FlxText(5, 0, 0, "", 32);
		infoText.setFormat(Paths.font("vcr.ttf"), 20, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = 0xFF000000;
		add(infoText);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState((FAVIPauseSubState.toOptions ? new PlayState() : new MainMenuState()));
			if (FAVIPauseSubState.toOptions)
			{
				FlxG.mouse.visible = false;
				FAVIPauseSubState.toOptions = false;
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		infoText.text = optionsD[curSelected];
		infoText.y = FlxG.height - infoText.height - 2; // line breaking;
		infoText.screenCenter(X);

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
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