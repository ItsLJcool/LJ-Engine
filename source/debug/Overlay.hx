package debug;

import flixel.FlxG;
import flixel.math.FlxMath;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

using StringTools;

class Overlay extends Sprite {
	private var title:TextField;

	public function new() {
		super();
		title = new TextField();
		title.autoSize = LEFT;
		title.selectable = false;
		title.textColor = 0xFFFFFFFF;
		title.defaultTextFormat = new TextFormat("vcr", 16); // figure out font lator
		title.text = 'LJ Engine (PlaceHolder Name) | ${Main.engineVersion}';
		title.y += 15;
		addChild(title);

		visible = true;
		toggleOverlay();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
			switch (e.keyCode) {
				case Keyboard.F6:
					toggleOverlay();
			}
		});
	}

	function toggleOverlay() {
		FlxG.mouse.useSystemCursor = (visible = !visible);
		FlxG.mouse.enabled = !FlxG.mouse.useSystemCursor;
		FlxG.keys.enabled = true;
	}

	public override function __enterFrame(deltaTime:Int) {
		super.__enterFrame(deltaTime);

		graphics.clear();
		graphics.beginFill(0x000000, 0.5);
		graphics.drawRect(0, 0, lime.app.Application.current.window.width, lime.app.Application.current.window.height);
		graphics.endFill();
	}
}
