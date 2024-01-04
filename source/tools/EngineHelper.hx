package tools;

/**
    idk man it can help sometimes
**/
class EngineHelper {
    public static function iterativeItemLoop(loopedVar:Array<Dynamic>, loopFunc:(Int, Dynamic)->Void) {
        for (i=>item in loopedVar) loopFunc(i, item);
    }
}