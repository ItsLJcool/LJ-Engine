package modding;
import backend.MusicBeat.MusicBeatState;
import scripts.ScriptInterface;
import scripts.HScript;
import sys.FileSystem;

class ModdableState extends MusicBeatState {

    var overrideState:Bool = false;
    var classScript:ScriptInterface;
    override function create() {
        super.create();
        // Returns the class thats Extending Moddable State
        var baseClassName = Type.getClassName(Type.getClass(FlxG.state));

        var baseSplit = baseClassName.split(".");
        var className = baseSplit[baseSplit.length-1];

        // Checks if the `states` folder contains the package structure in folders, then we get it from there, if not then just the class name works too.
        // Helps if you want your folders to be clean too.
        var scriptPath = Paths.script('states/${baseClassName.replace(".", "/")}');
        var path = (FileSystem.exists(scriptPath)) ? scriptPath : Paths.script('states/$className');

        if (path != null) {
            classScript = new HScript(path);
            if (classScript.scriptFailed) classScript.destroy(); 
            else {
                classScript.call("create");
            }
        }
        if (!overrideState) normalCreate();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (overrideState) classScript.call("update", [elapsed]);
        else normalUpdate(elapsed);
    }

    public override function destroy() {
        super.destroy();
        if (overrideState) classScript.call("destroy");
        else normalDestroy();
    }
    public override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);
        if (overrideState) classScript.call("beatHit", [curBeat]);
        else normalBeatHit(curBeat);
    }

    public override function stepHit(curStep:Int) {
        super.stepHit(curStep);
        if (overrideState) classScript.call("stepHit", [curStep]);
        else normalStepHit(curStep);
    }


    function normalCreate() {}
    function normalUpdate(elapsed:Float) {}
    function normalBeatHit(curBeat:Int) {}
    function normalStepHit(curStep:Int) {}
    function normalDestroy() {}
}