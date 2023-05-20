package;

import engine.backend.Conductor;
import openfl.display.FPS;
import engine.*;
import flixel.FlxGame;

class Main extends Sprite {
	public function new() {
		super();

		addChild(new FlxGame(0, 0, PlayState));
		addChild(new FPS(10,10,0xFFFFFF));

		FlxG.signals.preUpdate.add(Conductor.update);
	}
}
