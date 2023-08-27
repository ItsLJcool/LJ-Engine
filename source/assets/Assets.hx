package assets;

import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import sys.io.File;

class Assets {
    private static var cache:Map<String, Dynamic> = [];

    public static function load(type:AssetsType, path:String) {
		path = FileSystem.absolutePath(path);
		if (cache.exists(path) && !type.isSpritesheet()) return cache.get(path);

		if (!FileSystem.exists(path) && type != IMAGE) {
			trace('FILE NOT FOUND: ${path} RETURNING');
			return null;
		}
        
		switch (type) {
			case TEXT:
                return File.getContent(path);
			case JSON:
				cache.set(path, Json.parse(File.getContent(path)));
				return cache.get(path);
			case XML:
				cache.set(path, Xml.parse(File.getContent(path)));

				return cache.get(path);
			case SOUND:
				cache.set(path, Sound.fromAudioBuffer(AudioBuffer.fromBytes(File.getBytes(path))));

				return cache.get(path);
			case IMAGE:
				var graphic:FlxGraphic;
				if (!FileSystem.exists(path)) graphic = FlxGraphic.fromAssetKey("assets/embedded/whoops.png");
				else graphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(File.getBytes(path)));
				graphic.dump();
				graphic.bitmap.disposeImage();
				graphic.persist = true;
				cache.set(path, graphic);
				return cache.get(path);
			case SPARROW:
				return FlxAtlasFrames.fromSparrow(load(IMAGE, path), load(XML, path.replace(".png", ".xml")));
			case PACKER:
				return FlxAtlasFrames.fromSpriteSheetPacker(load(IMAGE, path), load(TEXT, path.replace(".png", ".txt")));
		}
		return null;
    }
}

enum abstract AssetsType(String) from String to String {
    var IMAGE:String = "IMAGE";
    var SOUND:String = "SOUND";
    var JSON:String = "JSON";
    var XML:String = "XML";
    var TEXT:String = "TEXT";
    var SPARROW:String = "SPARROW";
    var PACKER:String = "PACKER";

    inline public function isSpritesheet() return (this == SPARROW || this == PACKER);
}