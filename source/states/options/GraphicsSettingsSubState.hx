package states.options;

import flash.text.TextField;
import lime.utils.Assets;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import openfl.Lib;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Accessibility';
		rpcTitle = 'Accessibility Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			'If unchecked, disables shaders.\nIt\'s used for some visual effects, ^^and also CPU intensive for weaker PCs.^^', //Description
			'shaders', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('Bloom Effect', //Name
			'If unchecked, disables the bloom effect seen in certain songs.', //Description
			'bloom', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, ^^disables^^ some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Malfunction Effects',
			"Uncheck this to reduce amount of flashing lights on\nMalfunction!",
			'epilepsy',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Screen Shaking',
			"Uncheck this if you're sensitive to screen shakes!",
			'shaking',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}
}