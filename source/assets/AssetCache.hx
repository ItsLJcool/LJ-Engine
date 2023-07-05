package assets;

import haxe.ds.HashMap;

class AssetCache {
	var cacheMap:Map<String, Any> = [];

	public function new() {
		cacheMap = [];
	}

	public function add(key:String, value:Any) {
		if (!hasAsset(key) || (hasAsset(key) && value != getAsset(key)))
			cacheMap.set(key, value);
	}

	public function clear() {
		for (key in cacheMap) {
			cacheMap.remove(key);
		}
	}

	public function hasAsset(key:String) {
		return cacheMap.exists(key);
	}

	public function getAsset(key:String) {
		if (!hasAsset(key)) {
			Sys.print('ASSET NOT FOUND WITH KEY: ${key}');
			return null;
		}
		return cast cacheMap.get(key);
	}
}
