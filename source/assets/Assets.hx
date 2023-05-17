//a
package assets;
import haxe.io.Bytes;
import openfl.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Assets {
	public static var cache = new AssetCache();

	public static function exists(name:String):Bool {
		if (Paths.CURRENT_MOD != null)
			return FileSystem.exists(Paths.getPath(name));
		return false;
	}

	public static function getdirs(dir:String):Array<String> {
		if (Paths.CURRENT_MOD == null && !FileSystem.isDirectory(Paths.getPath(dir))) {
			trace("None Found :C");
			return [];
		}
		return FileSystem.readDirectory(Paths.getPath(dir));
	}

	public static function load(type:AssetType, path:String, ?curentCache:AssetCache):Dynamic {
		try {
			path = FileSystem.absolutePath(path);
			if (cache == null)
				curentCache = cache;

			switch (type) {
				case TEXT:
					if (!cache.exists(path))
						cache.add(path, File.getContent(path));
					return cache.get(path);
				case JSON:
					if (!cache.exists(path))
						cache.add(path, Json.parse(File.getContent(path)));
					return cache.get(path);
				case XML:
					if (!cache.exists(path))
						cache.add(path, Xml.parse(File.getContent(path)));
					return cache.get(path);
				// case INI:
				// 	if (!cache.exists(path))
				// 		cache.add(path, IniParser.parse(File.getContent(path)));
				// 	return cache.get(path);
				case IMAGE:
					if (!cache.exists(FileSystem.absolutePath(path))) {
						var bmp = BitmapData.fromFile(path);
						// Load default flixel image if image couldn't be found
						if (bmp == null)
							bmp = openfl.Assets.getBitmapData("flixel/images/logo/default.png");

						cache.add(path, FlxGraphic.fromBitmapData(bmp, false, path, false));
					}
					return cache.get(path);
				case SPARROW:
					return FlxAtlasFrames.fromSparrow(load(IMAGE, FileSystem.absolutePath(path)), load(XML, FileSystem.absolutePath(path).replace(".png", ".xml")), false);
				case SOUND:
					if (!cache.exists(FileSystem.absolutePath(path)))
						cache.add(path, Sound.fromFile(path));
					return cache.get(path);
				case GIF:
					if (!cache.exists(path))
						cache.add(path, Bytes.ofString(File.getContent(FileSystem.absolutePath(path))));
					return cache.get(path);
				default:
					trace("no Asset Type found");
					return null;
			}
		} catch (e) {
			trace("File Named " + '"${path}"' + " not Found");
			return null;
		}
	}
}

class AssetCache {
	public function new() {}

	var cache:Map<String, Any> = new Map();

	public function add(path:String, data:Any) {
		cache.set(FileSystem.absolutePath(path), data);
		var items = 0;
		for (asset in cache.keys())
			items++;
		trace('Asset cache has $items asset');
	}

	public function get(path:String) {
		return cache.get(path);
	}

	public function exists(path:String) {
		return cache.exists(path);
	}

	public function remove(path:String) {
		var data = get(path);
		if (Std.isOfType(data, FlxGraphic)) {
			var graphic:FlxGraphic = cast data;
			graphic.destroyOnNoUse = true;
			graphic.persist = false;
			graphic.dump();
			graphic.destroy();
		}
		cache.remove(path);
	}

	public function clear() {
		for (asset in cache.keys())
			remove(asset);
	}
}
