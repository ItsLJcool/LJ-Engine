package assets;

class Paths {
	public static var CURRENT_MOD = "Funkin'";

	public inline static function getPath(path:String):String {
		return FileSystem.absolutePath('assets/$path');
	}

	public inline static function image(path:String):String {
		return getPath('images/$path.png');
	}

	public inline static function getSparrowAtlas(path:String) {
		return Assets.load(SPARROW, image(path));
	}

	public inline static function sound(path:String):String {
		return getPath('sounds/$path.ogg');
	}

	public inline static function music(path:String):String {
		return getPath('music/$path.ogg');
	}

	public inline static function json(path:String):String {
		return getPath('$path.json');
	}

	public static function script(path:String):Null<String> {
		var exts:Array<String> = ["hx", "hxs", "hscript"]; //idk who the fucc is gonna use .hscript but put it in anyways.

		for (ext in exts) {
			if (FileSystem.exists(getPath('$path.$ext')))
				return getPath('$path.$ext');
		}

		return null;
	}
}
