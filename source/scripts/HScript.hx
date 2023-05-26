package scripts;

import backend.MusicBeat.MusicBeatState;
import flixel.FlxG;
import hscript.Expr.Error;
import hscript.*;

class HScript implements scripts.ScriptInterface {
    public static var classes:Map<String, Class<Dynamic>> = [
        "Math" => Math,
        "Std" => Std,

        "FlxG" => flixel.FlxG,
        "FlxSprite" => flixel.FlxSprite,
        "FlxTimer" => flixel.util.FlxTimer,
        "FlxTween" => flixel.tweens.FlxTween,
        "FlxEase" => flixel.tweens.FlxEase,
        "FlxText" => flixel.text.FlxText,
        "FlxTrail" => flixel.addons.effects.FlxTrail,
        "FlxBackdrop" => flixel.addons.display.FlxBackdrop,

        "Paths" => Paths,
        "Assets" => Assets,
    ];
    public static var statics:Map<String, Dynamic> = [];
    public static var parser:Parser;

    public var interp:Interp;
    public var expr:Expr;

    public var scriptFailed:Bool = false;

    @:isVar public var parent(get, set):Dynamic;
    public inline function get_parent():Dynamic {
        return (interp != null) ? interp.scriptObject : null;
    }
    public function set_parent(newParent:Dynamic) {
        if (interp != null)
            interp.scriptObject = newParent;
        return parent = newParent;
    }

    public var filePath:String;

    public function new(path:String) {
        if (parser == null)
            initParser();

        filePath = path;

        interp = new Interp();

        if (FlxG.state is MusicBeatState)
            interp.publicVariables = cast (FlxG.state, MusicBeatState).publicVars;
        interp.staticVariables = statics;

        interp.allowStaticVariables = true;
        interp.allowPublicVariables = true;
        interp.errorHandler = traceError;
        try {
            parser.line = 1; //Reset the parser position.
            expr = parser.parseString(Assets.load(TEXT, path), path);

            interp.variables.set("trace", hscriptTrace);

            for (val in classes.keys())
                interp.variables.set(val, classes[val]);

            interp.execute(expr);
        } catch (e) {
            scriptFailed = true;
            var exThingy = e.toString();
            openfl.Lib.application.window.alert('Failed to parse the file located at "$path".\r\n$exThingy at ${parser.line}');
        }
    }

    function hscriptTrace(v:Dynamic) {
        var posInfos = interp.posInfos();
        Sys.println(posInfos.fileName + ":" + posInfos.lineNumber + ": " + Std.string(v));
    }

    function traceError(e:Error) {
        var errorString:String = e.toString();
        Sys.println(errorString);
    }

    public function get(name:String) {
        if (interp == null)
            return null;
        return interp.variables.get(name);
    }

    public function set(name:String, value:Dynamic) {
        if (interp != null)
            interp.variables.set(name, value);
    }

    public function call(name:String, ?params:Array<Dynamic>) {
        if (interp == null) return null;

        var functionVar = interp.variables.get(name);
        var hasParams = (params != null && params.length > 0);

        if (functionVar == null || !Reflect.isFunction(functionVar))
            return null;

        return hasParams ? Reflect.callMethod(null, functionVar, params) : functionVar();
    }

    public function destroy() {
        expr = null;
        interp = null;
    }

    public static function initParser() {
        parser = new hscript.Parser();
        parser.allowJSON = true;
        parser.allowMetadata = true;
        parser.allowTypes = true;
        parser.preprocesorValues = [
            "sys" => #if (sys) true #else false #end,
            "desktop" => #if (desktop) true #else false #end,
            "windows" => #if (windows) true #else false #end,
            "mac" => #if (mac) true #else false #end,
            "linux" => #if (linux) true #else false #end,
        ];
    }
}