package;

import backend.Conductor;
import flixel.FlxGame;
import openfl.display.FPS;

using StringTools;

class Main extends Sprite {
	public function new() {
		super();

		// temporary
		var controls = sys.io.File.getContent(Paths.getPath('data/tempData.txt')).split("\n");
		for (i in 0...8)
			game.Receptor.keybindList[i % 4].push(FlxKey.fromString(controls[i].trim()));
		game.PlayState.SONG = game.Song.SongParser.parseSongJson("hard", controls[8].trim().toLowerCase());

		addChild(new FlxGame(0, 0, menus.TitleState, 500, 500, true));
		addChild(new FPS(10, 10, 0xFFFFFF));
		FlxG.fixedTimestep = false;

		FlxG.signals.preUpdate.add(Conductor.update);
	}
}
