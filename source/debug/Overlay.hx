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
	private var info:TextField;
	private var commandline:TextField;
	
	@:isVar public var font(get, set):String = "sans extra bold";
	private function set_font(s:String):String { return s = haxe.io.Path.withoutExtension(s); }
	private function get_font():String { return font; }

	public function new() {
		super();
		title = new TextField();
		title.autoSize = LEFT;
		title.selectable = false;
		title.textColor = 0xFFFFFFFF;
		title.defaultTextFormat = new TextFormat(Paths.font('${font}.ttf'), 16);
		title.text = 'LJ Engine (PlaceHolder Name) | ${Main.engineVersion}';
		title.y += 15;
		title.x += 15;
		addChild(title);

		info = new TextField();
		info.autoSize = LEFT;
		info.selectable = false;
		info.textColor = 0xFFFFFFFF;
		info.multiline = true;
		info.defaultTextFormat = new TextFormat(Paths.font('${font}.ttf'), 24);
		info.text = 'Alpha Debug Tools:'
		+ '\nF1: menus.TitleState'
		+ '\nF2: menus.MainMenuState'
		+ '\nF6: Closes Debug Tools'
		+ '\nF7: modding.Toolbox.ToolboxMain';
		info.y = title.y + title.height;
		info.x += 15;
		addChild(info);
		
		// commandline = new TextField();
        // commandline.selectable = true;
        // commandline.type = INPUT;
        // commandline.text = "";
        // commandline.textColor = 0xFFFFFFFF;
        // commandline.defaultTextFormat = new TextFormat(Paths.font('${font}.ttf'), 12);
        // commandline.height = 22;

		visible = true;
		toggleOverlay();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
			switch (e.keyCode) {
				case Keyboard.F6:
					toggleOverlay();
			}
			if (visible) {
				switch(e.keyCode) {
					case Keyboard.F7:
						FlxG.switchState(new modding.Toolbox.ToolboxMain());
					case Keyboard.F1:
						FlxG.switchState(new menus.TitleState());
					case Keyboard.F2:
						FlxG.switchState(new menus.MainMenuState());
				}
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
		if (!visible) return;

		graphics.clear();
		graphics.beginFill(0x000000, 0.5);
		graphics.drawRect(0, 0, lime.app.Application.current.window.width, lime.app.Application.current.window.height);
		graphics.endFill();
	}
}
