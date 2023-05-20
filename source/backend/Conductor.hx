package backend;

import game.Song;
import flixel.util.FlxSignal.FlxTypedSignal;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor {
    public static var songPosition:Float = 0;
    public static var songRate:Float = 1;
    public static var updateSongPos:Bool = true;

	public static var bpm(default, set):Float = 100;
    static function set_bpm(newBPM:Float) {
		crochet = ((60 / newBPM) * 1000);
		stepCrochet = crochet / 4;

        return bpm = newBPM;
    }

	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

    public static var curBeat:Int = 0;
    public static var curStep:Int = 0;
    public static var floatBeat:Float = 0;
    public static var floatStep:Float = 0;

    public static var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
    public static var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

    public static var bpmChanges:Array<BPMChangeEvent> = [];
    public static var curChange:BPMChangeEvent;

    public static function mapBPMChanges(song:SwagSong) {
        bpmChanges = [{
            bpm: song.bpm,
            songTime: 0,
            stepTime: 0
        }];

        var curBPM:Float = song.bpm;
        var curPos:Float = 0;
        var curSteps:Int = 0;
        for (section in song.notes) {
            if (section.changeBPM && section.bpm != null && section.bpm != curBPM)
                bpmChanges.push({
                    bpm: section.bpm,
                    songTime: curPos,
                    stepTime: curSteps
                });

            curSteps += section.lengthInSteps;
            curPos += ((60 / curBPM) * 1000 / 4) * section.lengthInSteps;
        }
    }

    public static function update() {
        if (!updateSongPos) return;

        songPosition += FlxG.elapsed * songRate;

        curChange = bpmChanges[0];
        for (change in bpmChanges) {
            if (change.songTime < songPosition)
                break;
            curChange = change;
        }

        floatStep = curChange.stepTime + (songPosition - curChange.songTime) / stepCrochet;
        if (curStep != (curStep = Math.floor(floatStep)) && floatStep >= 0)
            onStepHit.dispatch(curStep);

        floatBeat = floatStep / 4;
        if (curBeat != (curBeat = Math.floor(floatBeat)) && floatBeat >= 0)
            onBeatHit.dispatch(curBeat);
    }
}