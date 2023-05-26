package scripts;

interface ScriptInterface {
    public var scriptFailed:Bool;

    public var parent(get, set):Dynamic;
    function get_parent():Dynamic;
    function set_parent(newParent:Dynamic):Dynamic;

    public var filePath:String;

    public function get(varName:String):Dynamic;

    public function set(varName:String, value:Dynamic):Void;

    public function call(funcName:String, ?params:Array<Dynamic>):Dynamic;

    public function destroy():Void;
}