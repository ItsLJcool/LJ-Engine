package openfl.display;

import flixel.util.FlxStringUtil;
import haxe.Timer;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class FPS extends TextField {
	private var times:Array<Float>;

	private var memPeak:Float = 0;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000) {
		super();

		x = inX;

		y = inY;

		selectable = false;

		defaultTextFormat = new TextFormat("_sans", 12, inCol);

		text = "FPS: ";

		times = [];

		addEventListener(Event.ENTER_FRAME, onEnter);

		width = 300;

		height = 70;
	}

	private function onEnter(_) {
		var now = Timer.stamp();

		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var mem:Float = System.totalMemory;

		if (mem > memPeak)
			memPeak = mem;

		if (visible) {
			text = "FPS: "
				+ times.length
				+ "\nMEM: "
				+ FlxStringUtil.formatBytes(mem)
				+ "\nMEM peak: "
				+ FlxStringUtil.formatBytes(memPeak);
		}
	}
}
