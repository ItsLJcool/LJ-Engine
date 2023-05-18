package engine.utills;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets as LimeAssets;

class Mem {
    public static function clear() {
        Assets.cache.clear();
        LimeAssets.cache.clear();
        OpenFlAssets.cache.clear();
        FlxG.bitmap.dumpCache();
        FlxG.bitmap.clearCache();
        #if cpp
        cpp.vm.Gc.run();
        #end
    }
}
