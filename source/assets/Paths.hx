package assets;
import flixel.graphics.FlxGraphic;

class Paths {
	public static var CURRENT_MOD:String = "Template Mod";

	public static function getPath(path:String, forceAssets:Bool = false):String {
		if (!forceAssets) {
			var daPath = FileSystem.absolutePath('mods/$CURRENT_MOD/$path');
			if (FileSystem.exists(daPath))
				return daPath;
		}

		return FileSystem.absolutePath('assets/$path');
	}

    public inline static function getAllMods():Array<String> {
        var modArry = FileSystem.readDirectory(FileSystem.absolutePath('mods/'));
        if (modArry.length < 1) return [];
        var tempArry:Array<String> = [];
        for (mod in modArry) {
            if (!FileSystem.isDirectory(FileSystem.absolutePath('mods/$mod'))) continue;
            tempArry.push(mod);
        }
        return tempArry;
    }

	public inline static function image(path:String):String {
		return getPath('images/$path.png');
	}

	/**
		@param path Make sure you Define the extension (ex: font.ttf / font.otf)
	**/
	public inline static function font(path:String):String {
		return getPath('fonts/$path');
	}

	public inline static function loadImage(path:String):FlxGraphic {
		return Assets.load(IMAGE, image(path));
	}
	/**
		@param path This is the Path of the `Image` and `XML` data, usually in this format: `Paths.getSparrowAtlas("icon");` This returns the Icon in `asset/images/icon.png`.
		@param useImagesFolder (Not needed) Allows you to dispand 
	**/
	public inline static function getSparrowAtlas(path:String, ?useImagesFolder:Bool = true) {
		return Assets.load(SPARROW, (useImagesFolder) ? image(path) : getPath('$path.png'));
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
		return Json.parse(json);
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
		var assetTypes:Array<assets.Assets.AssetsType> = [SPARROW, PACKER];

		for (i => suffix in suffixes) {
			if (FileSystem.exists(getPath('characters/$char/spritesheet$suffix')))
				return Assets.load(assetTypes[i], getPath('characters/$char/spritesheet.png'));
		}

		return null;
	}
}
