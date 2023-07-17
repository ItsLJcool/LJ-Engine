package assets;

import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFlAssets;

class Mem {
	public static function clear() {
		Assets._cache.clear();
		LimeAssets.cache.clear();
		OpenFlAssets.cache.clear();
		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();
		#if cpp
		cpp.vm.Gc.run(true);
		#end
		#if hl
		hl.Gc.major();
		#end
	}
}
