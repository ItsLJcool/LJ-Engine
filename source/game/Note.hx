package game;

import backend.Conductor;

enum NoteScrollType {
    NOTE;
    HOLD;
    TAIL;
}

class Note extends FlxSprite {
    public var time:Float = 0;
    public var direction:Int = 0;

    public var scrollType:NoteScrollType = NOTE;

    public function new(time:Float, direction:Int, ?scrollType:NoteScrollType = NOTE) {
        super(-999, -999);

		this.time = time;
		this.direction = direction;
		this.scrollType = scrollType;

        scale.scale(0.7);

        var directionName = ["left", "down", "up", "right"][direction]; //temp
        frames = Paths.getSparrowAtlas("gameUI/coloredStrums");
        switch (scrollType) {
            case NOTE:
                animation.addByPrefix("scroll", '$directionName note', 24, true);
                animation.play("scroll");
			case HOLD:
				animation.addByPrefix("hold", '$directionName hold', 24, true);
                animation.play("hold");

                scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
			case TAIL:
				animation.addByPrefix("tail", '$directionName tail', 24, true);
                animation.play("tail");
        }
        
        updateHitbox();
    }
}