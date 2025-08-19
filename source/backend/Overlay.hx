package backend;

import openfl.Memory;
import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Overlay that displays FPS and memory usage.
 * 
 * Based on this tutorial:
 * https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
**/
class Overlay extends TextField
{
	var times:Array<Float> = [];
	var memPeak:UInt = 0;

	// display info
	static var displayFps = true;
	static var displayMemory = true;
	static var displayExtra = #if debug true #else false #end;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 18, 0xFFFFFF);
		text = "";

		addEventListener(Event.ENTER_FRAME, update);
	}

	public var textAfter:String = '';

	static function formatMemory(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		var dataTexts = ["B", "KB", "MB", "GB"];
		while (size > 1024 && data < dataTexts.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		var formatSize:String = formatAccuracy(size);
		return '${formatSize} ${dataTexts[data]}';
	}

	static function formatAccuracy(value:Float)
	{
		var conversion:Map<String, String> = [
			'0' => '0.00',
			'0.0' => '0.00',
			'0.00' => '0.00',
			'00' => '00.00',
			'00.0' => '00.00',
			'00.00' => '00.00', // gotta do these as well because lazy
			'000' => '000.00'
		]; // these are to ensure you're getting the right values, instead of using complex if statements depending on string length

		var stringVal:String = Std.string(value);
		var converVal:String = '';
		for (i in 0...stringVal.length)
		{
			if (stringVal.charAt(i) == '.')
				converVal += '.';
			else
				converVal += '0';
		}

		var wantedConversion:String = conversion.get(converVal);
		var convertedValue:String = '';

		for (i in 0...wantedConversion.length)
		{
			if (stringVal.charAt(i) == '')
				convertedValue += wantedConversion.charAt(i);
			else
				convertedValue += stringVal.charAt(i);
		}

		if (convertedValue.length == 0)
			return '$value';

		return convertedValue;
	}

	var peakMemory:Float;
	var curMemory:UInt;

	function update(_:Event)
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		curMemory = backend.MemoryRate.obtainMemory();
		if (curMemory >= peakMemory)
			peakMemory = curMemory;

		if (visible)
		{
			text = '' // set up the text itself
				+ (displayFps ? times.length + " FPS\n" : '') // Framerate
				+ (displayExtra ? 'Class Object Count: ' + FlxG.state.members.length + "\n" : '') // Current Game State
				+ (displayMemory ? '${formatMemory(Std.int(curMemory))} / ${formatMemory(Std.int(peakMemory))}\n' : ''); // Current and Total Memory Usage
		}
	}

	inline public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayMemory = shouldDisplayMemory;
	}
}
