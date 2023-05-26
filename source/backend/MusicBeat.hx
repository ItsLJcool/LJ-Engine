package backend;

import backend.Conductor;

class MusicBeatState extends flixel.addons.ui.FlxUIState {
    public var publicVars:Map<String, Dynamic> = [];

    public var curBeat(get, null):Int = 0;
    inline function get_curBeat():Int
        return Conductor.curBeat;

    public var curStep(get, null):Int = 0;
    inline function get_curStep():Int
        return Conductor.curStep;

    public var floatBeat(get, null):Float = 0;
    inline function get_floatBeat():Float
        return Conductor.floatBeat;

    public var floatStep(get, null):Float = 0;
    inline function get_floatStep():Float
        return Conductor.floatStep;

    override public function create() {
        super.create();
        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
    }

    override public function destroy() {
        super.destroy();
        Conductor.onBeatHit.remove(beatHit);
        Conductor.onStepHit.remove(stepHit);
    }

    function beatHit(curBeat:Int) {}

    function stepHit(curStep:Int) {}
}

class MusicBeatSubstate extends flixel.FlxSubState {
    public var curBeat(get, null):Int = 0;
    inline function get_curBeat():Int
        return Conductor.curBeat;

    public var curStep(get, null):Int = 0;
    inline function get_curStep():Int
        return Conductor.curStep;

    public var floatBeat(get, null):Float = 0;
    inline function get_floatBeat():Float
        return Conductor.floatBeat;

    public var floatStep(get, null):Float = 0;
    inline function get_floatStep():Float
        return Conductor.floatStep;

    public function new() {
        super();
        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
    }

    override public function destroy() {
        super.destroy();
        Conductor.onBeatHit.remove(beatHit);
        Conductor.onStepHit.remove(stepHit);
    }

    function beatHit(curBeat:Int) {}

    function stepHit(curStep:Int) {}
}