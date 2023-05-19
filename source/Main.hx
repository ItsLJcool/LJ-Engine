package;

import openfl.display.FPS;
import engine.*;
import flixel.FlxGame;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(0, 0, PlayState));
		addChild(new FPS(10,10,0xFFFFFF));
	}
}
