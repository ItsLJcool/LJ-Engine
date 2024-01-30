package game;

import backend.Settings;
import backend.Conductor;
import game.NoteShaders;

import flixel.util.FlxColor;

typedef QueuedNote = {
	var time:Float;
	var direction:Int;
	var length:Float;
	var mustPress:Bool;

	var stepLength:Float;
}

class Note extends FlxSprite {
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

	// Input stuff.
	public var canBeHit(get, null):Bool = false;
	public var tooLate(get, null):Bool = false;
	public var wasHit:Bool = false;

	// Visual stuff.
	public var noteShader:NoteShader;
	public var noteColor:FlxColor;

	// Sustain stuff.
	public var hold:FlxSprite;
	public var tail:FlxSprite;
	public var holdShader:HoldShader;
	public var sustainLength:Float = 0;

	public function new(time:Float, direction:Int, mustPress:Bool, stepLength:Float, ?sustainLength:Float = 0) {
		super(-999, -999);

		this.time = time;
		this.direction = direction;
		this.mustPress = mustPress;
		this.stepLength = stepLength;

		scale.scale(0.7);

		var directionName = ["left", "down", "up", "right"][direction]; // temp
		frames = Paths.getSparrowAtlas("gameUI/coloredNotes");
		animation.addByPrefix("scroll", '$directionName note', 24, true);
		animation.play("scroll");
		updateHitbox();

		noteColor = Settings.colors[direction];
		shader = noteShader = new NoteShader(noteColor, true);

		if (sustainLength > 0)
			setSustainLength(sustainLength, PlayState.SONG.speed);
	}

	public function setSustainLength(newLength:Float, speed:Float) {
		sustainLength = newLength;
		var sustainTile:Float = newLength / stepLength;

		if (hold == null && newLength > 0) {
			var directionName = ["left", "down", "up", "right"][direction];

			hold = new FlxSprite(x, y);
			hold.frames = Paths.getSparrowAtlas("gameUI/coloredNotes");
			hold.animation.addByPrefix("hold", '$directionName hold', 24, true);
			hold.animation.play("hold");
			hold.shader = holdShader = new HoldShader(noteColor, true);
			hold.scale.scale(0.7);
			hold.updateHitbox();
			hold.origin.y = 0;
			hold.offset.x = hold.frameWidth * 0.5;

			hold.alpha = 0.6;
		}

		hold.scale.y = scale.y * sustainTile * stepLength * 0.01 * 1.5 * speed;
		holdShader.tileMult.value = [sustainTile];
	}

	override public function draw() {
		if (frame == null) return;

		noteShader.noteColor.value[0] = noteColor.redFloat;
		noteShader.noteColor.value[1] = noteColor.greenFloat;
		noteShader.noteColor.value[2] = noteColor.blueFloat;

		super.draw();
		if (hold != null) {
			holdShader.frameTop.value = [(hold.frame.frame.top + 1.5) / hold.frames.parent.height];
			holdShader.frameBottom.value = [(hold.frame.frame.bottom - 1.5) / hold.frames.parent.height];
			hold.setPosition(x + width * 0.5, y + height * 0.5);
			hold.draw();
		}
		// if (Settings.downscroll) {
		// 	var ogY = y;
		// 	var scaleYMult = (scrollType != NOTE) ? -1 : 1;

		// 	y = FlxG.height - (frameHeight * scale.y) - y;
		// 	scale.y *= scaleYMult;
		// 	super.draw();
		// 	scale.y *= scaleYMult;
		// 	y = ogY;
		// }
		// else super.draw();
	}

	override public function destroy() {
		if (hold != null) {
			hold.destroy();
		}
		super.destroy();
	}

	// GETTERS AND SETTERS

	function get_canBeHit():Bool {
		return (time - maxEarlyDiff < Conductor.songPosition && time + maxLateDiff > Conductor.songPosition);
	}

	var _tooLate:Bool = false;
	function get_tooLate():Bool {
		_tooLate = _tooLate || (time + missDiff < Conductor.songPosition && !wasHit && !canBeHit);
		return _tooLate;
	}
}
