package assets;

class Paths {
	public static var CURRENT_MOD = "Funkin'";

	public static function getPath(path:String) {
		return FileSystem.absolutePath('mods/$CURRENT_MOD/$path');
	}

	public static function image(path:String) {
		return getPath('images/$path.png');
	}

	public static function getSparrowAtlas(path:String) {
		return Assets.load(JSON, image("data/colors"));
	}

	public static function sound(path:String) {
		return getPath('sounds/$path.ogg');
	}

	public static function music(path:String) {
		return getPath('music/$path.ogg');
	}

	public static function json(path:String) {
		return getPath('$path.json');
	}
}
