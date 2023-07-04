package assets;

import haxe.Json;

class Paths {
	public static var CURRENT_MOD = "Funkin'";

	public inline static function getPath(path:String):String {
		var daPath = FileSystem.absolutePath('mods/$CURRENT_MOD/$path');
		if (FileSystem.exists(daPath))
			return daPath;

		return FileSystem.absolutePath('assets/$path');
	}

	public inline static function image(path:String):String {
		return getPath('images/$path.png');
	}

	public inline static function loadImage(path:String):String {
		return Assets.load(IMAGE, image(path));
	}

	public inline static function getSparrowAtlas(path:String, ?useImagesFolder:Bool = true) {
		return Assets.load(
			SPARROW,
			((useImagesFolder) ? image(path) : getPath('$path.png'))
		);
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

	public inline static function loadJson(path:String):String {
		return Assets.load(JSON, json(path));
	}

	public inline static function parseJson(path:String):String {
		var json = Assets.load(JSON, json(path));
		var parsed = Json.parse(json);
		return parsed;
	}

	public inline static function txt(path:String):String {
		return getPath('assets/$path');
	}

	public inline static function loadTxt(path:String):String {
		return Assets.load(TEXT, txt(path));
	}

	public static function script(path:String):Null<String> {
		var exts:Array<String> = ["hx", "hxs", "hscript"]; // idk who the fucc is gonna use .hscript but put it in anyways.

		for (ext in exts) {
			if (FileSystem.exists(getPath('$path.$ext')))
				return getPath('$path.$ext');
		}

		return null;
	}

	public static function getCharacter(char:String) {
		var suffixes:Array<String> = [".xml", ".txt"];
		var assetTypes:Array<assets.AssetType> = [SPARROW, PACKER];

		for (i => suffix in suffixes) {
			if (FileSystem.exists(getPath('characters/$char/spritesheet$suffix')))
				return Assets.load(assetTypes[i], getPath('characters/$char/spritesheet.png'));
		}

		return null;
	}
}
