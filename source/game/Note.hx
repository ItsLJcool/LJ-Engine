package game;

import flixel.math.FlxRect;
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

	// Animation Stuff.
	public var characters:Array<Character>;
	public var animToPlay:String = "singLEFT";

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
	public var holding:Bool = false;
	public var untilTick:Float;
	public var hold:Sustain;
	public var tail:FlxSprite;
	public var sustainLength:Float = 0;

	public function new(time:Float, direction:Int, mustPress:Bool, char:Character, stepLength:Float, ?sustainLength:Float = 0) {
		super(-999, -999);

		this.time = time;
		this.direction = direction;
		this.mustPress = mustPress;
		this.characters = [char];
		this.stepLength = untilTick = stepLength;

		scale.scale(0.7);

		final directionName = ["left", "down", "up", "right"][direction]; // temp
		animToPlay = "sing" + directionName.toUpperCase();
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

		if (hold == null && newLength > 0) {
			final directionName = ["left", "down", "up", "right"][direction];

			hold = new Sustain(directionName, noteShader);

			tail = new FlxSprite(-999, -999);
			tail.frames = hold.frames;
			tail.animation.addByPrefix("tail", '$directionName tail', 24, true);
			tail.animation.play("tail");
			tail.shader = noteShader;
			tail.scale.scale(0.7);
			tail.updateHitbox();
			tail.clipRect = new FlxRect(0, 0, tail.frameWidth, tail.frameHeight);
			tail.offset.x = tail.frameWidth * 0.5;
		}

		hold.sustainMult = ((45 * (newLength * speed * 0.015)) - tail.frameHeight) / hold.frameHeight;
		tail.clipRect.y = -Math.min(hold.sustainMult, 0.0) * tail.frameHeight;
		tail.clipRect = tail.clipRect;
	}

	override public function draw() {
		if (frame == null) return;

		noteShader.noteColor.value[0] = noteColor.redFloat;
		noteShader.noteColor.value[1] = noteColor.greenFloat;
		noteShader.noteColor.value[2] = noteColor.blueFloat;

		if (hold != null) {
			hold.setPosition(x + width * 0.5, y + height * 0.5);
			hold.alpha = alpha * 0.6;
			hold.draw();

			tail.setPosition(hold.x, hold.y + hold.height);
			tail.alpha = hold.alpha;
			tail.draw();
		}
		if (!wasHit)
			super.draw();
	}

	override public function destroy() {
		if (hold != null) {
			hold.destroy();
			tail.destroy();
		}
		super.destroy();
	}

	// GETTERS AND SETTERS

	function get_canBeHit():Bool {
		return (time - maxEarlyDiff < Conductor.songPosition && time + maxLateDiff > Conductor.songPosition);
	}

	var _tooLate:Bool = false;
	function get_tooLate():Bool {
		_tooLate = _tooLate || (time + missDiff < Conductor.songPosition && !holding && !canBeHit);
		return _tooLate;
	}
}
