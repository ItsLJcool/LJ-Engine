package assets;

import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import sys.io.File;

using StringTools;

class Assets {
	public static var _cache:AssetCache = new AssetCache();

	public static function load(type:AssetsType, path:String):Dynamic {
		path = FileSystem.absolutePath(path);

		if (_cache.hasAsset(path))
			return _cache.getAsset(path);

		if (!FileSystem.exists(path) && type != IMAGE) {
			trace('FILE NOT FOUND: ${path} RETURNING');
			return null;
		}
		switch (type) {
			case TEXT:
				return File.getContent(path);
			case JSON:
				_cache.add(path, Json.parse(File.getContent(path)));
				return _cache.getAsset(path);
			case XML:
				_cache.add(path, Xml.parse(File.getContent(path)));

				return _cache.getAsset(path);
			case SOUND:
				_cache.add(path, Sound.fromAudioBuffer(AudioBuffer.fromBytes(File.getBytes(path))));

				return _cache.getAsset(path);
			case IMAGE:
				var graphic:FlxGraphic;
				if (!FileSystem.exists(path))
					graphic = FlxGraphic.fromAssetKey("assets/embedded/whoops.png");
				else
					graphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(File.getBytes(path)));
				graphic.dump();
				graphic.bitmap.disposeImage();
				graphic.persist = true;
				_cache.add(path, graphic);
				return _cache.getAsset(path);
			case SPARROW:
				return FlxAtlasFrames.fromSparrow(load(IMAGE, path), load(XML, path.replace(".png", ".xml")));
			case PACKER:
				return FlxAtlasFrames.fromSpriteSheetPacker(load(IMAGE, path), load(TEXT, path.replace(".png", ".txt")));
		}
		return null;
	}
}
