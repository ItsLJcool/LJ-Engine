package game;

import backend.Conductor;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

enum NoteScrollType {
	NOTE;
	HOLD;
	TAIL;
} class NoteShader extends FlxGraphicsShader {

	@:glFragmentSource('#pragma header

    uniform vec4 noteColor; //Set a to 0 to disable.
    
    uniform float yClip;
    uniform float frameY;
    uniform bool invert;
    
    void main() {
        if ((openfl_TextureCoordv.y < (frameY + yClip) / openfl_TextureSize.y && !invert) || (1.0 - openfl_TextureCoordv.y < (frameY + yClip) / openfl_TextureSize.y && invert))
            discard;

        vec4 texColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

        if (noteColor.a > 0.0) {
            float diff = texColor.r - ((texColor.g + texColor.b) / 2.0);

            gl_FragColor = vec4(
                ((texColor.g + texColor.b) / 2.0) + (noteColor.r * diff),
                texColor.g + (noteColor.g * diff),
                texColor.b + (noteColor.b * diff),
                texColor.a
            ) * noteColor.a;
        } else
            gl_FragColor = texColor;
    }
    ')
	public function new(color:FlxColor, enabled:Bool) {
		super();
		this.noteColor.value = [color.redFloat, color.greenFloat, color.blueFloat, enabled ? 1 : 0];
		this.yClip.value = [0];
	}
} class Note extends FlxSprite {

	public static var swagWidth:Float = 154 * 0.7;

	// Calculation Stuff.
	public var maxEarlyDiff:Float = 125;
	public var maxLateDiff:Float = 90;
	public var missDiff:Float = 250;
	public var stepLength:Float = 0;

	// Note data stuff.
	public var time:Float = 0;
	public var direction:Int = 0;
	public var mustPress:Bool = false;
	public var scrollType:NoteScrollType = NOTE;

	// Input stuff.
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

	// Visual stuff.
	public var yClip:Float = 0;
	public var noteShader:NoteShader;
	public var noteColor:FlxColor;

	public function new(time:Float, direction:Int, mustPress:Bool, stepLength:Float, ?scrollType:NoteScrollType = NOTE) {
		super(-999, -999);

		this.time = time;
		this.direction = direction;
		this.mustPress = mustPress;
		this.stepLength = stepLength;
		this.scrollType = scrollType;

		scale.scale(0.7);

		var directionName = ["left", "down", "up", "right"][direction]; // temp
		frames = Paths.getSparrowAtlas("gameUI/coloredNotes");
		switch (scrollType) {
			case NOTE:
				animation.addByPrefix("scroll", '$directionName note', 24, true);
				animation.play("scroll");
			case HOLD:
				animation.addByPrefix("hold", '$directionName hold', 24, true);
				animation.play("hold");

				scale.y *= stepLength / 100 * 1.5 * PlayState.SONG.speed;
				alpha = 0.6;

				clipRect = new FlxRect(0, 0, frameWidth, frameHeight);
			case TAIL:
				animation.addByPrefix("tail", '$directionName tail', 24, true);
				animation.play("tail");

				alpha = 0.6;

				clipRect = new FlxRect(0, 0, frameWidth, frameHeight);
		}

		updateHitbox();

		noteColor = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F][direction];
		shader = noteShader = new NoteShader(noteColor, true);
	}

	override public function draw() {
		noteShader.frameY.value = [frame.frame.top];
		noteShader.yClip.value = [yClip];
		noteShader.noteColor.value[0] = noteColor.redFloat;
		noteShader.noteColor.value[1] = noteColor.greenFloat;
		noteShader.noteColor.value[2] = noteColor.blueFloat;
		noteShader.invert.value = [backend.Settings.downscroll && scrollType != NOTE];

		if (backend.Settings.downscroll) {
			var ogY = y;
			var scaleYMult = (scrollType != NOTE) ? -1 : 1;

			y = FlxG.height - (frameHeight * scale.y) - y;
			scale.y *= scaleYMult;
			super.draw();
			scale.y *= scaleYMult;
			y = ogY;
		}
		else
			super.draw();

		noteShader.invert.value = [false];
	}
}
