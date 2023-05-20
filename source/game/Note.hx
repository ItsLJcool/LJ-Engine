package game;

import backend.Conductor;

enum NoteScrollType {
    NOTE;
    HOLD;
    TAIL;
}

class Note extends FlxSprite {
    public static var swagWidth:Float = 154 * 0.7;

	public var maxEarlyDiff:Float = 125;
	public var maxLateDiff:Float = 90;
	public var missDiff:Float = 250;

    public var time:Float = 0;
    public var direction:Int = 0;
    public var mustPress:Bool = false;
    public var scrollType:NoteScrollType = NOTE;
    public var stepLength:Float = 0;

    public var canBeHit(get, null):Bool = false;
    function get_canBeHit():Bool {
        return (time - maxEarlyDiff < Conductor.songPosition && time + maxLateDiff > Conductor.songPosition && scrollType == NOTE)
            || (time + maxEarlyDiff > Conductor.songPosition && time - stepLength < Conductor.songPosition && scrollType != NOTE);
    }

    var _tooLate:Bool = false;
    public var tooLate(get, null):Bool = false;
    function get_tooLate():Bool {
        _tooLate = _tooLate || (time + missDiff < Conductor.songPosition && !wasHit && !canBeHit);
        return _tooLate;
    }

    public var wasHit:Bool = false;

    public function new(time:Float, direction:Int, mustPress:Bool, ?scrollType:NoteScrollType = NOTE) {
        super(-999, -999);

		this.time = time;
		this.direction = direction;
        this.mustPress = mustPress;
		this.scrollType = scrollType;

        scale.scale(0.7);

        var directionName = ["left", "down", "up", "right"][direction]; //temp
        frames = Paths.getSparrowAtlas("gameUI/coloredNotes");
        switch (scrollType) {
            case NOTE:
                animation.addByPrefix("scroll", '$directionName note', 24, true);
                animation.play("scroll");
			case HOLD:
				animation.addByPrefix("hold", '$directionName hold', 24, true);
                animation.play("hold");

                scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
                alpha = 0.6;
			case TAIL:
				animation.addByPrefix("tail", '$directionName tail', 24, true);
                animation.play("tail");

                alpha = 0.6;
        }
        
        updateHitbox();
    }
}