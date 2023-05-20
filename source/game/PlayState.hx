package game;

import game.HUD;

class PlayState extends backend.MusicBeat.MusicBeatState {
	public static var current:PlayState;
	public static var SONG:game.Song.SwagSong;

	public var hud:HUD;

	override public function create() {
		super.create();
		current = this;

		hud = new HUD();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function destroy() {
		super.destroy();
		current = null;
	}
}
