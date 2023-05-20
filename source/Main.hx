package;

import backend.Conductor;
import openfl.display.FPS;
import engine.*;
import flixel.FlxGame;

using StringTools;

class Main extends Sprite {
	public function new() {
		super();

		//temporary
		var controls = Assets.load(TEXT, FileSystem.absolutePath('assets/data/temoControls.txt')).split("\n");
		for (i in 0...8)
			game.Receptor.keybindList[i % 4].push(FlxKey.fromString(controls[i].trim()));

		addChild(new FlxGame(0, 0, game.PlayState));
		addChild(new FPS(10,10,0xFFFFFF));

		FlxG.signals.preUpdate.add(Conductor.update);
	}
}
